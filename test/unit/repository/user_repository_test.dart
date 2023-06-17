import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/repository/user_repository.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  test('readUserId',() async{
    UserRepository instance = UserRepository();
    await instance.readUserId().then((userId){
      expect(userId, '');
    });
    await instance.writeUserId('testId').then((result){
      expect(result, true);
    });
    await instance.readUserId().then((userId){
      expect(userId, 'testId');
    });

  });
}