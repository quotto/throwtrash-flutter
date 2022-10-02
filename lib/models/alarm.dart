
import 'package:json_annotation/json_annotation.dart';

part 'alarm.g.dart';

@JsonSerializable()
class Alarm {
  bool enabled;
  bool everydayFlg;
  int hour;
  int minute;

  Alarm(this.enabled, this.everydayFlg, this.hour,this.minute);

  factory Alarm.fromJson(Map<String,dynamic> json) => _$AlarmFromJson(json);
  Map<String,dynamic> toJson() => _$AlarmToJson(this);

}