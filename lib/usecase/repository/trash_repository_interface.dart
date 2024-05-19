import 'package:throwtrash/models/trash_data.dart';

import '../../models/calendar_model.dart';

abstract class TrashRepositoryInterface {
  Future<bool> updateTrashData(TrashData trashData);
  Future<bool> insertTrashData(TrashData trashData);
  Future<List<TrashData>> readAllTrashData();
  Future<bool> deleteTrashData(String id);
  Future<bool> updateLastUpdateTime(int updateTimestamp);
  Future<int> getLastUpdateTime();
  Future<bool> truncateAllTrashData();
  Future<SyncStatus> getSyncStatus();
  Future<bool> setSyncStatus(SyncStatus syncStatus);
}