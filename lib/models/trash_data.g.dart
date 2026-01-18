// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrashData _$TrashDataFromJson(Map<String, dynamic> json) => TrashData(
  id: json['id'] as String,
  type: json['type'] as String,
  trashVal: json['trash_val'] as String? ?? "",
  schedules:
      (json['schedules'] as List<dynamic>?)
          ?.map((e) => TrashSchedule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  excludes:
      (json['excludes'] as List<dynamic>?)
          ?.map((e) => ExcludeDate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TrashDataToJson(TrashData instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'trash_val': instance.trashVal,
  'schedules': instance.schedules.map((e) => e.toJson()).toList(),
  'excludes': instance.excludes.map((e) => e.toJson()).toList(),
};
