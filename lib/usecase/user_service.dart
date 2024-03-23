import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/usecase/user_repository_interface.dart';

class UserService extends UserServiceInterface {
  User _user = User('');
  final UserRepositoryInterface _userRepository;

  UserService(
      this._userRepository,
  );

  @override
  User get user => _user;

  @override
  Future<void> refreshUser() async {
    await _userRepository.readUser().then((value) {
      if(value != null) {
        _user = value;
      }
    });
  }

  @override
  Future<bool> registerUser(String id) async {
    User newUser = User(id);
    if(await _userRepository.writeUser(newUser)) {
      await refreshUser();
      return true;
    }
    return false;
  }
}