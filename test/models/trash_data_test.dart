import 'dart:convert';

import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:test/test.dart';

void main() {
  group("TrashScheduleからJsonに変換",(){
    test("trash_valあり/単一のスケジュール/単一の例外日",() {
      TrashData trashData = TrashData("001", "burn", "燃えるゴミ",
          [TrashSchedule("weekday", "0")], [ExcludeDate(12,1)]);
      expect(trashData.toJson().toString(),
          '{id: 001, type: burn, trash_val: 燃えるゴミ, '
              'schedules: [{type: weekday, value: 0}], '
              'excludes: [{month: 12, date: 1}]}'
      );
    });
    test("trash_valなし/単一のスケジュール/例外日なし",() {
      TrashData trashData = TrashData("001", "burn", "",
          [TrashSchedule("weekday", "0")], []);
      expect(trashData.toJson().toString(),
          '{id: 001, type: burn, trash_val: , schedules: [{type: weekday, value: 0}], excludes: []}'
      );
    });
    test("trash_valなし/複数のスケジュール+隔週（Map型）スケジュール/複数の例外日",() {
      TrashData trashData = TrashData("001", "burn", "",
          [
            TrashSchedule("weekday", "0"),
            TrashSchedule("evweek",{"weekday": "1", "interval": 2, "start": "2021-03-10"}),
          ], [ExcludeDate(12,1),ExcludeDate(3, 3)]);
      expect(trashData.toJson().toString(),
          '{id: 001, type: burn, trash_val: , '
              'schedules: [{type: weekday, value: 0}, '
              '{type: evweek, value: {weekday: 1, interval: 2, start: 2021-03-10}}], '
              'excludes: [{month: 12, date: 1}, {month: 3, date: 3}]}'
      );
      print(jsonEncode(trashData.toJson()));
    });
  });
  group("JsonからTrashDataに変換",(){
    test("trash_valあり/単一のスケジュール/単一の例外日",() {
      String jsonValue = '{"id": "001", "type": "burn", "trash_val": "燃えるゴミ", '
          '"schedules": [{"type": "weekday", "value": "0"}], '
          '"excludes": [{"month": 12, "date": 1}]}';

      TrashData trashData = TrashData.fromJson(jsonDecode(jsonValue));
      expect(trashData.id, '001');
      expect(trashData.type, 'burn');
      expect(trashData.trashVal, '燃えるゴミ');
      expect(trashData.schedules[0].type, 'weekday');
      expect(trashData.schedules[0].value, '0');
      expect(trashData.excludes[0].month, 12);
      expect(trashData.excludes[0].date, 1);
    });
    test("trash_valなし/単一のスケジュール/例外日なし",() {
      String jsonValue = '{"id": "001", "type": "burn", "trash_val": "", '
          '"schedules": [{"type": "weekday", "value": "0"}], "excludes": []}';
      TrashData trashData = TrashData.fromJson(jsonDecode(jsonValue));
      expect(trashData.id, '001');
      expect(trashData.type, 'burn');
      expect(trashData.trashVal, '');
      expect(trashData.schedules[0].type, 'weekday');
      expect(trashData.schedules[0].value, '0');
      expect(trashData.excludes.length, 0);
    });
    test("trash_valなし/複数のスケジュール+隔週（Map型）スケジュール/複数の例外日",() {
      String jsonValue = '{"id": "001", "type": "burn", "trash_val": "", '
          '"schedules": [{"type": "weekday", "value": "0"}, '
          '{"type": "evweek", "value": {"weekday": "1", "interval": 2, "start": "2021-03-10"}}], '
          '"excludes": [{"month": 12, "date": 1}, {"month": 3, "date": 3}]}';

      TrashData trashData = TrashData.fromJson(jsonDecode(jsonValue));
      expect(trashData.id, '001');
      expect(trashData.type, 'burn');
      expect(trashData.trashVal, '');
      expect(trashData.schedules[0].type, 'weekday');
      expect(trashData.schedules[0].value, '0');
      expect(trashData.schedules[1].type, 'evweek');
      Map<String,dynamic> evweekValue = trashData.schedules[1].value;
      expect(evweekValue['weekday'], '1');
      expect(evweekValue['interval'], 2);
      expect(evweekValue['start'], '2021-03-10');
      expect(trashData.excludes[0].month, 12);
      expect(trashData.excludes[0].date, 1);
      expect(trashData.excludes[1].month, 3);
      expect(trashData.excludes[1].date, 3);
    });
  });
}