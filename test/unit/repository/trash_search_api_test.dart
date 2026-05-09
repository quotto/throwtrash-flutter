import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';

import 'trash_api_test.mocks.dart';

class FakeTrashSearchEnvironment implements EnvironmentProviderInterface {
  @override
  String get alarmApiKey => '';

  @override
  String get flavor => 'development';

  @override
  String get trashSearchApiEndpoint => 'https://search.example.com';

  @override
  String get trashSearchApiKey => 'search-api-key';
}

void main() {
  group('searchTrashSchedule', () {
    late MockAppConfigProviderInterface appConfigProvider;
    late MockClient httpClient;
    late TrashApi trashApi;

    setUp(() {
      appConfigProvider = MockAppConfigProviderInterface();
      httpClient = MockClient();
      when(
        appConfigProvider.mobileApiUrl,
      ).thenReturn('https://mobile.example.com');
      trashApi = TrashApi.createForTest(
        appConfigProvider,
        httpClient,
        FakeTrashSearchEnvironment(),
      );
    });

    test('郵便番号で検索 API を呼び出して TrashData に変換する', () async {
      when(
        httpClient.post(
          any,
          body: anyNamed('body'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => Response.bytes(
          utf8.encode(
            jsonEncode({
              'trashes': [
                {
                  'type': 'burn',
                  'schedule': [
                    {'type': 'weekday', 'value': '2'},
                  ],
                },
                {
                  'type': 'other',
                  'trash_name': '蛍光灯',
                  'schedule': [
                    {'type': 'month', 'value': 5},
                  ],
                },
              ],
              'error_type': '',
            }),
          ),
          200,
        ),
      );

      final result = await trashApi.searchTrashSchedule(
        '160-0023',
        TrashSearchInputType.postalCode,
      );

      expect(result.success, isTrue);
      expect(result.trashes, hasLength(2));
      expect(result.trashes[0].type, 'burn');
      expect(result.trashes[0].schedules[0].type, 'weekday');
      expect(result.trashes[0].schedules[0].value, '2');
      expect(result.trashes[1].type, 'other');
      expect(result.trashes[1].trashVal, '蛍光灯');
      expect(result.trashes[1].schedules[0].value, '5');

      final captured = verify(
        httpClient.post(
          captureAny,
          body: captureAnyNamed('body'),
          headers: captureAnyNamed('headers'),
        ),
      ).captured;
      expect(captured[0], Uri.parse('https://search.example.com/search'));
      expect(captured[1], jsonEncode({'postal_code': '160-0023'}));
      expect(captured[2], {
        'content-type': 'application/json;charset=utf-8',
        'Accept': 'application/json',
        'x-api-key': 'search-api-key',
      });
    });

    test('unsupported スケジュールは保存対象から除外する', () async {
      when(
        httpClient.post(
          any,
          body: anyNamed('body'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => Response.bytes(
          utf8.encode(
            jsonEncode({
              'trashes': [
                {
                  'type': 'burn',
                  'schedule': [
                    {'type': 'unsupported', 'value': '毎月第5週'},
                  ],
                },
                {
                  'type': 'resource',
                  'schedule': [
                    {'type': 'biweek', 'value': '1-2'},
                  ],
                },
              ],
              'message': '一部のゴミ出し予定に対応していないため、対応可能な予定のみ返しています。',
              'error_type': 'unsupported_schedule',
            }),
          ),
          200,
        ),
      );

      final result = await trashApi.searchTrashSchedule(
        '東京都新宿区西新宿2丁目',
        TrashSearchInputType.address,
      );

      expect(result.success, isTrue);
      expect(result.trashes, hasLength(1));
      expect(result.trashes.single.type, 'resource');
    });

    test('エラーレスポンスは失敗結果に変換する', () async {
      when(
        httpClient.post(
          any,
          body: anyNamed('body'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => Response.bytes(
          utf8.encode(
            jsonEncode({
              'trashes': [],
              'message': '住所または郵便番号を指定してください。',
              'error_type': 'unknown',
            }),
          ),
          400,
        ),
      );

      final result = await trashApi.searchTrashSchedule(
        '',
        TrashSearchInputType.address,
      );

      expect(result.success, isFalse);
      expect(result.message, '住所または郵便番号を指定してください。');
    });

    test('Gateway 認証エラーはユーザー向けメッセージに変換する', () async {
      when(
        httpClient.post(
          any,
          body: anyNamed('body'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => Response.bytes(
          utf8.encode(jsonEncode({'message': 'Forbidden'})),
          403,
        ),
      );

      final result = await trashApi.searchTrashSchedule(
        '160-0023',
        TrashSearchInputType.postalCode,
      );

      expect(result.success, isFalse);
      expect(result.message, '自動取り込み API の認証に失敗しました。');
    });

    test('通信例外は失敗結果に変換する', () async {
      when(
        httpClient.post(
          any,
          body: anyNamed('body'),
          headers: anyNamed('headers'),
        ),
      ).thenThrow(Exception('network error'));

      final result = await trashApi.searchTrashSchedule(
        '160-0023',
        TrashSearchInputType.postalCode,
      );

      expect(result.success, isFalse);
      expect(result.message, '自動取り込みに失敗しました。');
    });
  });
}
