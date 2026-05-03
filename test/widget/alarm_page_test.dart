import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/alarm.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';

class FakeAlarmService implements AlarmServiceInterface {
  Alarm alarm = Alarm(7, 30, true, false);
  int changeAlarmCallCount = 0;
  bool lastNextDayNotificationEnabled = false;

  @override
  Future<bool> cancelAlarm({bool? nextDayNotificationEnabled}) async {
    alarm = alarm.changeEnable(false).changeNextDayNotificationEnabled(nextDayNotificationEnabled ?? false);
    return true;
  }

  @override
  Future<bool> changeAlarmTime({
    required int hour,
    required int minute,
    required bool nextDayNotificationEnabled,
  }) async {
    changeAlarmCallCount++;
    lastNextDayNotificationEnabled = nextDayNotificationEnabled;
    alarm = Alarm(hour, minute, true, nextDayNotificationEnabled);
    return true;
  }

  @override
  Future<bool> enableAlarm({
    required int hour,
    required int minute,
    required bool nextDayNotificationEnabled,
  }) async {
    alarm = Alarm(hour, minute, true, nextDayNotificationEnabled);
    return true;
  }

  @override
  Future<Alarm> getAlarm() async => alarm;

  @override
  Future<void> reRegisterAlarm() async {}
}

void main() {
  testWidgets('通知設定画面に翌日のゴミ出し通知トグルが表示される', (tester) async {
    final service = FakeAlarmService();

    await tester.pumpWidget(
      Provider<AlarmServiceInterface>.value(
        value: service,
        child: MaterialApp(home: AlarmPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('翌日のゴミ出しを通知する'), findsOneWidget);
  });

  testWidgets('翌日通知トグルを変更して設定するとServiceへ反映される', (tester) async {
    final service = FakeAlarmService();

    await tester.pumpWidget(
      Provider<AlarmServiceInterface>.value(
        value: service,
        child: MaterialApp(home: AlarmPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('翌日のゴミ出しを通知する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    expect(service.changeAlarmCallCount, 1);
    expect(service.lastNextDayNotificationEnabled, true);
  });
}
