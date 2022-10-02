import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trash_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TrashResponse {
  @JsonKey(name: "id")
  String userId;
  String description;
  String platform;
  int timestamp;

  TrashResponse(this.userId,this.description,this.platform,this.timestamp);
  factory TrashResponse.fromJson(Map<String,dynamic> json) => _$TrashResponseFromJson(json);
  Map<String,dynamic> toJson() => _$TrashResponseToJson(this);
}