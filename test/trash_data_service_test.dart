// 202001を想定したカレンダー日付
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/usecase/user_service.dart';

class FirebaseFirestoreMock extends Mock implements FirebaseFirestore{}

List<int> dataSet = [29,30,31,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,1];


void main() {
  SharedPreferences.setMockInitialValues({});
  TrashDataService instance = TrashDataService(
      UserService(
        UserRepository()
      ),
      TrashRepository(),
      TrashApi("")
  );
  group('getEnableTrashListByWeekday', () {
    test('毎週（weekday）', () {
      TrashData trash1 = TrashData('', 'burn', '',
          [TrashSchedule('weekday', '1'), TrashSchedule('weekday', '2')], []);
      TrashData trash2 = TrashData(
          '', 'bin', '', [TrashSchedule('weekday', '1')], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[8].length, 2);
      expect(result[8][0], 'もえるゴミ');
      expect(result[8][1], 'ビン');
      expect(result[9].length, 1);
      expect(result[10].length, 0,);
    });
    test('毎月〇日（month）', () {
      TrashData trash1 = TrashData(
          '', 'unburn', '',
          [TrashSchedule('month', '3'), TrashSchedule('month', '29')], []
      );
      TrashData trash2 = TrashData(
          '', 'other', '家電', [TrashSchedule('month', '3')], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[5].length, 2);
      expect(result[5][0], 'もえないゴミ');
      expect(result[5][1], '家電');
      expect(result[0].length, 1);
      expect(result[31].length, 1);
      expect(result[0][0], 'もえないゴミ');
    });
    test('第〇△曜日（biweek）', () {
      TrashData trash1 = TrashData(
          '', 'plastic', '',
          [TrashSchedule('biweek', '0-3'), TrashSchedule('biweek', '6-1')], []
      );
      TrashData trash2 = TrashData(
          '', 'petbottle', '', [TrashSchedule('biweek', '0-3')], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[21].length, 2);
      expect(result[21][0], 'プラスチック');
      expect(result[21][1], 'ペットボトル');
      expect(result[6].length, 1);
      expect(result[34].length, 1);
      expect(result[34][0], 'プラスチック');
    });
    test('隔週(evweek)でinterval=2', () {
      TrashData trash1 = TrashData('', 'can', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 2}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-29', 'interval': 2})
      ],
          []
      );
      TrashData trash2 = TrashData('', 'paper', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 2})
      ], []);

      // intervalの無いevweekはinterval=2として処理される
      TrashData trash3 = TrashData('', 'burn', '', [
        TrashSchedule(
            'evweek', {'weekday': '4', 'start': '2020-01-05'})
      ], []);

      instance.schedule = [trash1, trash2, trash3];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[10].length, 2);
      expect(result[10][0], 'カン');
      expect(result[24].length, 2);
      expect(result[24][1], '古紙');
      expect(result[25].length, 1);
      expect(result[25][0], 'もえるゴミ');
      expect(result[14].length, 1);
      expect(result[28].length, 1);
      expect(result[0].length, 1);
      expect(result[0][0], 'カン');
    });
    test('隔週(evweek)でinterval=3', () {
      TrashData trash1 = TrashData('', 'resource', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 3}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-22', 'interval': 3})
      ],
          []
      );
      TrashData trash2 = TrashData('', 'coarse', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 3})
      ], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[10].length, 2);
      expect(result[31].length, 2);
      expect(result[10][0], '資源ごみ');
      expect(result[31][1], '粗大ごみ');
      expect(result[0].length, 0);
      expect(result[14].length, 1);
      expect(result[14][0], '資源ごみ');
      expect(result[21].length, 0);
      expect(result[28].length, 0);
    });
    test('隔週(evweek)でinterval=4', () {
      TrashData trash1 = TrashData('', 'resource', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2019-12-29', 'interval': 4}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-01', 'interval': 4})
      ],
          []
      );
      TrashData trash2 = TrashData('', 'coarse', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2019-12-29', 'interval': 4})
      ], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[3].length, 2);
      expect(result[31].length, 2);
      expect(result[3][0], '資源ごみ');
      expect(result[31][1], '粗大ごみ');
      expect(result[0].length, 1);
      expect(result[0][0], '資源ごみ');
      expect(result[14].length, 0);
      expect(result[28].length, 1);
      expect(result[28][0], '資源ごみ');
    });
    test('weekdayに対するExcludeDate設定',(){
      TrashData trash1 = TrashData('','unburn', '', [
        TrashSchedule('weekday','2'),TrashSchedule('weekday', '6')
      ],[ExcludeDate(12, 31),ExcludeDate(1, 7), ExcludeDate(2, 1)]);

      //trash3の比較用でExcludeDate以外同じスケジュール
      TrashData trash2 = TrashData('','plastic', '', [
        TrashSchedule('weekday','2'),TrashSchedule('weekday', '6')
      ],[]);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(year: 2020, month: 1, targetDateList: dataSet);
      expect(result[2].length, 1);
      expect(result[9].length, 1);
      expect(result[34].length ,1);
    });
    test('monthに対するExcludeDate',(){
      TrashData trash1 = TrashData('', 'burn', '', [
        TrashSchedule('month', '29'),TrashSchedule('month', '1')
      ],[ExcludeDate(12, 29), ExcludeDate(1, 1), ExcludeDate(1, 1), ExcludeDate(2, 1)]);
      TrashData trash2 = TrashData('', 'burn', '', [
        TrashSchedule('month', '29'),TrashSchedule('month', '1')
      ],[]);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(year: 2020, month: 1, targetDateList: dataSet);
      expect(result[0].length, 1);
      expect(result[3].length, 1);
      expect(result[34].length, 1);
    });
    test('biweekに対するExcludeDate設定',()
    {
      TrashData trash1 = TrashData('id', 'burn', '', [
        TrashSchedule('biweek', '1-1'),
        TrashSchedule('biweek', '0-5'),
        TrashSchedule('biweek', '6-1')
      ], [ExcludeDate(12, 29), ExcludeDate(1, 6), ExcludeDate(2, 1)]);
      // ExcludeDate以外はtrash1と同じデータ
      TrashData trash2 = TrashData('id', 'burn', '', [
        TrashSchedule('biweek', '1-1'),
        TrashSchedule('biweek', '0-5'),
        TrashSchedule('biweek', '6-1')
      ], []);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[8].length, 1);
      expect(result[0].length, 1);
      expect(result[34].length, 1);
    });
    test('evweekに対する除外設定',(){
      TrashData trash1 = TrashData('id', 'paper', '', [
        TrashSchedule('evweek', {'start': '2019-12-29', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-01-19', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2019-01-15', 'weekday': '0', 'interval': 2}),
      ], [ExcludeDate(12, 29), ExcludeDate(1, 4), ExcludeDate(2, 1)]);
      // ExcludeDate以外はtrash1と同じデータ
      TrashData trash2 = TrashData('id', 'paper', '', [
        TrashSchedule('evweek', {'start': '2019-12-29', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-01-19', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2019-01-15', 'weekday': '0', 'interval': 2}),
      ],[]);

      instance.schedule = [trash1, trash2];

      List<List<String>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[0].length, 1);
      expect(result[6].length, 1);
      expect(result[34].length, 1);

    });
  });
  group('getTodaysTrash',(){
    test('weekday/month',()
    {
      TrashData trash1 = TrashData('', 'burn', '', [
        TrashSchedule('weekday', '3'), TrashSchedule('month', '5')
      ], []);
      TrashData trash2 = TrashData('', 'other', '家電', [
        TrashSchedule('biweek', '3-1')], []);
      TrashData trash3 = TrashData('', 'bin', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule(
            'evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4})
      ], []);
      TrashData trash4 = TrashData('', 'paper', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '0', 'interval': 3})
      ], []);
      TrashData trash5 = TrashData('', 'petbottle', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule(
            'evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4})
      ], []);

      instance.schedule = [trash1, trash2, trash3, trash4, trash5];

      List<TrashData> result1 = instance.getTrashOfToday(
          year: 2020, month: 3, date: 4);
      expect(result1.length, 2);
      expect(result1[0].type, 'burn');
      expect(result1[1].type, 'other');

      List<TrashData> result2 = instance.getTrashOfToday(
          year: 2020, month: 3, date: 5);
      expect(result2.length, 3);
      expect(result2[0].type, 'burn');
      expect(result2[1].type, 'bin');
      expect(result2[2].type, 'petbottle');

      List<TrashData> result3 = instance.getTrashOfToday(
          year: 2020, month: 3, date: 12);
      expect(result3.length, 2);
      expect(result3[0].type, 'bin');
      expect(result3[1].type, 'petbottle');

      List<TrashData> result4 = instance.getTrashOfToday(
          year: 2020, month: 3, date: 29);
      expect(result4.length, 1);
      expect(result4[0].type, 'paper');
    });
    test('biweek',() {
      TrashData trash1 = TrashData('', 'burn', '', [
        TrashSchedule('biweek','1-1')
      ], []);
      TrashData trash2 = TrashData('', 'bottle', '',[
        TrashSchedule('biweek', '2-2')
      ],[]);
      TrashData trash3 = TrashData('', 'paper', '', [
        TrashSchedule('biweek', '3-5')
      ], []);

      instance.schedule = [trash1, trash2, trash3];
      List<TrashData> result1 = instance.getTrashOfToday(year: 2020, month: 9, date: 7);
      expect(result1.length, 1);
      expect(result1[0].type, 'burn');

      List<TrashData> result2 = instance.getTrashOfToday(year: 2020, month: 9, date: 8);
      expect(result2.length, 1);
      expect(result2[0].type, 'bottle');

      List<TrashData> result3 = instance.getTrashOfToday(year: 2020, month: 9, date: 1);
      expect(result3.length, 0);

      List<TrashData> result4 = instance.getTrashOfToday(year: 2020, month: 9, date: 30);
      expect(result4.length, 1);
      expect(result4[0].type, 'paper');
    });
    test('exclude',() {
      TrashData trash1 = TrashData('id', 'burn', '', [
        TrashSchedule('weekday', '3'),TrashSchedule('month', '5')
      ], [ExcludeDate(3, 4)]);
      TrashData trash2 = TrashData('id', 'bin', '', [
        TrashSchedule('evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4}),
      ], []);

      instance.schedule = [trash1, trash2];

      // 3月4日は除外設定されているためburnは設定されない
      List<TrashData> result = instance.getTrashOfToday(year: 2020, month: 3, date: 4);
      expect(result.length, 0);

      List<TrashData> result2 = instance.getTrashOfToday(year: 2020, month: 3, date: 5);
      expect(result2.length, 2);
      expect(result2[0].type, 'burn');
      expect(result2[1].type, 'bin');

      List<TrashData> result3 = instance.getTrashOfToday(year: 2020, month: 3, date: 12);
      expect(result3.length, 1);
      expect(result3[0].type, 'bin');
    });
  });
}