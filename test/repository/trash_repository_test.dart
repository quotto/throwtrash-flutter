import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  TrashRepository repository = TrashRepository();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('insertTrashData', () {
    test('登録済みデータ無しの状態で新規追加', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.insertTrashData(trashData);
      expect(result, true);
      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 1);
      expect(resultData[0].id, '001');
      expect(resultData[0].type, 'other');
      expect(resultData[0].trashVal, '生ごみ');
      expect(resultData[0].schedules.length, 1);
      expect(resultData[0].schedules[0].type, 'weekday');
      expect(resultData[0].schedules[0].value, '0');
      expect(resultData[0].excludes.length, 1);
      expect(resultData[0].excludes[0].month, 1);
      expect(resultData[0].excludes[0].date, 10);
    });
    test('登録済みデータ有の状態で新規追加', () async {
      TrashData trashData1 = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.insertTrashData(trashData1);
      expect(result, true);

      TrashData trashData2 = TrashData('002', 'burn', '', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      bool result2 = await repository.insertTrashData(trashData2);
      expect(result2, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 2);
      expect(resultData[0].id, '001');
      expect(resultData[1].id, '002');
    });
    test('ID重複でエラー', () async {
      TrashData trashData1 = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.insertTrashData(trashData1);
      expect(result, true);

      TrashData trashData2 = TrashData('001', 'burn', '', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      bool result2 = await repository.insertTrashData(trashData2);
      expect(result2, false);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 1);
      expect(resultData[0].id, '001');
    });
  });
  group('updateTrashData', () {
    test('通常のアップデート,全1件,1件目更新', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.insertTrashData(trashData);
      expect(result, true);

      trashData.type = 'burn';
      trashData.trashVal = '';

      bool result2 = await repository.updateTrashData(trashData);
      expect(result2, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 1);
      expect(resultData[0].type, 'burn');
      expect(resultData[0].trashVal, '');
      // 他の項目は変わっていないこと
      expect(resultData[0].id, '001');
      expect(resultData[0].schedules[0].type, 'weekday');
      expect(resultData[0].schedules[0].value, '0');
      expect(resultData[0].excludes.length, 1);
      expect(resultData[0].excludes[0].month, 1);
      expect(resultData[0].excludes[0].date, 10);
    });
    test('通常のアップデート,全3件,2件目更新', () async {
      TrashData trashData1 = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      TrashData trashData2 = TrashData('002', 'burn', '', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      TrashData trashData3 = TrashData('003', 'unburn', '', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData1);
      await repository.insertTrashData(trashData2);
      await repository.insertTrashData(trashData3);

      trashData2.type = 'plastic';
      trashData2.trashVal = '';

      bool result = await repository.updateTrashData(trashData2);
      expect(result, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 3);
      // 2件目のtypeだけ変わっていること
      expect(resultData[0].type, 'other');
      expect(resultData[1].type, 'plastic');
      expect(resultData[2].type, 'unburn');
    });
    test('対象データ無しでエラー（登録済みデータなし）', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.updateTrashData(trashData);
      expect(result, false);
    });
    test('対象データ無しでエラー（登録済みデータあり,1件目の更新）', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result = await repository.insertTrashData(trashData);
      expect(result, true);

      TrashData trashData2 = TrashData('002', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      bool result2 = await repository.updateTrashData(trashData2);
      expect(result2, false);
    });
  });
  group('deleteTrashData', () {
    test('3件データある状態で1件目を削除', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData('002', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData('003', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData);
      await repository.insertTrashData(trashData2);
      await repository.insertTrashData(trashData3);

      bool result = await repository.deleteTrashData('001');
      expect(result, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 2);
      expect(resultData[0].id, '002');
      expect(resultData[1].id, '003');
    });
    test('3件データある状態で2件目を削除', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData('002', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData('003', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData);
      await repository.insertTrashData(trashData2);
      await repository.insertTrashData(trashData3);

      bool result = await repository.deleteTrashData('002');
      expect(result, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 2);
      expect(resultData[0].id, '001');
      expect(resultData[1].id, '003');
    });
    test('3件データある状態で3件目を削除', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData2 = TrashData('002', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);
      TrashData trashData3 = TrashData('003', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData);
      await repository.insertTrashData(trashData2);
      await repository.insertTrashData(trashData3);

      bool result = await repository.deleteTrashData('003');
      expect(result, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 2);
      expect(resultData[0].id, '001');
      expect(resultData[1].id, '002');
    });
    test('1件データがある状態の削除', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData);

      bool result = await repository.deleteTrashData('001');
      expect(result, true);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 0);
    });
    test('対象データ無しでエラー（登録済みデータなし）', () async {
      bool result = await repository.deleteTrashData('001');
      expect(result, false);
    });
    test('対象データ無しでエラー（登録済みデータあり）', () async {
      TrashData trashData = TrashData('001', 'other', '生ごみ', [
        TrashSchedule('weekday', '0')
      ], [ExcludeDate(1, 10)]);

      await repository.insertTrashData(trashData);
      bool result = await repository.deleteTrashData('002');
      expect(result, false);

      List<TrashData> resultData = await repository.readAllTrashData();
      expect(resultData.length, 1);
    });
  });
}