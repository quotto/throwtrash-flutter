import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserRepository implements UserRepositoryInterface {
  static const String USER_ID_KEY = 'USER_ID';
  static const String DEVICE_TOKEN_KEY = 'DEVICE_TOKEN';
  static UserRepository? _instance;
  final SharedPreferences _preferences;

  UserRepository._(this._preferences);

  static void initialize(SharedPreferences preferences) {
    if(_instance != null) {
      throw StateError('UserRepository is already initialized');
    }
    _instance = UserRepository._(preferences);
  }

  factory UserRepository() {
    if(_instance == null) {
      throw StateError('UserRepository is not initialized');
    }
    return _instance!;
  }

  @override
  Future<User?> readUser() async {
    String? userId = this._preferences.getString(USER_ID_KEY);
    if(userId == null) {
      return null;
    }
    return User(userId);
  }

  @override
  Future<bool> writeUser(User user) async {
    return this._preferences.setString(USER_ID_KEY, user.id);
  }
}