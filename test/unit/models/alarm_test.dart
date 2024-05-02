// Alarmクラスの単体テスト
import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/models/alarm.dart';

void main() {
  group('コンストラクタ', () {
    test('初期値', () {
      final alarm = Alarm(12, 34, false);
      expect(alarm.hour, 12);
      expect(alarm.minute, 34);
      expect(alarm.isEnable, false);
    });
    test('時間は0-23の範囲が有効であること', () {
      expect(() => Alarm(-1, 34, false), throwsArgumentError);
      expect(() => Alarm(24, 34, false), throwsArgumentError);
      Alarm alarm = Alarm(0, 34, false);
      expect(alarm.hour, 0);
      alarm = Alarm(23, 34, false);
      expect(alarm.hour, 23);
    });
    test('分は0-59の範囲が有効であること', () {
      expect(() => Alarm(12, -1, false), throwsArgumentError);
      expect(() => Alarm(12, 60, false), throwsArgumentError);
      Alarm alarm = Alarm(12, 0, false);
      expect(alarm.minute, 0);
      alarm = Alarm(12, 59, false);
      expect(alarm.minute, 59);
    });
  });
  group('changeEnable', () {
    test('無効から有効に変更', () {
      final alarm = Alarm(12, 34, false);
      final changedAlarm = alarm.changeEnable(true);
      expect(changedAlarm.isEnable, true);
    });
    test('有効から無効に変更', () {
      final alarm = Alarm(12, 34, true);
      final changedAlarm = alarm.changeEnable(false);
      expect(changedAlarm.isEnable, false);
    });
  });

  group('changeTime', () {
    test('時と分を変更', () {
      final alarm = Alarm(12, 34, false);
      final changedAlarm = alarm.changeTime(23, 45);
      expect(changedAlarm.hour, 23);
      expect(changedAlarm.minute, 45);
    });
    test('時だけを変更', () {
      final alarm = Alarm(12, 34, false);
      final changedAlarm = alarm.changeTime(23, 34);
      expect(changedAlarm.hour, 23);
      expect(changedAlarm.minute, 34);
    });
    test('分だけを変更', () {
      final alarm = Alarm(12, 34, false);
      final changedAlarm = alarm.changeTime(12, 45);
      expect(changedAlarm.hour, 12);
      expect(changedAlarm.minute, 45);
    });
  });
}