import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:throwtrash/repository/alarm_repository_interface.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';

enum AlarmState {
  EDIT,
  DISABLED,
  PROCESSING,
  COMPLETE,
  FAILED
}

class AlarmModel extends ChangeNotifier {
  Alarm _alarm = Alarm(false,false,7,0);
  AlarmState _state = AlarmState.EDIT;
  String _alarmTime = "07:00";

  final AlarmRepositoryInterface _alarmRepositoryInterface;
  final AlarmServiceInterface _alarmService;

  AlarmModel(this._alarmRepositoryInterface, this._alarmService) {
    _state = _alarmService.isEnabledToUseAlarm() ? AlarmState.EDIT : AlarmState.DISABLED;
    _alarmRepositoryInterface.getAlarm().then((alarm) {
      if(alarm != null) {
        _alarm = alarm;
        changeTime(TimeOfDay(hour: _alarm.hour, minute: _alarm.minute));
      }
    });
  }

  Alarm get alarm => _alarm;
  AlarmState get state => _state;
  String get alarmTime => _alarmTime;

  void changeEnabled(bool enabled) {
    _alarm.enabled = enabled;
    notifyListeners();
  }

  void changeEverydayFlag(bool everydayFlag) {
    _alarm.everydayFlg = everydayFlag;
    notifyListeners();
  }

  void changeTime(TimeOfDay timeOfDay) {
    _alarm.hour = timeOfDay.hour;
    _alarm.minute = timeOfDay.minute;
    _alarmTime = '${_alarm.hour < 10 ? '0${_alarm.hour}' : _alarm.hour}:'
        '${_alarm.minute < 10 ? '0${_alarm.minute}' : _alarm.minute}';
    notifyListeners();
  }

  Future<bool> setAlarm() {
    _state = AlarmState.PROCESSING;
    return _alarmService.setAlarm(_alarm).then((result){
      _state = result ? AlarmState.COMPLETE : AlarmState.FAILED;
      return result;
    });
  }
}