import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/repository/noop_crash_report.dart';
import 'package:throwtrash/repository/noop_fcm_service.dart';

void main() {
  test('NoopCrashReport は例外を投げずに破棄できる', () {
    final report = NoopCrashReport();

    expect(() => report.reportCrash(Exception('test')), returnsNormally);
  });

  test('NoopFcmService は空トークンを返し通知を無視できる', () async {
    const service = NoopFcmService();

    await expectLater(service.refreshDeviceToken(), completion(''));
    await expectLater(
      service.showLocalNotification('title', 'body'),
      completes,
    );
  });
}
