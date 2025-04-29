import 'package:json_annotation/json_annotation.dart';

part 'user_api_signin_response.g.dart';

@JsonSerializable()
class SigninResponse {
  final String? userId;

  SigninResponse({
    required this.userId,
  });

  factory SigninResponse.fromJson(Map<String, dynamic> json)  => _$SigninResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SigninResponseToJson(this);
}