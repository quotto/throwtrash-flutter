import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm.dart';
import '../usecase/repository/alarm_repository_interface.dart';

class AlarmRepository implements AlarmRepositoryInterface {
  static const ALARM_HOUR_KEY = 'ALARM_HOUR';
  static const ALARM_MINUTE_KEY = 'ALARM_MINUTE';
  static const ALARM_ENABLED_KEY = 'ALARM_ENABLED';
  final _logger = Logger();
  final SharedPreferences _preferences;
  static AlarmRepository? _instance;

  AlarmRepository._(this._preferences);

  static void initialize(SharedPreferences preferences) {
    if(_instance != null) throw StateError('AlarmRepositoryは既に初期化されています');
    _instance = AlarmRepository._(preferences);
  }
  factory AlarmRepository() {
    if(_instance == null) {
      throw StateError('AlarmRepositoryが初期化されていません');
    }
    return _instance!;
  }

  @override
  Future<Alarm?> readAlarm() async {
    int? hour = _preferences.getInt(ALARM_HOUR_KEY);
    int? minute = _preferences.getInt(ALARM_MINUTE_KEY);
    bool? enabled = _preferences.getBool(ALARM_ENABLED_KEY);

    if(hour != null && minute != null && enabled != null) {
      return Alarm(hour, minute, enabled);
    } else {
      return null;
    }
  }

  @override
  Future<bool> saveAlarm(Alarm alarm) async {
    try {
      return await _preferences.setInt(ALARM_HOUR_KEY, alarm.hour) &&
          await _preferences.setInt(ALARM_MINUTE_KEY, alarm.minute) &&
          await _preferences.setBool(ALARM_ENABLED_KEY, alarm.isEnable);
    } catch(error) {
      _logger.e("アラームデータの保存に失敗しました: $error");
      return false;
    }
  }
}