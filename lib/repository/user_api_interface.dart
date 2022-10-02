abstract class UserApiInterface {
  // APIから新規にユーザーIDの発行を受ける
  Future<String> registerUser();
}