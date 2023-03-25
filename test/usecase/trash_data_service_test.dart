// 202001を想定したカレンダー日付
import 'dart:convert';

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


void main() async{
  SharedPreferences.setMockInitialValues({});
  TrashDataService instance = TrashDataService(
      UserService(
        UserRepository()
      ),
      TrashRepository(),
      TrashApi("")
  );
  group('getEnableTrashListByWeekday', () {
    test('毎週（weekday）', () async{
      TrashData trash1 = TrashData('1', 'burn', '',
          [TrashSchedule('weekday', '1'), TrashSchedule('weekday', '2')], []);
      TrashData trash2 = TrashData(
          '2', 'bin', '', [TrashSchedule('weekday', '1')], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[8].length, 2);
      expect(result[8][0].type, 'burn');
      expect(result[8][1].type, 'bin');
      expect(result[9].length, 1);
      expect(result[10].length, 0,);
    });
    test('毎月〇日（month）', () async {
      TrashData trash1 = TrashData(
          '1', 'unburn', '',
          [TrashSchedule('month', '3'), TrashSchedule('month', '29')], []
      );
      TrashData trash2 = TrashData(
          '2', 'other', '家電', [TrashSchedule('month', '3')], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[5].length, 2);
      expect(result[5][0].type, 'unburn');
      expect(result[5][1].type, 'other');
      expect(result[5][1].trashVal, '家電');
      expect(result[0].length, 1);
      expect(result[31].length, 1);
      expect(result[0][0].type, 'unburn');
    });
    test('第〇△曜日（biweek）', () async {
      TrashData trash1 = TrashData(
          '1', 'plastic', '',
          [TrashSchedule('biweek', '0-3'), TrashSchedule('biweek', '6-1')], []
      );
      TrashData trash2 = TrashData(
          '2', 'petbottle', '', [TrashSchedule('biweek', '0-3')], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[21].length, 2);
      expect(result[21][0].type, 'plastic');
      expect(result[21][1].type, 'petbottle');
      expect(result[6].length, 1);
      expect(result[34].length, 1);
      expect(result[34][0].type, 'plastic');
    });
    test('隔週(evweek)でinterval=2', () async {
      TrashData trash1 = TrashData('1', 'can', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 2}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-29', 'interval': 2})
      ],
          []
      );
      TrashData trash2 = TrashData('2', 'paper', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 2})
      ], []);

      // intervalの無いevweekはinterval=2として処理される
      TrashData trash3 = TrashData('3', 'burn', '', [
        TrashSchedule(
            'evweek', {'weekday': '4', 'start': '2020-01-05'})
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,
          [
            jsonEncode(trash1.toJson()),
            jsonEncode(trash2.toJson()),
            jsonEncode(trash3.toJson())
          ]
      );
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[10].length, 2);
      expect(result[10][0].type, 'can');
      expect(result[24].length, 2);
      expect(result[24][1].type, 'paper');
      expect(result[25].length, 1);
      expect(result[25][0].type, 'burn');
      expect(result[14].length, 1);
      expect(result[28].length, 1);
      expect(result[0].length, 1);
      expect(result[0][0].type, 'can');
    });
    test('隔週(evweek)でinterval=3', () async {
      TrashData trash1 = TrashData('1', 'resource', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 3}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-22', 'interval': 3})
      ],
          []
      );
      TrashData trash2 = TrashData('2', 'coarse', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2020-01-05', 'interval': 3})
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[10].length, 2);
      expect(result[31].length, 2);
      expect(result[10][0].type, 'resource');
      expect(result[31][1].type, 'coarse');
      expect(result[0].length, 0);
      expect(result[14].length, 1);
      expect(result[14][0].type, 'resource');
      expect(result[21].length, 0);
      expect(result[28].length, 0);
    });
    test('隔週(evweek)でinterval=4', () async {
      TrashData trash1 = TrashData('1', 'resource', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2019-12-29', 'interval': 4}),
        TrashSchedule(
            'evweek', {'weekday': '0', 'start': '2019-12-01', 'interval': 4})
      ],
          []
      );
      TrashData trash2 = TrashData('2', 'coarse', '', [
        TrashSchedule(
            'evweek', {'weekday': '3', 'start': '2019-12-29', 'interval': 4})
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet
      );

      expect(result[3].length, 2);
      expect(result[31].length, 2);
      expect(result[3][0].type, 'resource');
      expect(result[31][1].type, 'coarse');
      expect(result[0].length, 1);
      expect(result[0][0].type, 'resource');
      expect(result[14].length, 0);
      expect(result[28].length, 1);
      expect(result[28][0].type, 'resource');
    });
    test('weekdayに対するExcludeDate設定',() async {
      TrashData trash1 = TrashData('1','unburn', '', [
        TrashSchedule('weekday','2'),TrashSchedule('weekday', '6')
      ],[ExcludeDate(12, 31),ExcludeDate(1, 7), ExcludeDate(2, 1)]);

      //trash3の比較用でExcludeDate以外同じスケジュール
      TrashData trash2 = TrashData('2','plastic', '', [
        TrashSchedule('weekday','2'),TrashSchedule('weekday', '6')
      ],[]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(year: 2020, month: 1, targetDateList: dataSet);
      expect(result[2].length, 1);
      expect(result[9].length, 1);
      expect(result[34].length ,1);
    });
    test('monthに対するExcludeDate',() async {
      TrashData trash1 = TrashData('1', 'burn', '', [
        TrashSchedule('month', '29'),TrashSchedule('month', '1')
      ],[ExcludeDate(12, 29), ExcludeDate(1, 1), ExcludeDate(1, 1), ExcludeDate(2, 1)]);
      TrashData trash2 = TrashData('', 'burn', '', [
        TrashSchedule('month', '29'),TrashSchedule('month', '1')
      ],[]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(year: 2020, month: 1, targetDateList: dataSet);
      expect(result[0].length, 1);
      expect(result[3].length, 1);
      expect(result[34].length, 1);
    });
    test('biweekに対するExcludeDate設定',() async {
      TrashData trash1 = TrashData('1', 'burn', '', [
        TrashSchedule('biweek', '1-1'),
        TrashSchedule('biweek', '0-5'),
        TrashSchedule('biweek', '6-1')
      ], [ExcludeDate(12, 29), ExcludeDate(1, 6), ExcludeDate(2, 1)]);
      // ExcludeDate以外はtrash1と同じデータ
      TrashData trash2 = TrashData('2', 'burn', '', [
        TrashSchedule('biweek', '1-1'),
        TrashSchedule('biweek', '0-5'),
        TrashSchedule('biweek', '6-1')
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[8].length, 1);
      expect(result[0].length, 1);
      expect(result[34].length, 1);
    });
    test('evweekに対する除外設定',() async {
      TrashData trash1 = TrashData('1', 'paper', '', [
        TrashSchedule('evweek', {'start': '2019-12-29', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-01-19', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2019-01-15', 'weekday': '0', 'interval': 2}),
      ], [ExcludeDate(12, 29), ExcludeDate(1, 4), ExcludeDate(2, 1)]);
      // ExcludeDate以外はtrash1と同じデータ
      TrashData trash2 = TrashData('2', 'paper', '', [
        TrashSchedule('evweek', {'start': '2019-12-29', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-01-19', 'weekday': '6', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2019-01-15', 'weekday': '0', 'interval': 2}),
      ],[]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,[jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]);
      await instance.refreshTrashData();

      List<List<TrashData>> result = instance.getEnableTrashList(
          year: 2020, month: 1, targetDateList: dataSet);
      expect(result[0].length, 1);
      expect(result[6].length, 1);
      expect(result[34].length, 1);

    });
  });
  group('getTodaysTrash',() {
    test('weekday/month',() async {
      TrashData trash1 = TrashData('1', 'burn', '', [
        TrashSchedule('weekday', '3'), TrashSchedule('month', '5')
      ], []);
      TrashData trash2 = TrashData('2', 'other', '家電', [
        TrashSchedule('biweek', '3-1')], []);
      TrashData trash3 = TrashData('3', 'bin', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule(
            'evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4})
      ], []);
      TrashData trash4 = TrashData('4', 'paper', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '0', 'interval': 3})
      ], []);
      TrashData trash5 = TrashData('5', 'petbottle', '', [
        TrashSchedule(
            'evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule(
            'evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4})
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,
          [
            jsonEncode(trash1.toJson()),
            jsonEncode(trash2.toJson()),
            jsonEncode(trash3.toJson()),
            jsonEncode(trash4.toJson()),
            jsonEncode(trash5.toJson())
          ]
      );
      await instance.refreshTrashData();

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
    test('biweek',() async {
      TrashData trash1 = TrashData('1', 'burn', '', [
        TrashSchedule('biweek','1-1')
      ], []);
      TrashData trash2 = TrashData('2', 'bottle', '',[
        TrashSchedule('biweek', '2-2')
      ],[]);
      TrashData trash3 = TrashData('3', 'paper', '', [
        TrashSchedule('biweek', '3-5')
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,
          [
            jsonEncode(trash1.toJson()),
            jsonEncode(trash2.toJson()),
            jsonEncode(trash3.toJson())
          ]
      );
      await instance.refreshTrashData();

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
    test('exclude',() async {
      TrashData trash1 = TrashData('id', 'burn', '', [
        TrashSchedule('weekday', '3'),TrashSchedule('month', '5')
      ], [ExcludeDate(3, 4)]);
      TrashData trash2 = TrashData('id', 'bin', '', [
        TrashSchedule('evweek', {'start': '2020-03-08', 'weekday': '4', 'interval': 2}),
        TrashSchedule('evweek', {'start': '2020-03-01', 'weekday': '4', 'interval': 4}),
      ], []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(TrashRepository.TRASH_DATA_KEY,
          [jsonEncode(trash1.toJson()),jsonEncode(trash2.toJson())]
      );
      await instance.refreshTrashData();

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