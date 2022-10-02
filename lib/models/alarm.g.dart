// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alarm _$AlarmFromJson(Map<String, dynamic> json) => Alarm(
      json['enabled'] as bool,
      json['everydayFlg'] as bool,
      json['hour'] as int,
      json['minute'] as int,
    );

Map<String, dynamic> _$AlarmToJson(Alarm instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'everydayFlg': instance.everydayFlg,
      'hour': instance.hour,
      'minute': instance.minute,
    };
