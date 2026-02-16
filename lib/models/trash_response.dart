import 'package:json_annotation/json_annotation.dart';
import 'package:throwtrash/models/exclude_date.dart';

part 'trash_response.g.dart';

@JsonSerializable()
class TrashApiSyncDataResponse {
  String id;
  String description;
  int timestamp;
  String platform;
  @JsonKey(name: "shared_id")
  String? sharedId;
  @JsonKey(name: "globalExcludes", defaultValue: [])
  List<ExcludeDate> globalExcludes;

  TrashApiSyncDataResponse(this.id, this.description, this.platform,
      this.sharedId, this.timestamp, this.globalExcludes);
  factory TrashApiSyncDataResponse.fromJson(Map<String, dynamic> json) =>
      _$TrashApiSyncDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TrashApiSyncDataResponseToJson(this);
}
