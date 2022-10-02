abstract class UserRepositoryInterface {
  Future<String> readUserId();
  Future<bool> writeUserId(String userId);
  Future<bool> writeDeviceToken(String deviceToken);
  Future<String> readDeviceToken();
}