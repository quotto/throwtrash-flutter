// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrashResponse _$TrashResponseFromJson(Map<String, dynamic> json) =>
    TrashResponse(
      json['id'] as String,
      json['description'] as String,
      json['platform'] as String,
      json['shared_id'] as String?,
      json['timestamp'] as int,
    );

Map<String, dynamic> _$TrashResponseToJson(TrashResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'timestamp': instance.timestamp,
      'platform': instance.platform,
      'shared_id': instance.sharedId,
    };
