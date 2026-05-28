import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/calendar_model.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_import_message.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/models/trash_search_result.dart';
import 'package:throwtrash/usecase/repository/fcm_interface.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';

import 'trash_data_service_test.mocks.dart';

class FakeFcmService implements FcmInterface {
  int refreshTokenCount = 0;

  @override
  Future<String> refreshDeviceToken() async {
    refreshTokenCount++;
    return 'fcm-token';
  }
}

class FailingFcmService implements FcmInterface {
  @override
  Future<String> refreshDeviceToken() async {
    throw Exception('token error');
  }
}

void main() {
  group('AI取り込み', () {
    late MockCrashReportInterface crashReport;
    late MockTrashRepositoryInterface trashRepository;
    late MockTrashApiInterface trashApi;
    late MockUserServiceInterface userService;
    late FakeFcmService fcmService;
    late TrashDataService service;

    setUp(() {
      crashReport = MockCrashReportInterface();
      trashRepository = MockTrashRepositoryInterface();
      trashApi = MockTrashApiInterface();
      userService = MockUserServiceInterface();
      fcmService = FakeFcmService();
      when(trashRepository.readAllTrashData()).thenAnswer((_) async => []);
      when(
        trashRepository.readGlobalExcludeDates(),
      ).thenAnswer((_) async => []);
      when(
        trashRepository.replaceAllTrashData(any),
      ).thenAnswer((_) async => true);
      when(
        trashRepository.setSyncStatus(SyncStatus.SYNCING),
      ).thenAnswer((_) async => true);
      service = TrashDataService(
        userService,
        trashRepository,
        trashApi,
        crashReport,
        fcmService,
      );
    });

    test('郵便番号はハイフン有無どちらも郵便番号として判定する', () {
      expect(
        service.classifySearchInput('160-0023'),
        TrashSearchInputType.postalCode,
      );
      expect(
        service.classifySearchInput('1600023'),
        TrashSearchInputType.postalCode,
      );
      expect(
        service.classifySearchInput('東京都新宿区西新宿2丁目'),
        TrashSearchInputType.address,
      );
    });

    test('成功時は既存データを置き換えて同期待ちにする', () async {
      when(
        trashApi.searchTrashSchedule(
          '160-0023',
          TrashSearchInputType.postalCode,
          fcmToken: 'fcm-token',
        ),
      ).thenAnswer(
        (_) async => TrashSearchResult.success([
          TrashData(
            id: '',
            type: 'burn',
            schedules: [TrashSchedule('weekday', '2')],
          ),
          TrashData(
            id: '',
            type: 'other',
            trashVal: '蛍光灯',
            schedules: [TrashSchedule('month', '5')],
          ),
        ]),
      );

      final result = await service.importTrashSchedule('160-0023');

      expect(result.success, isTrue);
      expect(result.message, 'ゴミ出し予定を取り込みました');
      verify(
        trashRepository.replaceAllTrashData(
          argThat(
            isA<List<TrashData>>().having((value) => value.length, 'length', 2),
          ),
        ),
      ).called(1);
      verify(trashRepository.setSyncStatus(SyncStatus.SYNCING)).called(1);
      expect(fcmService.refreshTokenCount, 1);
      verify(
        trashRepository.saveImportMessage(
          argThat(
            isA<TrashImportMessage>()
                .having((value) => value.message, 'message', 'ゴミ出し予定を取り込みました')
                .having((value) => value.isSuccess, 'isSuccess', isTrue),
          ),
        ),
      ).called(1);
    });

    test('エラー時は既存データを削除しない', () async {
      when(
        trashApi.searchTrashSchedule(
          '東京都新宿区',
          TrashSearchInputType.address,
          fcmToken: 'fcm-token',
        ),
      ).thenAnswer(
        (_) async =>
            TrashSearchResult.failure('指定された住所に対応するゴミ出し予定を特定できませんでした。'),
      );

      final result = await service.importTrashSchedule('東京都新宿区');

      expect(result.success, isFalse);
      verifyNever(trashRepository.replaceAllTrashData(any));
      expect(fcmService.refreshTokenCount, 1);
      verify(
        trashRepository.saveImportMessage(
          argThat(
            isA<TrashImportMessage>()
                .having(
                  (value) => value.message,
                  'message',
                  '指定された住所に対応するゴミ出し予定を特定できませんでした。',
                )
                .having((value) => value.isSuccess, 'isSuccess', isFalse),
          ),
        ),
      ).called(1);
    });

    test('一部未対応の予定がある場合は保存後に注意メッセージを残す', () async {
      when(
        trashApi.searchTrashSchedule(
          '160-0023',
          TrashSearchInputType.postalCode,
          fcmToken: 'fcm-token',
        ),
      ).thenAnswer(
        (_) async => TrashSearchResult.success([
          TrashData(
            id: '',
            type: 'burn',
            schedules: [TrashSchedule('weekday', '2')],
          ),
        ], message: '一部のゴミ出し予定を取り込めませんでした。取り込めなかった内容は手動で確認してください。'),
      );

      final result = await service.importTrashSchedule('160-0023');

      expect(result.success, isTrue);
      expect(result.message, '一部のゴミ出し予定を取り込めませんでした。取り込めなかった内容は手動で確認してください。');
      verify(trashRepository.replaceAllTrashData(any)).called(1);
      verify(
        trashRepository.saveImportMessage(
          argThat(
            isA<TrashImportMessage>()
                .having(
                  (value) => value.message,
                  'message',
                  '一部のゴミ出し予定を取り込めませんでした。取り込めなかった内容は手動で確認してください。',
                )
                .having((value) => value.isSuccess, 'isSuccess', isTrue),
          ),
        ),
      ).called(1);
    });

    test('保存失敗時は同期状態を変更しない', () async {
      when(
        trashRepository.replaceAllTrashData(any),
      ).thenAnswer((_) async => false);
      when(
        trashApi.searchTrashSchedule(
          '160-0023',
          TrashSearchInputType.postalCode,
          fcmToken: 'fcm-token',
        ),
      ).thenAnswer(
        (_) async => TrashSearchResult.success([
          TrashData(
            id: '',
            type: 'burn',
            schedules: [TrashSchedule('weekday', '2')],
          ),
        ]),
      );

      final result = await service.importTrashSchedule('160-0023');

      expect(result.success, isFalse);
      verifyNever(trashRepository.setSyncStatus(SyncStatus.SYNCING));
      verify(
        trashRepository.saveImportMessage(
          argThat(
            isA<TrashImportMessage>()
                .having(
                  (value) => value.message,
                  'message',
                  'AI取り込み結果の保存に失敗しました。',
                )
                .having((value) => value.isSuccess, 'isSuccess', isFalse),
          ),
        ),
      ).called(1);
    });

    test('通知用トークンを取得できない場合はAPIを呼ばない', () async {
      final tokenFailureService = TrashDataService(
        userService,
        trashRepository,
        trashApi,
        crashReport,
        FailingFcmService(),
      );

      final result = await tokenFailureService.importTrashSchedule('160-0023');

      expect(result.success, isFalse);
      expect(result.message, '通知用トークンの取得に失敗しました。時間をおいて再度お試しください。');
      verifyNever(
        trashApi.searchTrashSchedule(any, any, fcmToken: anyNamed('fcmToken')),
      );
      verifyNever(trashRepository.replaceAllTrashData(any));
      verify(
        trashRepository.saveImportMessage(
          argThat(
            isA<TrashImportMessage>()
                .having(
                  (value) => value.message,
                  'message',
                  '通知用トークンの取得に失敗しました。時間をおいて再度お試しください。',
                )
                .having((value) => value.isSuccess, 'isSuccess', isFalse),
          ),
        ),
      ).called(1);
    });

    test('初回ダイアログ状態と取り込みメッセージを扱える', () async {
      when(
        trashRepository.shouldShowInitialSearchDialog(),
      ).thenAnswer((_) async => true);
      when(
        trashRepository.markInitialSearchDialogShown(),
      ).thenAnswer((_) async => true);
      when(
        trashRepository.consumeImportMessage(),
      ).thenAnswer((_) async => TrashImportMessage.success('完了しました'));

      expect(await service.shouldShowInitialSearchDialog(), isTrue);
      expect(await service.markInitialSearchDialogShown(), isTrue);
      final message = await service.consumeImportMessage();
      expect(message?.message, '完了しました');
      expect(message?.isSuccess, isTrue);
    });
  });
}
