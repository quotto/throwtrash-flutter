import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/models/trash_update_result.dart';

import '../models/trash_sync_result.dart';
import '../models/user.dart';

abstract class TrashApiInterface {
  Future<RegisterResponse?> registerUserAndTrashData(List<TrashData> allTrashData);
  Future<TrashUpdateResult> updateTrashData(String id, List<TrashData> localSchedule, int localTimestamp);
  Future<TrashSyncResult> syncTrashData(String userId);
}