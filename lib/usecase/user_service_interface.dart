import 'package:throwtrash/models/user.dart';

abstract class UserServiceInterface {
  Future<bool> registerUser(String id);

  // 初期化時のFirebaseサインイン
  Future<void> initialize();

  // メモリ上のユーザー情報を読み出す
  User get user;

  // メモリ上のユーザー情報を永続化レイヤの情報に更新する
  Future<void> refreshUser();

  // Googleログインを実行する
  Future<bool> signInWithGoogle();

  // ログアウト処理を行う
  Future<bool> signOut();

  // アカウント削除処理を行う
  Future<bool> deleteAccount();

  // FirebaseAuthのIDトークンを取得する
  Future<String?> getIdToken();
}
