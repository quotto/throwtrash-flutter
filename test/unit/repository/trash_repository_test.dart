import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'trash_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  MockSharedPreferences sharedPreferences = MockSharedPreferences();
  late final TrashRepository repository;
  setUpAll(() {
    TrashRepository.initialize(sharedPreferences);
    repository = TrashRepository();
  });
  setUp(() {
    resetMockitoState();
  });

  group('readAllTrashData',(){
    test('データが1件もない状態で空リストが返却される', () async {
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn(null);
      List<TrashData> result = await repository.readAllTrashData();
      expect(result.length, 0);
    });
    test('空の配列データが1件ある状態で1件のデータが返却される', () async {
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([]);
      List<TrashData> result = await repository.readAllTrashData();
      expect(result.length, 0);
    });
    test('データが1件ある状態で1件のデータが返却される', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson())]);
      List<TrashData> result = await repository.readAllTrashData();
      expect(result.length, 1);
      expect(result[0].id, '001');
      expect(result[0].type, 'other');
      expect(result[0].trashVal, '生ごみ');
      expect(result[0].schedules.length, 1);
      expect(result[0].schedules[0].type, 'weekday');
      expect(result[0].schedules[0].value, '0');
      expect(result[0].excludes.length, 1);
      expect(result[0].excludes[0].month, 1);
      expect(result[0].excludes[0].date, 10);
    });
    test('データが3件ある状態で3件のデータが返却される', () async {
      TrashData trashData1 = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      TrashData trashData2 = TrashData(id: '002', type: 'burn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      TrashData trashData3 = TrashData(id: '003', type: 'unburn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData1.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())]);
      List<TrashData> result = await repository.readAllTrashData();
      expect(result.length, 3);
      expect(result[0].id, '001');
      expect(result[1].id, '002');
      expect(result[2].id, '003');
    });
  });
  group('insertTrashData', () {
    test('登録済みデータ無しの状態で新規追加', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn(null);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      bool result = await repository.insertTrashData(trashData);
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData.toJson())])).called(1);
    });
    test('登録済みデータ有の状態で新規追加', () async {
      TrashData trashData1 = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData1.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      TrashData trashData2 = TrashData(id: '002', type: 'burn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      bool result2 = await repository.insertTrashData(trashData2);
      expect(result2, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData1.toJson()), jsonEncode(trashData2.toJson())])).called(1);
    });
    test('ID重複でエラー', () async {
      TrashData trashData1 = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData1.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      TrashData trashData2 = TrashData(id: '001', type: 'burn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      bool result2 = await repository.insertTrashData(trashData2);
      expect(result2, false);
      verifyNever(sharedPreferences.setStringList('TRASH_DATA', any));
    });
  });
  group('updateTrashData', () {
    test('通常のアップデート,全1件,1件目更新', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      trashData.type = 'burn';
      trashData.trashVal = '';

      bool result2 = await repository.updateTrashData(trashData);
      expect(result2, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData.toJson())])).called(1);
    });
    test('通常のアップデート,全3件,2件目更新', () async {
      TrashData trashData1 = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      TrashData trashData2 = TrashData(id: '002', type: 'burn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      TrashData trashData3 = TrashData(id: '003', type: 'unburn', trashVal: '', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData1.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      trashData2.type = 'plastic';
      trashData2.trashVal = '';

      bool result = await repository.updateTrashData(trashData2);
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData1.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())])).called(1);
    });
    test('対象データ無しでエラー（登録済みデータなし）', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn(null);

      bool result = await repository.updateTrashData(trashData);
      expect(result, false);
      verifyNever(sharedPreferences.setStringList('TRASH_DATA', any));
    });
    test('対象データ無しでエラー（登録済みデータあり,1件目の更新）', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson())]);

      TrashData trashData2 = TrashData(id: '002', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);

      bool result2 = await repository.updateTrashData(trashData2);
      expect(result2, false);
      verifyNever(sharedPreferences.setStringList('TRASH_DATA', any));
    });
  });
  group('deleteTrashData', () {
    test('3件データある状態で1件目を削除', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData(id: '002', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData(id: '003', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      bool result = await repository.deleteTrashData('001');
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())])).called(1);
    });
    test('3件データある状態で2件目を削除', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData(id: '002', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData(id: '003', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      bool result = await repository.deleteTrashData('002');
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData.toJson()), jsonEncode(trashData3.toJson())])).called(1);
    });
    test('3件データある状態で3件目を削除', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData(id: '002', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData(id: '003', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson()), jsonEncode(trashData2.toJson()), jsonEncode(trashData3.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      bool result = await repository.deleteTrashData('003');
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [jsonEncode(trashData.toJson()), jsonEncode(trashData2.toJson())])).called(1);
    });
    test('1件データがある状態の削除', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson())]);
      when(sharedPreferences.setStringList('TRASH_DATA', any)).thenAnswer((_) async => true);

      bool result = await repository.deleteTrashData('001');
      expect(result, true);
      verify(sharedPreferences.setStringList('TRASH_DATA', [])).called(1);
    });
    test('対象データ無しでエラー（登録済みデータなし）', () async {
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn(null);
      bool result = await repository.deleteTrashData('001');
      expect(result, false);
      verifyNever(sharedPreferences.setStringList('TRASH_DATA', any));
    });
    test('対象データ無しでエラー（登録済みデータあり）', () async {
      TrashData trashData = TrashData(id: '001', type: 'other', trashVal: '生ごみ', schedules: [
        TrashSchedule('weekday', '0')
      ], excludes: [ExcludeDate(1, 10)]);
      when(sharedPreferences.getStringList('TRASH_DATA')).thenReturn([jsonEncode(trashData.toJson())]);

      bool result = await repository.deleteTrashData('002');
      expect(result, false);
      verifyNever(sharedPreferences.setStringList('TRASH_DATA', any));
    });
  });
  group('getLastUpdateTime', () {
    test('データが1件もない状態で0が返却される', () async {
      when(sharedPreferences.getInt('LAST_UPDATE_TIME')).thenReturn(null);
      int result = await repository.getLastUpdateTime();
      expect(result, 0);
    });
    test('データが1件ある状態で1件のデータが返却される', () async {
      when(sharedPreferences.getInt('LAST_UPDATE_TIME')).thenReturn(1633024800);
      int result = await repository.getLastUpdateTime();
      expect(result, 1633024800);
    });
  });
  group('updateLastUpdateTime', () {
    test('正常に更新される', () async {
      when(sharedPreferences.setInt('LAST_UPDATE_TIME', 1633024800)).thenAnswer((_) async => true);
      bool result = await repository.updateLastUpdateTime(1633024800);
      expect(result, true);
      verify(sharedPreferences.setInt('LAST_UPDATE_TIME', 1633024800)).called(1);
    });
  });
  group('truncateAllTrashData', () {
    test('正常に削除される', () async {
      when(sharedPreferences.remove('TRASH_DATA')).thenAnswer((_) async => true);
      bool result = await repository.truncateAllTrashData();
      expect(result, true);
      verify(sharedPreferences.remove('TRASH_DATA')).called(1);
    });
  });
  group("initialize", () {
    test("initializeが繰り返し実行された場合はStateErrorが発生すること", () {
      expect(()=>TrashRepository.initialize(sharedPreferences), throwsStateError);
    });
  });
}