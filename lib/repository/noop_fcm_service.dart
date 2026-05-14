import 'package:throwtrash/usecase/repository/fcm_interface.dart';

class NoopFcmService implements FcmInterface {
  const NoopFcmService();

  @override
  Future<String> refreshDeviceToken() async => '';

  @override
  Future<void> showLocalNotification(String title, String body) async {}
}
