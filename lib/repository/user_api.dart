import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:uuid/uuid.dart';

class UserApi extends UserApiInterface {
  final FirebaseFirestore _firebaseFirestore;

  UserApi(this._firebaseFirestore);

  Future<bool> refreshDeviceToken(String userId, String deviceToken) async {
    return await _firebaseFirestore.collection('devices').doc(deviceToken).set({
      'userId': userId,
      'created': DateTime.now().toUtc(),
      'updated': DateTime.now().toUtc()
    }).then((value)=>true).catchError((error){
      print(error);
      return false;
    });
  }

  @override
  Future<String> registerUser() async {
    String userId = Uuid().v4();
    return await _firebaseFirestore.collection('users').doc(userId).set({
      'created': DateTime.now().toUtc(),
      'updated': DateTime.now().toUtc()
    })
        .then((_)=> userId)
        .catchError((error){
          print(error);
          return '';
        });
  }

}
