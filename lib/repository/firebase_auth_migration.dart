// filepath: /Users/takah/project/throwtrash-flutter/lib/repository/firebase_auth_migration.dart
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/user.dart';
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
  final Logger _logger = Logger();

  /// Firebase認証マイグレーションを作成
  ///
  /// [_userApi] FirebaseIDトークンとユーザーIDを送信するAPI
  /// [_userRepository] 更新されたユーザー情報を保存するためのリポジトリ
  /// [_userService] ユーザー情報の管理を行うサービス
  FirebaseAuthMigration(this._userApi, this._userRepository, this._userService)
      : _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  String get name => 'Firebase認証マイグレーション';

  @override
  int get version => 1;

  @override
  Future<bool> execute() async {
    // 現在のユーザー情報を取得
    final user = _userService.user;

    // ユーザー情報がない場合または既に認証済みの場合はマイグレーション不要
    if (user == null || user.id.isEmpty || user.isAuthenticated) {
      _logger.d('Firebase認証マイグレーション: ユーザーが未登録または既に認証済みのため、マイグレーションをスキップします');
      return true; // マイグレーションは不要だが正常に完了したとみなす
    }

    try {
      _logger.i('Firebase認証マイグレーション: マイグレーションを開始します');

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
        displayName: user.displayName
      );

      // 更新したユーザー情報を保存
      await _userRepository.writeUser(updatedUser);

      // ユーザーサービスの情報も更新
      await _userService.refreshUser();

      _logger.i('Firebase認証マイグレーション: マイグレーションが成功しました');
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
