import 'package:json_annotation/json_annotation.dart';

part 'activate_response.g.dart';

@JsonSerializable()
class ActivateResponse {
  String description;
  int timestamp;

  ActivateResponse(this.description, this.timestamp);
  factory ActivateResponse.fromJson(Map<String,dynamic> json) => _$ActivateResponseFromJson(json);
  Map<String,dynamic> toJson() => _$ActivateResponseToJson(this);
}