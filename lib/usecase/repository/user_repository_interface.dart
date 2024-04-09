import '../../models/user.dart';

abstract class UserRepositoryInterface {
  Future<User?> readUser();
  Future<bool> writeUser(User user);
}