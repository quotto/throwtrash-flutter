import 'package:throwtrash/models/trash_data.dart';

enum TrashApiSyncStatus {
  SUCCESS,
  NO_MATCH,
  ERROR
}
class TrashSyncResult {
  final List<TrashData> allTrashDataList;
  final int timestamp;
  final TrashApiSyncStatus syncResult;
  TrashSyncResult(this.allTrashDataList, this.timestamp, this.syncResult);
}