import 'package:logger/logger.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/config_repository_interface.dart';
import 'package:throwtrash/usecase/user_repository_interface.dart';

import '../models/alarm.dart';
import 'alarm_api_interface.dart';
import 'alarm_repository_interface.dart';
import 'alarm_service_interface.dart';
import 'fcm_interface.dart';

class AlarmService implements AlarmServiceInterface {
  final AlarmRepositoryInterface _alarmRepository;
  final AlarmApiInterface _api;
  final ConfigRepositoryInterface _configRepository;
  final FcmInterface _fcm;
  final UserRepositoryInterface _userRepository;
  final Logger _logger = Logger();

  AlarmService(this._alarmRepository, this._api, this._configRepository, this._fcm, this._userRepository);

  @override
  Future<Alarm> getAlarm() async {
    Alarm? currentAlarm = await _alarmRepository.readAlarm();

    return currentAlarm == null  ? Alarm(0, 0, false) : currentAlarm;
  }

  @override
  Future<bool> changeAlarmTime({required int hour, required int minute}) async {
    final alarm = await _alarmRepository.readAlarm();
    if(alarm == null || !alarm.isEnable) {
      final errMessage = 'アラームが設定されていないか無効です。';
      _logger.e(errMessage);
      throw Exception(errMessage);
    }

    final newAlarm = Alarm(hour, minute, alarm.isEnable);
    final deviceToken = await _fcm.refreshDeviceToken();
    return await _api.changeAlarm(newAlarm, deviceToken).then((result) async {
        return result && await _alarmRepository.saveAlarm(newAlarm);
    });
  }

  @override
  Future<bool> cancelAlarm() async {
    // アラームのキャンセルはリモートに登録済みのデバイストークンに対するキャンセルであるため、
    // トークンのリフレッシュは行わずにローカルに保存済みのデバイストークンを取得する
    final deviceToken = await _configRepository.getDeviceToken();

    // リモート側の更新はローカルに登録済みのデバイストークンが存在する場合のみ実行する
    if(deviceToken != null) {
      _logger.e('リモートのアラームをキャンセルします');
      await _api.cancelAlarm(deviceToken);
    }

    final currentAlarm = await _alarmRepository.readAlarm();
    // アラームが設定されていない場合は成功として扱う
    if (currentAlarm == null) {
      _logger.w('アラームが設定されていないため処理を終了します');
      return true;
    }
    return await _alarmRepository.saveAlarm(currentAlarm.changeEnable(false));
  }

  @override
  Future<bool> enableAlarm({required int hour, required int minute}) async {
    User? user = await _userRepository.readUser();
    if(user == null) {
      throw Exception('ユーザー情報が取得できませんでした');
    }

    final deviceToken = await _fcm.refreshDeviceToken();

    final alarm = Alarm(hour, minute, true);
    return await _api.setAlarm(Alarm(hour, minute, true), deviceToken, user).then((result) async {
      return result && await _alarmRepository.saveAlarm(alarm);
    });
  }

  @override
  Future<void> refreshAlarmToken(String oldToken ,String newToken) async {
    User? user  = await _userRepository.readUser();
    if(user == null) {
      _logger.e('ユーザー情報が取得できませんでした');
      throw Exception('ユーザー情報が取得できませんでした');
    }

    Alarm? alarm = await _alarmRepository.readAlarm();
    if(alarm == null || !alarm.isEnable) {
      _logger.w('アラームは設定されていないか無効です');
      return;
    }

    if(oldToken != newToken) {
      _logger.i('デバイストークンが変更されました');
      _logger.i('古いデバイストークンのアラームをキャンセルします');
      await _api.cancelAlarm(oldToken);
      await _api.setAlarm(alarm, newToken, user);
    }
  }
}