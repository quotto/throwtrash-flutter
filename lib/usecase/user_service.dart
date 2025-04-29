import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/models/user_api_signin_response.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class UserService extends UserServiceInterface {
  User _user = User('');
  final UserRepositoryInterface _userRepository;
  final UserApiInterface _userApi;
  final TrashRepositoryInterface _trashRepository;
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Logger _logger = Logger();

  UserService(
    this._userRepository,
    this._userApi,
    this._trashRepository,
  )   : _firebaseAuth = auth.FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn() {
    refreshUser();
  }

  @override
  User get user => _user;

  @override  Future<void> initialize() async {
    if(_firebaseAuth.currentUser == null) {
      await _firebaseAuth.signInAnonymously();
      _logger.i('Anonymous user signed in: ${_firebaseAuth.currentUser?.uid}');
    }  else {
      _logger.i('User already signed in: ${_firebaseAuth.currentUser?.uid}');
    }
    await refreshUser();
  }

  @override
  Future<void> refreshUser() async {
    await _userRepository.readUser().then((value) {
      _user = value != null ? value : User('');
    });
  }

  @override
  Future<bool> registerUser(String id) async {
    User newUser = User(id);
    if (await _userRepository.writeUser(newUser)) {
      await refreshUser();
      return true;
    }
    return false;
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      _logger.i('Google user signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || await _userRepository.readUser() == null) {
        throw Exception('User is not registered in or firebase user is null');
      }

      if (currentUser.isAnonymous) {
        try {
          // 新たにGoogleアカウントにリンクされた場合はユーザーIDとFirebaseアカウントの紐付けが
          // 既に完了している前提であるためAPIでのサインインは不要
          await currentUser.linkWithCredential(credential);
          _logger.d('Anonymous user linked with Google account.');
        } on auth.FirebaseAuthException catch (_) {
          // 既にリンク済みの場合もFirebaseAuthExceptionが発生するので、このCredentialを使ってサインインを試みる
          _logger.w('This Google account is already linked. Try signing in with provider credential.');
          await _firebaseAuth.signInWithCredential(credential);
          _logger.d('Firebase user authorized as ${_firebaseAuth.currentUser?.uid}');
          SigninResponse response = await _userApi.signin();
          if (response.userId == null) {
            throw Exception('Failed to sign in with Google: userId is null');
          }
          _user = User(response.userId!);
          _logger.i('User signed in as ${_user.id}');
        }
        // サインイン情報をローカルに保存する
        User updated_user = _user.signInWithGoogle(googleUser.email, googleUser.displayName != null ? googleUser.displayName! :"");
        await _userRepository.writeUser(updated_user);
        await refreshUser();

        await _trashRepository.truncateAllTrashData();
        await _trashRepository.updateLastUpdateTime(0);
      }
      return true;
    } catch (e) {
      _logger.e('Error signing in with Google: $e');
      return false;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      if(await _userRepository.deleteUser()) {
        await _trashRepository.truncateAllTrashData();
        await refreshUser();
        return await _signInAnonymously();
      }
      throw Exception('Unknown error: Failed to delete user from repository');
    } catch (e) {
      _logger.e('Error signing out: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      if(!await _userApi.deleteAccount(_user)) {
        throw Exception('Unknown error: Failed to delete account from API');
      }
      if(!await _userRepository.deleteUser()) {
        throw Exception('Unknown error: Failed to delete user from repository');
      }
      await _trashRepository.truncateAllTrashData();
      await _firebaseAuth.signOut();
      await refreshUser();
      return await _signInAnonymously();
    } catch (e, stackTrace) {
      _logger.e(e);
      _logger.e(stackTrace);
      return false;
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      final auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return null;

      return await currentUser.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  Future<bool> _signInAnonymously() async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception('Unknown error : Firebase user is null');
      _logger.i('Anonymous user signed in: ${firebaseUser.uid}');

      return true;
    } catch (e) {
      _logger.e('Error signing in anonymously: $e');
      return false;
    }
  }

}
