import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trash_data.g.dart';

@JsonSerializable(explicitToJson: true)
class TrashData {
  TrashData({required this.id,required this.type,this.trashVal = "", this.schedules=const [],this.excludes = const []});

  final String id;
  String type;
  @JsonKey(name: 'trash_val')
  String trashVal;
  List<TrashSchedule> schedules;
  List<ExcludeDate> excludes;

  bool isMatchOfDay(int year, int month, int date) {
    return (
        !this.excludes.any((exclude)=>exclude.month == month && exclude.date == date)) &&
      schedules.any((schedule) => schedule.isMatch(year, month, date));
  }

  factory TrashData.fromJson(Map<String,dynamic> json) => _$TrashDataFromJson(json);
  Map<String,dynamic> toJson() => _$TrashDataToJson(this);

}