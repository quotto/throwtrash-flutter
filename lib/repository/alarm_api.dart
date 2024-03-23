import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/repository/crashlytics_report.dart';
import 'package:throwtrash/usecase/alarm_api_interface.dart';

import '../models/alarm.dart';
import '../models/user.dart';

class AlarmApi implements AlarmApiInterface {
  final Logger _logger = Logger();
  final String _alarmApiUrl;
  final http.Client _httpClient;


  AlarmApi(this._alarmApiUrl, this._httpClient);

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
            "user_id": user.id
          }),
          headers: {
            "Content-Type": "application/json"
          }
      );

      if(response.statusCode == 200) {
        return true;
      } else {
        throw Exception("アラームの設定でエラーが発生しました: ${response.statusCode},${response.body.toString()}");
      }
    } catch (e, s) {
      _logger.e(e.toString());
      CrashlyticsReport().reportCrash(e, stackTrace: s, fatal: true);
      return false;
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
            "Content-Type": "application/json"
          }
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("アラームの削除でエラーが発生しました: ${response
            .statusCode},${response.body.toString()}");
      }
    } catch (e, s) {
      _logger.e(e.toString());
      CrashlyticsReport().reportCrash(e, stackTrace: s, fatal: true);
      return false;
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
            "Content-Type": "application/json"
          }
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("アラームの変更でエラーが発生しました: ${response
            .statusCode},${response.body.toString()}");
      }
    } catch (e, s) {
      _logger.e(e.toString());
      CrashlyticsReport().reportCrash(e, stackTrace: s, fatal: true);
      return false;
    }
  }
}