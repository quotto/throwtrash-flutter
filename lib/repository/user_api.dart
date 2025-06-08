import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:throwtrash/models/user_api_signin_response.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/user.dart';
import 'app_config_provider.dart';

class UserApi extends UserApiInterface {
  static UserApi? _instance;
  final http.Client _httpClient;
  final AppConfigProvider _appConfigProvider;

  UserApi._(this._appConfigProvider, this._httpClient);

  static void initialize(AppConfigProvider appConfigProvider, http.Client httpClient) {
    if (_instance != null) {
      throw StateError('UserApi is already initialized');
    }
    _instance = UserApi._(appConfigProvider, httpClient);
  }

  factory UserApi() {
    if (_instance == null) {
      throw StateError('UserApi is not initialized');
    }
    return _instance!;
  }

  @override
  Future<SigninResponse> signin() async {
    final response = await _httpClient.post(
        Uri.parse('${_appConfigProvider.mobileApiUrl}/signin'),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    return response.statusCode == 200
        ? SigninResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)))
        : throw new Exception('Signin api response error: ${response.statusCode}');
  }

  @override
  Future<SigninResponse> signup(String userId) async {
    final idToken = await auth.FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('Firebase ID token is null. User must be authenticated.');
    }

    final response = await _httpClient.post(
        Uri.parse('${_appConfigProvider.mobileApiUrl}/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
          'X-TRASH-USERID': userId
        }
    );

    return response.statusCode == 200
        ? SigninResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)))
        : throw new Exception('Signup api response error: ${response.statusCode}');
  }

  @override
  Future<bool> deleteAccount(User user) async {
    try {
      http.BaseRequest request = http.Request(
        'DELETE',
        Uri.parse('${_appConfigProvider.mobileApiUrl}/delete'),
      );
      request.headers ['X-TRASH-USERID'] = user.id;
      request.headers['Content-Type'] = 'application/json';
      final response = await _httpClient.send(request);

      return response.statusCode == 204;
    } catch (e) {
      print('Error in deleteAccount: $e');
      return false;
    }
  }
}
