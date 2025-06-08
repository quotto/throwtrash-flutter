// filepath: /Users/takah/project/throwtrash-flutter/lib/usecase/migration_service_interface.dart
import 'package:throwtrash/usecase/repository/migration_interface.dart';

/// マイグレーションサービスのインターフェース
///
/// アプリの全てのマイグレーション処理を管理・実行するためのインターフェース
abstract class MigrationServiceInterface {
  /// 登録されているマイグレーション処理のリスト
  List<MigrationInterface> get migrations;

  /// マイグレーション処理を登録する
  ///
  /// [migration] 登録するマイグレーション処理
  void registerMigration(MigrationInterface migration);

  /// すべてのマイグレーション処理を実行する
  ///
  /// [onMigrationCompleted] 各マイグレーション完了後に呼ばれるコールバック関数（オプション）
  /// 返り値: すべてのマイグレーションが成功したかどうか
  Future<bool> executeAll({Function(String migrationName, bool success)? onMigrationCompleted});
}
