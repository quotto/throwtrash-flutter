abstract class UserApiInterface {
  // APIから新規にユーザーIDの発行を受ける
  Future<String> registerUser();

  // Firebase Authentication のトークンをリフレッシュする
  Future<bool> refreshDeviceToken(String userId, String deviceToken);

  // Googleログインユーザーのサインアップ処理を行う
  Future<bool> signupGoogleUser(String userId);

  // アカウント削除処理を行う
  Future<bool> deleteAccount();
}
