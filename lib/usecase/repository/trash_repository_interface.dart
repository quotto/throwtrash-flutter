import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_import_message.dart';

import '../../models/calendar_model.dart';

abstract class TrashRepositoryInterface {
  Future<bool> updateTrashData(TrashData trashData);
  Future<bool> insertTrashData(TrashData trashData);
  Future<bool> replaceAllTrashData(List<TrashData> allTrashData);
  Future<List<TrashData>> readAllTrashData();
  Future<bool> deleteTrashData(String id);
  Future<bool> updateLastUpdateTime(int updateTimestamp);
  Future<int> getLastUpdateTime();
  Future<bool> truncateAllTrashData();
  Future<SyncStatus> getSyncStatus();
  Future<bool> setSyncStatus(SyncStatus syncStatus);
  Future<List<ExcludeDate>> readGlobalExcludeDates();
  Future<bool> writeGlobalExcludeDates(List<ExcludeDate> excludeDates);
  Future<bool> shouldShowInitialSearchDialog();
  Future<bool> markInitialSearchDialogShown();
  Future<bool> saveImportMessage(TrashImportMessage message);
  Future<TrashImportMessage?> consumeImportMessage();
}
