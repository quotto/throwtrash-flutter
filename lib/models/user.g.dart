// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  json['id'] as String,
  isAuthenticated: json['isAuthenticated'] as bool? ?? false,
  email: json['email'] as String? ?? "",
  displayName: json['displayName'] as String? ?? "匿名アカウント",
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'isAuthenticated': instance.isAuthenticated,
  'email': instance.email,
  'displayName': instance.displayName,
};
