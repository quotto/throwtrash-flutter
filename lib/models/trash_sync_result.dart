import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';

enum SyncResult {
  SUCCESS,
  NO_MATCH,
  ERROR
}
class TrashSyncResult {
  final List<TrashData> allTrashDataList;
  final int timestamp;
  final SyncResult syncResult;
  TrashSyncResult(this.allTrashDataList, this.timestamp, this.syncResult);
}