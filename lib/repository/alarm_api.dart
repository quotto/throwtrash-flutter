import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/repository/alarm_api_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

import '../models/alarm.dart';
import '../models/user.dart';

class AlarmApi implements AlarmApiInterface {
  final Logger _logger = Logger();
  final AppConfigProviderInterface _configProvider;
  final EnvironmentProviderInterface _environmentProvider;
  final http.Client _httpClient;

  late final String _alarmApiUrl;
  late final String _alarmApiKey;

  static AlarmApi? _instance;

  AlarmApi._(this._configProvider, this._environmentProvider, this._httpClient) {
    this._alarmApiUrl = this._configProvider.alarmApiUrl;
    this._alarmApiKey = this._environmentProvider.alarmApiKey;
  }

  static initialize(AppConfigProviderInterface configProvider, EnvironmentProviderInterface environmentProvider,http.Client httpClient) {
    if(_instance != null) {
      throw StateError("AlarmApi is already initialized");
    }
    _instance = AlarmApi._(configProvider, environmentProvider,httpClient);
  }

  factory AlarmApi() {
    if(_instance == null) {
      throw StateError("AlarmApi is not initialized");
    }
    return _instance!;
  }

  @override
  Future<bool> setAlarm(Alarm alarm, String deviceToken ,User user) async {
    Uri endpointUri = Uri.parse("${this._alarmApiUrl}/create");
    try {
      http.Response response = await this._httpClient.post(
          endpointUri,
          body: jsonEncode({
            "device_token": deviceToken,
            "alarm_time": {
              "hour": alarm.hour,
              "minute": alarm.minute
            },
            "user_id": user.id,
            "platform": "ios"
          }),
          headers: {
            "Content-Type": "application/json",
            "X-API-KEY": this._alarmApiKey
          }
      );

      _logger.d(response.request?.headers.toString());
      _logger.d(response.request.toString());
      if(response.statusCode == 200) {
        return true;
      } else {
        _logger.e("アラームの設定でエラーが発生しました: ${response.statusCode},${response.body.toString()}");
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      throw e;
    }
  }

  @override
  Future<bool> cancelAlarm(deviceToken) async {
    Uri endpointUri = Uri.parse("${this._alarmApiUrl}/delete");
    try {
      http.Response response = await this._httpClient.delete(
          endpointUri,
          body: jsonEncode({
            "device_token": deviceToken
          }),
          headers: {
            "Content-Type": "application/json",
            "X-API-KEY": this._alarmApiKey
          }
      );

      _logger.d(response.request?.headers.toString());
      _logger.d(response.request.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.e("アラームの削除でエラーが発生しました: ${response.statusCode},${response.body.toString()}");
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      throw e;
    }
  }

  @override
  Future<bool> changeAlarm(Alarm alarm, String deviceToken) async {
    Uri endpointUri = Uri.parse("${this._alarmApiUrl}/update");

    try {
      http.Response response = await this._httpClient.put(
          endpointUri,
          body: jsonEncode({
            "device_token": deviceToken,
            "alarm_time": {
              "hour": alarm.hour,
              "minute": alarm.minute
            }
          }),
          headers: {
            "Content-Type": "application/json",
            "X-API-KEY": this._alarmApiKey
          }
      );

      _logger.d(response.request?.headers.toString());
      _logger.d(response.request.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.e("アラームの更新でエラーが発生しました: ${response.statusCode},${response.body.toString()}");
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      throw e;
    }
  }
}