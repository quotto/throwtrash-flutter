import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/exclude_date.dart';

enum TrashApiSyncStatus { SUCCESS, NO_MATCH, ERROR }

class TrashSyncResult {
  final List<TrashData> allTrashDataList;
  final List<ExcludeDate> globalExcludes;
  final int timestamp;
  final TrashApiSyncStatus syncResult;
  TrashSyncResult(this.allTrashDataList, this.globalExcludes, this.timestamp,
      this.syncResult);
}
