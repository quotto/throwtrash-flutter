abstract class FcmInterface {
  Future<String> refreshDeviceToken();
  Future<void> showLocalNotification(String title, String body);
}
