import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String id;
  final bool isAuthenticated;
  final String email;
  final String displayName;

  User._(
    this.id,
    this.isAuthenticated,
    this.email,
    this.displayName,
  );

  User (
    this.id, {
      this.isAuthenticated = false,
      this.email = "",
      this.displayName = "匿名アカウント"
    }
  );

  User signInWithGoogle(
      String email, String displayName) {
    return User._(
        this.id,
        true,
        email,
        displayName
    );
  }

  // Factory method for anonymous user
  factory User.anonymous(String userId) {
    return User(userId);
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
