import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:uuid/uuid.dart';

import 'app_config_provider.dart';

class UserApi extends UserApiInterface {
  final FirebaseFirestore _firebaseFirestore;
  static UserApi? _instance;
  final http.Client _httpClient;
  final AppConfigProvider _appConfigProvider;

  UserApi._(this._firebaseFirestore, this._appConfigProvider, this._httpClient);

  static void initialize(AppConfigProvider appConfigProvider, http.Client httpClient) {
    if (_instance != null) {
      throw StateError('UserApi is already initialized');
    }
    _instance = UserApi._(FirebaseFirestore.instance, appConfigProvider, httpClient);
  }

  factory UserApi() {
    if (_instance == null) {
      throw StateError('UserApi is not initialized');
    }
    return _instance!;
  }

  @override
  Future<bool> refreshDeviceToken(String userId, String deviceToken) async {
    return await _firebaseFirestore
        .collection('devices')
        .doc(deviceToken)
        .set({
          'userId': userId,
          'created': DateTime.now().toUtc(),
          'updated': DateTime.now().toUtc()
        })
        .then((value) => true)
        .catchError((error) {
          print(error);
          return false;
        });
  }

  @override
  Future<String> registerUser() async {
    String userId = Uuid().v4();
    return await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .set({'created': DateTime.now().toUtc(), 'updated': DateTime.now().toUtc()})
        .then((_) => userId)
        .catchError((error) {
          print(error);
          return '';
        });
  }

  @override
  Future<bool> signupGoogleUser(String userId) async {
    try {
      final idToken = await auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return false;

      final response = await _httpClient.post(
        Uri.parse('${_appConfigProvider.apiEndpoint}/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: {'userId': userId},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error in signupGoogleUser: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      final idToken = await auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return false;

      final response = await _httpClient.post(
        Uri.parse('${_appConfigProvider.apiEndpoint}/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error in deleteAccount: $e');
      return false;
    }
  }
}
