import 'package:throwtrash/models/user.dart';

abstract class UserServiceInterface {
  Future<bool> registerUser(String id);

  // メモリ上のユーザー情報を読み出す
  User get user;

  // メモリ上のユーザー情報を永続化レイヤの情報に更新する
  Future<void> refreshUser();
}