import 'dart:convert';

import 'package:throwtrash/models/trash_schedule.dart';
import 'package:test/test.dart';

void main() {
  group('TrashScheduleからJsonデータに変換',(){
    test('valueがString',(){
      TrashSchedule ts = TrashSchedule("weekday", "0");
      String json = ts.toJson().toString();
      expect(json,"{type: weekday, value: 0}");
    });
    test('valueがMap',()
    {
      Map<String, dynamic> scheduleValue = Map();
      scheduleValue['weekday'] = "0";
      scheduleValue['interval'] = 1;
      scheduleValue['start'] = '2021-03-29';
      TrashSchedule ts = TrashSchedule("evweek", scheduleValue);
      String json = ts.toJson().toString();
      expect(json,
          "{type: evweek, value: {weekday: 0, interval: 1, start: 2021-03-29}}");
    });
  });
  group('JsonからTrashScheduleに変換',(){
    test('valueがString',(){
      String jsonValue = '{"type": "weekday", "value": "0"}';
      TrashSchedule ts = TrashSchedule.fromJson(jsonDecode(jsonValue));
      expect(ts.type, "weekday");
      expect(ts.value, "0");
    });
    test('valueがMap',(){
      String jsonValue = '{"type": "evweek", "value": {"weekday": "0", "interval": 1, "start": "2021-03-29"}}';
      TrashSchedule ts = TrashSchedule.fromJson(jsonDecode(jsonValue));
      expect(ts.type, "evweek");
      expect((ts.value as Map<String,dynamic>)["weekday"], "0");
      expect((ts.value as Map<String,dynamic>)["interval"], 1);
      expect((ts.value as Map<String,dynamic>)["start"], "2021-03-29");
    });
  });

  group('月の特定日',() {
    test('一致する', () {
      expect(
          TrashSchedule(
              "month", "5"
          ).isMatch(2022, 3, 5),
          true
      );
    });
    test('一致っしない', () {
      expect(
          TrashSchedule(
              "month", "6"
          ).isMatch(2022, 3, 5),
          false
      );
    });
  });

  group('隔週の判定',(){
    test('異常な日付が与えられた場合',(){
      expect(
          TrashSchedule(
              "evweek",{"start": "2022-3-5","weekday": "3","interval": 2}
          ).isMatch(2020,10,1),
          false
      );
    });
    test('interval=2',()
    {
      // 同じ週
      expect(
        TrashSchedule(
            "evweek",{"start": '2020-03-01', "weekday": "4", "interval": 2}
        ).isMatch(2020, 3, 5),
        true
      );
      // 2週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "4", "interval": 2}
          ).isMatch(2020, 3, 5),
          true
      );
      // 2週間後（interval指定なし）
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "4"}
          ).isMatch(2020, 3, 5),
          true
      );
      //月またぎ（6週後）
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-05-03',  "weekday": "0", "interval": 2}
          ).isMatch(2020, 6, 14),
          true
      );
      // 2週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "3", "interval": 2}
          ).isMatch(2020, 2, 19),
          true
      );

      // 翌週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 2}
          ).isMatch(2020, 3, 14),
          false
      );

      // 前週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "3", "interval": 2}
          ).isMatch(2020, 2, 26),
          false
      );
    });

    test('interval=3',(){
      // 同じ週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "4", "interval": 3}
          ).isMatch(2020, 3, 5),
          true
      );

      // 3週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "1", "interval": 3}
          ).isMatch(2020, 3, 23),
          true
      );

      //月またぎ
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-05-03', "weekday": "2", "interval": 3}
          ).isMatch(2020, 6, 16),
          true
      );

      // 翌週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "3", "interval": 3}
          ).isMatch(2020, 3, 11),
          false
      );

      // 2週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 3}
          ).isMatch(2020, 3, 21),
          false
      );

      //前週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-05-03',  "weekday": "6", "interval": 3}
          ).isMatch(2020, 2, 29),
          false
      );

      // 2週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "5", "interval": 3}
          ).isMatch(2020, 2, 21),
          false
      );

      // 3週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "3", "interval": 3}
          ).isMatch(2020, 2, 12),
          true
      );
    });
    test('interval=4',(){
      // 同じ週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "4", "interval": 4}
          ).isMatch(2020, 3, 5),
          true
      );

      // 4週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "1", "interval": 4}
          ).isMatch(2020, 3, 30),
          true
      );
      //月またぎ
      expect(
          TrashSchedule("evweek",
              {"start": '2020-05-03',  "weekday": "3", "interval": 4}
          ).isMatch(2020, 7, 1),
          true
      );
      // 4週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "2", "interval": 4}
          ).isMatch(2020, 2, 4),
          true
      );

      // 翌週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "3", "interval": 4}
          ).isMatch(2020, 3, 11),
          false
      );

      // 2週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 4}
          ).isMatch(2020, 3, 21),
          false
      );

      // 3週後
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 4}
          ).isMatch(2020, 2, 28),
          false
      );

      //前週
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-05-03',  "weekday": "0", "interval": 4}
          ).isMatch(2020, 2, 29),
          false
      );

      // 2週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 4}
          ).isMatch(2020, 2, 21),
          false
      );

      // 3週前
      expect(
          TrashSchedule(
              "evweek",
              {"start": '2020-03-01',  "weekday": "6", "interval": 4}
          ).isMatch(2020, 2, 14),
          false
      );
    });
  });
}