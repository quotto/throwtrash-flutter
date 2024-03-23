import 'package:throwtrash/usecase/user_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserRepository implements UserRepositoryInterface {
  static const String USER_ID_KEY = 'USER_ID';
  static const String DEVICE_TOKEN_KEY = 'DEVICE_TOKEN';

  @override
  Future<User?> readUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString(USER_ID_KEY);
    if(userId == null) {
      return null;
    }
    return User(userId);
  }

  @override
  Future<bool> writeUser(User user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(USER_ID_KEY, user.id);
  }
}