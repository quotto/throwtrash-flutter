import 'package:throwtrash/models/user_api_signin_response.dart';

import '../../models/user.dart';

abstract class UserApiInterface {
  // Googleログインユーザーのサインイン処理を行う
  Future<SigninResponse> signin();

  // アカウント削除処理を行う
  Future<bool> deleteAccount(User user);

  // ユーザーIDとFirebase認証情報を使用してサインアップ処理を行う
  Future<SigninResponse> signup(String userId);
}
