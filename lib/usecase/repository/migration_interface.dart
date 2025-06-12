// filepath: /Users/takah/project/throwtrash-flutter/lib/usecase/repository/migration_interface.dart
import 'package:throwtrash/models/user.dart';

/// マイグレーション処理のインターフェース
///
/// このインターフェースを実装することで、アプリの任意のマイグレーション処理を追加できる
abstract class MigrationInterface {
  /// マイグレーションの名前
  String get name;

  /// マイグレーションのバージョン（実行順序を決定するための値）
  int get version;

  /// マイグレーション処理を実行する
  ///
  /// 返り値: 処理結果（成功: true, 失敗: false）
  Future<bool> execute();
}

/// ユーザーマイグレーション用のインターフェース
///
/// ユーザー情報に関するマイグレーション処理を実装する
abstract class UserMigrationInterface extends MigrationInterface {
  /// ユーザー情報へのアクセサ
  User? get user;

  /// ユーザー情報を設定する
  set user(User? value);
}

///
/// データベーススキーマの更新などのマイグレーション処理を実装する
abstract class DatabaseMigrationInterface extends MigrationInterface {
  /// データベースバージョン
  int get dbVersion;
}
