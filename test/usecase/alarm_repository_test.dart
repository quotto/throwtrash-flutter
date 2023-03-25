import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/repository/alarm_repository.dart';

AlarmRepository _repository = AlarmRepository();
void main() {
  setUp((){
    SharedPreferences.setMockInitialValues({});
  });

  group('setAlarm & getAlarm', (){
    test('登録が無い状態', () async {
      Alarm alarm = Alarm(true, true, 7, 8);
      bool result = await _repository.setAlarm(alarm);
      expect(result, true);

      Alarm? actual = await _repository.getAlarm();
      expect(actual != null, true);
      expect(actual!.enabled, alarm.enabled);
      expect(actual.everydayFlg, alarm.everydayFlg);
      expect(actual.hour, alarm.hour);
      expect(actual.minute, alarm.minute);
    });
    test('登録がある状態の更新', () async {
      Alarm alarm = Alarm(true, false, 7, 8);
      await _repository.setAlarm(alarm);

      Alarm alarm2 = Alarm(true, true, 0, 0);
      await _repository.setAlarm(alarm2);

      Alarm? actual = await _repository.getAlarm();
      expect(actual != null, true);
      expect(actual!.enabled, alarm2.enabled);
      expect(actual.everydayFlg, alarm2.everydayFlg);
      expect(actual.hour, alarm2.hour);
      expect(actual.minute, alarm2.minute);
    });
  });
}