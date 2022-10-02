import 'package:json_annotation/json_annotation.dart';

part 'exclude_date.g.dart';

@JsonSerializable()
class ExcludeDate {
  ExcludeDate(this.month,this.date);
  int month;
  int date;

  factory ExcludeDate.fromJson(Map<String,dynamic> json) => _$ExcludeDateFromJson(json);
  Map<String,dynamic> toJson() => _$ExcludeDateToJson(this);

}