import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';

enum AlarmSubmitState {
  INIT,
  SUBMITTING,
  COMPLETE,
  ERROR
}
class AlarmModel extends ChangeNotifier {
  bool _lastAlarmState = false;
  bool _isAlarmEnabled = false;
  int _hour = 0;
  int _minute = 0;
  AlarmSubmitState _submitState = AlarmSubmitState.INIT;
  final AlarmServiceInterface _alarmService;
  final _logger = Logger();

  AlarmModel(this._alarmService);

  Future<void> initialize() async {
    _alarmService.getAlarm().then((alarm) {
      _isAlarmEnabled = alarm.isEnable;
      _lastAlarmState = alarm.isEnable;
      _hour = alarm.hour;
      _minute = alarm.minute;
      _logger.d("initialize alarm-> $_hour:$_minute, enable:$_isAlarmEnabled");
      notifyListeners();
    });
  }

  bool get isAlarmEnabled => _isAlarmEnabled;
  int get hour => _hour;
  int get minute => _minute;
  AlarmSubmitState get submitState => _submitState;

  void toggleAlarmEnabled() {
    _isAlarmEnabled = !_isAlarmEnabled;
    notifyListeners();
    _logger.d("toggle alarm-> $_isAlarmEnabled");
  }

  void setAlarmTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;
    notifyListeners();
    _logger.d("set alarm time-> $_hour:$_minute");
  }

  Future<void> submitAlarmTime() async {
    _logger.d("submit alarm time-> $_hour:$_minute");
    if(_submitState == AlarmSubmitState.SUBMITTING) {
      return;
    }
    _submitState = AlarmSubmitState.SUBMITTING;
    notifyListeners();

    bool result = false;
    if(isAlarmEnabled && ! _lastAlarmState) {
      result = await _alarmService.enableAlarm(hour: hour, minute: minute);
    } else if(!isAlarmEnabled) {
      result = await _alarmService.cancelAlarm();
    } else if(isAlarmEnabled && _lastAlarmState){
      result = await _alarmService.changeAlarmTime(hour: hour, minute: minute);
    }
    _submitState = result ? AlarmSubmitState.COMPLETE : AlarmSubmitState.ERROR;
    notifyListeners();

    // 保存に成功したら最後の状態を更新
    if(result) {
      _lastAlarmState = isAlarmEnabled;
    }
    _submitState = AlarmSubmitState.INIT;
  }
}