abstract class ShareServiceInterface {
  Future<String> getActivationCode();
  Future<bool> importSchedule(String activationCode);
}