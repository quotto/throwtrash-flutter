// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrashApiSyncDataResponse _$TrashApiSyncDataResponseFromJson(
  Map<String, dynamic> json,
) => TrashApiSyncDataResponse(
  json['id'] as String,
  json['description'] as String,
  json['platform'] as String,
  json['shared_id'] as String?,
  (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$TrashApiSyncDataResponseToJson(
  TrashApiSyncDataResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'timestamp': instance.timestamp,
  'platform': instance.platform,
  'shared_id': instance.sharedId,
};
