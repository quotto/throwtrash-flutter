// filepath: /Users/takah/project/throwtrash-flutter/lib/repository/firebase_auth_migration.dart
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/repository/app_version_repository_interface.dart';
import 'package:throwtrash/usecase/repository/migration_interface.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

/// Firebase認証マイグレーション
///
/// ユーザーIDのみを持つユーザーに対してFirebase匿名認証を行い、
/// リモートAPIにFirebase認証情報を紐づけるマイグレーション
class FirebaseAuthMigration implements MigrationInterface {
  final auth.FirebaseAuth _firebaseAuth;
  final UserApiInterface _userApi;
  final UserRepositoryInterface _userRepository;
  final UserServiceInterface _userService;
  final AppVersionRepositoryInterface _appVersionRepository;
  final Logger _logger = Logger();
  // マイグレーションを実行する最大バージョン (1.3)
  final double _maxVersionForMigration = 1.3;

  /// Firebase認証マイグレーションを作成
  ///
  /// [_userApi] FirebaseIDトークンとユーザーIDを送信するAPI
  /// [_userRepository] 更新されたユーザー情報を保存するためのリポジトリ
  /// [_userService] ユーザー情報の管理を行うサービス
  /// [_appVersionRepository] アプリバージョンの永続化を行うリポジトリ
  FirebaseAuthMigration(this._userApi, this._userRepository, this._userService, this._appVersionRepository)
      : _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  String get name => 'Firebase認証マイグレーション';

  @override
  int get version => 1;

  /// アプリのバージョンを取得し、マイグレーションが必要かどうかを判断する
  ///
  /// 保存されたアプリのバージョンが1.3以下の場合にマイグレーションを実行する
  Future<bool> _shouldMigrateBasedOnVersion() async {
    try {
      String? savedVersion = await _appVersionRepository.getSavedAppVersion();
      if (savedVersion == null) {
        _logger.d('保存されたアプリバージョンが見つかりません。マイグレーションを実行します。');
        return true; // 保存されたバージョンがない場合は初回起動とみなし、マイグレーションを実行
      }

      // バージョン文字列をパースして比較（x.y.z形式を想定）
      List<String> versionParts = savedVersion.split('.');
      double majorMinor = double.parse('${versionParts[0]}.${versionParts[1]}');

      _logger.d('保存されたアプリのバージョン: $savedVersion (比較値: $majorMinor)');

      // 1.3以下のバージョンであればマイグレーションを実行
      return majorMinor <= _maxVersionForMigration;
    } catch (e) {
      _logger.e('保存されたバージョン情報の取得またはパース中にエラーが発生しました: $e');
      // エラーが発生した場合は安全のためマイグレーションを実行
      return true;
    }
  }

  /// ユーザーIDが直接文字列として保存されている可能性があるかをチェック
  Future<bool> _checkForLegacyUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? rawUserId = prefs.getString(UserRepository.USER_ID_KEY);

      if (rawUserId == null) return false;

      // ユーザーIDが単なる文字列として保存されているか確認
      // JSON形式でない場合はマイグレーションが必要
      if (!rawUserId.startsWith('{') && rawUserId.isNotEmpty) {
        _logger.d('レガシー形式のユーザーIDを検出: $rawUserId');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('レガシーユーザーID確認中にエラーが発生しました: $e');
      // エラーが発生した場合は安全のためマイグレーションを実行
      return true;
    }
  }

  @override
  Future<bool> execute() async {
    try {
      // アプリバージョンによるマイグレーション判定
      bool shouldMigrateVersion = await _shouldMigrateBasedOnVersion();
      bool hasLegacyUserId = await _checkForLegacyUserId();

      if (!shouldMigrateVersion) {
        _logger.i('Firebase認証マイグレーション: アプリバージョンが新しいためスキップします');
        return true; // マイグレーションは不要だが正常に完了したとみなす
      }
      if (!hasLegacyUserId) {
        _logger.i('Firebase認証マイグレーション: レガシーユーザーIDが検出されません。マイグレーションは不要です');
        return true; // マイグレーションは不要だが正常に完了したとみなす
      }

      _logger.i('Firebase認証マイグレーション: マイグレーションを開始します (バージョン条件: $shouldMigrateVersion, レガシーID検出: $hasLegacyUserId)');

      // レガシーユーザーIDがある場合は取得して新形式に変換
      User? user;
      if (hasLegacyUserId) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? legacyUserId = prefs.getString(UserRepository.USER_ID_KEY);

        if (legacyUserId != null && legacyUserId.isNotEmpty) {
          // レガシーIDからユーザーオブジェクトを作成
          user = User(legacyUserId);
          _logger.i('レガシーユーザーIDからユーザーオブジェクトを作成: $legacyUserId');
        }
      } else {
        // 通常のユーザー取得
        user = _userService.user;
      }

      // ユーザー情報がない場合または既に認証済みの場合はマイグレーション不要
      if (user == null || user.id.isEmpty || user.isAuthenticated) {
        _logger.d('Firebase認証マイグレーション: ユーザーが未登録または既に認証済みのため、マイグレーション処理をスキップします');
        return true; // マイグレーションは不要だが正常に完了したとみなす
      }

      // 既にFirebase認証済みの場合はサインインしない
      if (_firebaseAuth.currentUser == null) {
        // Firebase匿名ログイン
        await _firebaseAuth.signInAnonymously();
        _logger.i('Firebase認証マイグレーション: 匿名ユーザーでサインインしました: ${_firebaseAuth.currentUser?.uid}');
      } else {
        _logger.i('Firebase認証マイグレーション: 既にサインインしています: ${_firebaseAuth.currentUser?.uid}');
      }

      // APIにサインアップリクエストを送信
      await _signupToRemote(user);

      // マイグレーション後のユーザー情報を更新（認証済みフラグをtrueに設定）
      User updatedUser = User(
        user.id,
        isAuthenticated: true,
        email: user.email,
        displayName: user.displayName,
      );

      // 更新したユーザー情報を保存
      await _userRepository.writeUser(updatedUser);

      // ユーザーサービスの情報も更新
      await _userService.refreshUser();

      return true;
    } catch (e) {
      _logger.e('Firebase認証マイグレーション中にエラーが発生しました: $e');
      return false;
    }
  }

  /// リモートAPIにサインアップリクエスト送信
  Future<void> _signupToRemote(User user) async {
    try {
      await _userApi.signup(user.id);
      _logger.i('Firebase認証マイグレーション: リモートAPIへのサインアップが成功しました');
    } catch (e) {
      _logger.e('リモートAPIへのサインアップ中にエラーが発生しました: $e');
      throw e;
    }
  }
}
