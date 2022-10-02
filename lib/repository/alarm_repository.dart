import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/repository/alarm_repository_interface.dart';

class AlarmRepository implements AlarmRepositoryInterface {
  static const String ALARM_KEY = 'ALARM_KEY';
  @override
  Future<Alarm?> getAlarm() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? alarmString = sharedPreferences.getString(ALARM_KEY);
    print('Read Alarm Setting: $alarmString');
    if(alarmString != null) {
      return Alarm.fromJson(jsonDecode(alarmString));
    }
    return null;
  }

  @override
  Future<bool> setAlarm(Alarm alarm) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(ALARM_KEY, jsonEncode(alarm.toJson()));
  }

}