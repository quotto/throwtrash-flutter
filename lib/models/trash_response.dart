import 'package:json_annotation/json_annotation.dart';

part 'trash_response.g.dart';

@JsonSerializable()
class TrashResponse {
  String id;
  String description;
  int timestamp;
  String platform;
  @JsonKey(name: "shared_id")
  String? sharedId;

  TrashResponse(this.id, this.description,this.platform, this.sharedId, this.timestamp);
  factory TrashResponse.fromJson(Map<String,dynamic> json) => _$TrashResponseFromJson(json);
  Map<String,dynamic> toJson() => _$TrashResponseToJson(this);
}