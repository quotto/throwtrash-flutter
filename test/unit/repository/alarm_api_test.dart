import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/repository/alarm_api.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

import 'alarm_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<AppConfigProviderInterface>(), MockSpec<EnvironmentProviderInterface>()])
void main() {
  late final AlarmApi alarmApi;
  MockClient httpClient = MockClient();
  MockAppConfigProviderInterface appConfigProvider = MockAppConfigProviderInterface();
  MockEnvironmentProviderInterface environmentProvider = MockEnvironmentProviderInterface();
  setUpAll(() {
    when(appConfigProvider.alarmApiUrl).thenReturn("https://example.com");
    when(environmentProvider.alarmApiKey).thenReturn("test_key");
    AlarmApi.initialize(appConfigProvider, environmentProvider,httpClient);
    alarmApi = AlarmApi();
  });
  group("setAlarm", () {
    test("setAlarmでアラーム情報が更新されること", () async {
      final testAlarm = Alarm(12, 30, true);
      when(httpClient.post(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenAnswer((_) async {
        return Response('{"hour": 12, "minute": 30, "isEnable": true}', 200, headers: {"Content-Type": "application/json"}, request: http.Request("POST", Uri.parse("https://example.com/create")));
      });

      User user = User("test_id");
      bool result = await alarmApi.setAlarm(testAlarm, "test_token", user);
      expect(result, true);
      final captured = verify(httpClient.post(captureAny, body: captureAnyNamed("body"), headers: captureAnyNamed("headers"))).captured;
      expect(captured[0], Uri.parse("https://example.com/create"));
      expect(captured[1], jsonEncode({
        "device_token": "test_token",
        "alarm_time": {
          "hour": 12,
          "minute": 30
        },
        "user_id": "test_id",
        "platform": "ios"
      }));
      expect(captured[2], {
        "Content-Type": "application/json",
        "X-API-KEY": "test_key"
      });
    });
    test("setAlarmでエラーが発生した場合はfalseが返ること", () async {
      when(httpClient.post(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenAnswer((_) async {
        return Response('{"error": "error"}', 500, headers: {"Content-Type": "application/json"}, request: http.Request("POST", Uri.parse("https://example.com/create")));
      });

      User user = User("test_id");
      bool result = await alarmApi.setAlarm(Alarm(12, 30, true), "test_token", user);
      expect(result, false);
    });
    test("setAlarm内で例外が発生した場合はExceptionがthrowされること", () async {
      when(httpClient.post(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenThrow(Exception());

      User user = User("test_id");
      expect(alarmApi.setAlarm(Alarm(12, 30, true), "test_token", user), throwsException);
    });
  });
  group("cancelAlarm",() {
    test("cancelAlarmでアラーム情報が削除されること", () async {
      when(httpClient.delete(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenAnswer((_) async {
        return Response('{"result": "success"}', 200, headers: {"Content-Type": "application/json"}, request: http.Request("DELETE", Uri.parse("https://example.com/delete")));
      });

      bool result = await alarmApi.cancelAlarm("device_token");
      expect(result, true);
      final captured = verify(httpClient.delete(captureAny, body: captureAnyNamed("body"),headers: captureAnyNamed("headers"))).captured;
      expect(captured[0], Uri.parse("https://example.com/delete"));
      expect(captured[1], jsonEncode({
      "device_token": "device_token"
      }));
      expect(captured[2], {
        "Content-Type": "application/json",
        "X-API-KEY": "test_key"
      });
    });
    test("cancelAlarmでエラーが発生した場合はfalseが返ること", () async {
      when(httpClient.delete(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenAnswer((_) async {
        return Response('{"error": "error"}', 500, headers: {"Content-Type": "application/json"}, request: http.Request("DELETE", Uri.parse("https://example.com/delete")));
      });

      bool result = await alarmApi.cancelAlarm("device_token");
      expect(result, false);
    });
    test("cancelAlarm内で例外が発生した場合はExceptionがthrowされること", () async {
      when(httpClient.delete(any, body: anyNamed("body"), headers: anyNamed("headers"))).thenThrow(Exception());

      expect(alarmApi.cancelAlarm("device_token"), throwsException);
    });
    group("initialize", () {
      test("initializeが繰り返し呼ばれた場合はエラーが発生すること", () async {
        expect(() => AlarmApi.initialize(appConfigProvider, environmentProvider, httpClient), throwsStateError);
      });
    });
  });
}