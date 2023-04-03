import 'package:json_annotation/json_annotation.dart';

part 'trash_response.g.dart';

@JsonSerializable()
class TrashApiSyncDataResponse {
  String id;
  String description;
  int timestamp;
  String platform;
  @JsonKey(name: "shared_id")
  String? sharedId;

  TrashApiSyncDataResponse(this.id, this.description,this.platform, this.sharedId, this.timestamp);
  factory TrashApiSyncDataResponse.fromJson(Map<String,dynamic> json) => _$TrashApiSyncDataResponseFromJson(json);
  Map<String,dynamic> toJson() => _$TrashApiSyncDataResponseToJson(this);
}