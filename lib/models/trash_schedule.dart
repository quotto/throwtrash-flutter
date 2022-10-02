
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

part 'trash_schedule.g.dart';

@JsonSerializable()
class TrashSchedule {
  TrashSchedule(this.type,this.value);
  String type;
  dynamic value;
  final _logger = Logger();

  bool isMatch(int year, int month, int date){
    String strMonth = month < 10 ? "0$month" : month.toString();
    String strDate = date < 10 ? "0$date" : date.toString();

    bool match = false;
    try {
      DateTime targetDt = DateTime.parse("$year-$strMonth-$strDate");
      // DartのDateTimeは月曜日が1、日曜日が7のためバックエンドAPIに合わせて日曜は0に修正する
      int dayOfWeek = targetDt.weekday == 7 ? 0 : targetDt.weekday;
      switch (this.type) {
        case "weekday":
          match = int.parse(value) == dayOfWeek;
          break;
        case "month":
          match = value == date.toString();
          break;
        case "biweek":
          int numOfDay = 1; //対象日の曜日が第何かを示す数字
          while ((date - (numOfDay * 7) > 0)) {
            numOfDay++;
          }
          match = value == "$dayOfWeek-$numOfDay";
          break;
        case "evweek":
          Map<String, dynamic> vMap = value as Map<String, dynamic>;
          int interval = vMap["interval"] != null ? vMap["interval"] : 2;
          match = vMap["weekday"]!! == dayOfWeek.toString() && _isEvWeek(
              vMap["start"] as String,
              "$year-$strMonth-$strDate",
              dayOfWeek,
              interval
          );
          break;
      }
    } on FormatException catch(e) {
      _logger.e(e.message);
    }
    return match;
  }

  bool _isEvWeek(String start, String target, int dayOfWeek, int interval) {
    DateTime startDt = DateTime.parse(start);
    DateTime targetDt = DateTime.parse(target);
    // 指定された日付からその週の日曜日の日付を求める
    DateTime targetDtFromSunday = targetDt.subtract(Duration(days: dayOfWeek));

    int diffDate = targetDtFromSunday.difference(startDt).inDays;
    return diffDate % interval == 0;
  }

  factory TrashSchedule.fromJson(Map<String,dynamic> json) => _$TrashScheduleFromJson(json);
  Map<String,dynamic> toJson() => _$TrashScheduleToJson(this);
}