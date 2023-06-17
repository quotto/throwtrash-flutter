import 'package:throwtrash/usecase/user_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository implements UserRepositoryInterface {
  static const String USER_ID_KEY = 'USER_ID';
  static const String DEVICE_TOKEN_KEY = 'DEVICE_TOKEN';

  @override
  Future<String> readUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString(USER_ID_KEY);
    return userId != null ? userId : '';
  }

  @override
  Future<bool> writeUserId(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(USER_ID_KEY, userId);
  }

  @override
  Future<String> readDeviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceToken = preferences.getString(DEVICE_TOKEN_KEY);
    return deviceToken != null ? deviceToken : '';
  }

  @override
  Future<bool> writeDeviceToken(String deviceToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(DEVICE_TOKEN_KEY, deviceToken);
  }
  
}