// filepath: /Users/takah/project/throwtrash-flutter/lib/usecase/migration_service.dart
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:throwtrash/usecase/migration_service_interface.dart';
import 'package:throwtrash/usecase/repository/app_version_repository_interface.dart';
import 'package:throwtrash/usecase/repository/migration_interface.dart';

/// マイグレーションサービス
///
/// アプリの全てのマイグレーション処理を管理・実行する
class MigrationService implements MigrationServiceInterface {
  final List<MigrationInterface> _migrations = [];
  final Logger _logger = Logger();
  final AppVersionRepositoryInterface _appVersionRepository;

  /// マイグレーションサービスを作成
  MigrationService(this._appVersionRepository);

  @override
  List<MigrationInterface> get migrations => List.unmodifiable(_migrations);

  @override
  void registerMigration(MigrationInterface migration) {
    _migrations.add(migration);
    // バージョン順に並べ替え
    _migrations.sort((a, b) => a.version.compareTo(b.version));
  }

  @override
  Future<bool> executeAll({Function(String migrationName, bool success)? onMigrationCompleted}) async {
    if (_migrations.isEmpty) {
      _logger.i('登録されているマイグレーション処理がありません');
      return true;
    }

    bool allSuccess = true;
    _logger.i('マイグレーション処理を開始します: ${_migrations.length}個のマイグレーションが登録されています');

    for (var migration in _migrations) {
      _logger.d('マイグレーションを実行します: ${migration.name} (version: ${migration.version})');

      try {
        final success = await migration.execute();
        _logger.i('マイグレーション ${migration.name} の実行結果: ${success ? "成功" : "失敗"}');

        // マイグレーション完了時のコールバックを実行
        onMigrationCompleted?.call(migration.name, success);

        // 1つでも失敗したらallSuccessはfalseになる
        if (!success) {
          allSuccess = false;
        }
      } catch (e) {
        _logger.e('マイグレーション中にエラーが発生しました: ${migration.name} - $e');
        onMigrationCompleted?.call(migration.name, false);
        allSuccess = false;
      }
    }

    _logger.i('すべてのマイグレーション処理が完了しました: ${allSuccess ? "すべて成功" : "一部失敗あり"}');

    // すべてのマイグレーションが完了した後、現在のアプリバージョンを保存
    if (allSuccess) {
      try {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        await _appVersionRepository.saveAppVersion(packageInfo.version);
        _logger.i('現在のアプリバージョンを保存しました: ${packageInfo.version}');
      } catch (e) {
        _logger.e('アプリバージョンの保存中にエラーが発生しました: $e');
        // バージョン保存のエラーはマイグレーション全体の成否に影響させない
      }
    }
    return allSuccess;
  }
}
