import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/repository/user_repository.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  test('readUser',() async{
    UserRepository.initialize(await SharedPreferences.getInstance());
    UserRepository instance = UserRepository();
    await instance.readUser().then((user){
      expect(user, null);
    });
    await instance.writeUser(User('testId')).then((result){
      expect(result, true);
    });
    await instance.readUser().then((user){
      expect(user?.id, 'testId');
    });
  });
}