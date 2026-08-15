import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/calendar_model.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';

import 'trash_data_service_test.mocks.dart';

void main() {
  late MockCrashReportInterface crashReport;
  late MockTrashRepositoryInterface trashRepository;
  late MockTrashApiInterface trashApi;
  late MockUserServiceInterface userService;
  final localTrash = TrashData(
    id: 'trash-1',
    type: 'other',
    trashVal: 'あいうえおかきくけこさしすせそたちつてと',
    schedules: [TrashSchedule('weekday', '0')],
    excludes: [],
  );

  setUp(() {
    crashReport = MockCrashReportInterface();
    trashRepository = MockTrashRepositoryInterface();
    trashApi = MockTrashApiInterface();
    userService = MockUserServiceInterface();

    when(userService.user).thenReturn(User('user-1'));
    when(trashRepository.readAllTrashData())
        .thenAnswer((_) async => [localTrash]);
    when(trashRepository.readGlobalExcludeDates())
        .thenAnswer((_) async => []);
    when(trashRepository.getLastUpdateTime()).thenAnswer((_) async => 100);
    when(trashRepository.getSyncStatus())
        .thenAnswer((_) async => SyncStatus.SYNCING);
    when(trashRepository.setSyncStatus(any)).thenAnswer((_) async => true);
    when(trashRepository.updateLastUpdateTime(any))
        .thenAnswer((_) async => true);
    when(trashRepository.truncateAllTrashData()).thenAnswer((_) async => true);
    when(trashRepository.writeGlobalExcludeDates(any))
        .thenAnswer((_) async => true);
    when(trashRepository.insertTrashData(any)).thenAnswer((_) async => true);
  });

  test('20文字のその他ゴミ名が同期更新APIを通って成功する', () async {
    when(trashApi.syncTrashData('user-1')).thenAnswer(
      (_) async => TrashSyncResult(
        [localTrash],
        [],
        100,
        TrashApiSyncStatus.SUCCESS,
      ),
    );
    when(trashApi.updateTrashData(any, any, any, any)).thenAnswer(
      (_) async => TrashUpdateResult(200, UpdateResult.SUCCESS),
    );

    final service = TrashDataService(
      userService,
      trashRepository,
      trashApi,
      crashReport,
    );
    final result = await service.syncTrashData();

    expect(result, SyncResult.success);
    final captured = verify(
      trashApi.updateTrashData('user-1', captureAny, captureAny, 100),
    ).captured;
    final updatedTrash = (captured[0] as List<TrashData>).single;
    expect(updatedTrash.trashVal.length, 20);
    expect(updatedTrash.trashVal, localTrash.trashVal);
    verify(trashRepository.updateLastUpdateTime(200)).called(1);
    verify(trashRepository.setSyncStatus(SyncStatus.COMPLETE)).called(1);
  });

  test('同期競合時はrollbackとなりリモートデータをローカルへ反映する', () async {
    when(trashApi.syncTrashData('user-1')).thenAnswer(
      (_) async => TrashSyncResult(
        [localTrash],
        [],
        100,
        TrashApiSyncStatus.SUCCESS,
      ),
    );
    when(trashApi.updateTrashData(any, any, any, any)).thenAnswer(
      (_) async => TrashUpdateResult(-1, UpdateResult.NO_MATCH),
    );

    final service = TrashDataService(
      userService,
      trashRepository,
      trashApi,
      crashReport,
    );

    final result = await service.syncTrashData();

    expect(result, SyncResult.rollback);
    verify(trashRepository.truncateAllTrashData()).called(1);
    verify(trashRepository.setSyncStatus(SyncStatus.COMPLETE)).called(1);
    verifyNever(crashReport.reportCrash(any, fatal: true));
  });

  test('同期更新の不測のエラー時はfailedとなり競合処理を行わない', () async {
    when(trashApi.syncTrashData('user-1')).thenAnswer(
      (_) async => TrashSyncResult(
        [localTrash],
        [],
        100,
        TrashApiSyncStatus.SUCCESS,
      ),
    );
    when(trashApi.updateTrashData(any, any, any, any)).thenAnswer(
      (_) async => TrashUpdateResult(-1, UpdateResult.ERROR),
    );

    final service = TrashDataService(
      userService,
      trashRepository,
      trashApi,
      crashReport,
    );

    final result = await service.syncTrashData();

    expect(result, SyncResult.failed);
    verify(crashReport.reportCrash(any, fatal: true)).called(1);
    verifyNever(trashRepository.truncateAllTrashData());
    verifyNever(trashRepository.setSyncStatus(SyncStatus.COMPLETE));
  });
}
