import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/repository/user_repository_interface.dart';

class UserService extends UserServiceInterface {
  User _user = User('', '');
  final UserRepositoryInterface _userRepository;

  UserService(
      this._userRepository,
  );

  @override
  User get user => _user;

  @override
  Future<void> refreshUser() async {
    String id = await _userRepository.readUserId();
    String deviceToken = await _userRepository.readDeviceToken();
    _user = User(id, deviceToken);
  }

  @override
  Future<bool> registerUser(String id) async {
    if(await _userRepository.writeUserId(id)) {
      await refreshUser();
      return true;
    }
    return false;
  }
}