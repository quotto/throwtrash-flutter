import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class UserService extends UserServiceInterface {
  User _user = User('');
  final UserRepositoryInterface _userRepository;
  final UserApiInterface _userApi;
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserService(
    this._userRepository,
    this._userApi,
  )   : _firebaseAuth = auth.FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  @override
  User get user => _user;

  @override
  Future<void> refreshUser() async {
    User? savedUser = await _userRepository.readUser();

    // Check if there's a Firebase user
    auth.User? firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null && savedUser != null) {
      // If we have both Firebase user and saved user, create a merged user
      _user = User.fromFirebaseUser(firebaseUser, existingUserId: savedUser.id);
    } else if (firebaseUser != null) {
      // If we only have Firebase user
      _user = User.fromFirebaseUser(firebaseUser);
    } else if (savedUser != null) {
      // If we only have saved user
      _user = savedUser;
    }
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
  Future<bool> signInAnonymously() async {
    try {
      // Sign in anonymously with Firebase
      final auth.UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return false;

      // Register the new user with our API
      String userId = await _userApi.registerUser();
      if (userId.isEmpty) return false;

      // Save the user locally
      await registerUser(userId);

      return true;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return false;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      // Begin Google sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if we have an anonymous user
      final auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        // Link the Google account with the anonymous account
        final auth.UserCredential userCredential = await currentUser.linkWithCredential(credential);

        // If this is the first time linking with this Google account,
        // inform the backend about the user signup
        await _userApi.signupGoogleUser(_user.id);
      } else {
        // Sign in directly with Google
        await _firebaseAuth.signInWithCredential(credential);

        // Attempt to sign up the user if needed
        await _userApi.signupGoogleUser(_user.id);
      }

      // Refresh user data
      await refreshUser();
      return true;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      // Clear local data
      // First, sign in anonymously to create a new anonymous user
      final result = await signInAnonymously();
      return result;
    } catch (e) {
      print('Error signing out: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      // Call the API endpoint to delete the account
      final deleteSuccessful = await _userApi.deleteAccount();
      if (!deleteSuccessful) return false;

      // Delete the current Firebase user
      final auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      // Sign in anonymously to create a new account
      return await signInAnonymously();
    } catch (e) {
      print('Error deleting account: $e');
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
}
