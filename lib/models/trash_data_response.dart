import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trash_data_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TrashDataResponse {
  TrashDataResponse(this.id,this.type,this.trashVal,this.schedules,this.excludes);

  final String id;
  String type;
  @JsonKey(name: 'trash_val')
  String? trashVal;
  List<TrashSchedule> schedules;
  List<ExcludeDate>? excludes;

  bool isMatchOfDay(int year, int month, int date) {
    return (
        this.excludes != null && !this.excludes!.any((exclude)=>exclude.month == month && exclude.date == date)) &&
      schedules.any((schedule) => schedule.isMatch(year, month, date));
  }

  factory TrashDataResponse.fromJson(Map<String,dynamic> json) => _$TrashDataResponseFromJson(json);
  Map<String,dynamic> toJson() => _$TrashDataResponseToJson(this);
  TrashData toTrashData() {
   return TrashData(
     id: this.id,
     type: this.type,
     trashVal: trashVal != null ? trashVal! : "",
     schedules: schedules,
     excludes: excludes != null ? excludes! : []
   );
  }

}