import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';

abstract class TrashApiInterface {
  Future<RegisterResponse?> registerUserAndTrashData(List<TrashData> allTrashData);
  Future<int?> updateTrashData(String id, List<TrashData> allTrashData);
  Future<TrashResponse?> getRemoteTrashData(String userId);
}