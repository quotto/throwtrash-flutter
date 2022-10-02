enum SyncStatus {
  NOT_YET, // ローカルに変更があり未同期
  SYNCING, // 同期処理中
  COMPLETE // 同期済み
}

extension SyncStatusHelper on SyncStatus {
  SyncStatus toSyncStatus(int index) {
    switch(index) {
      case 0:
        return SyncStatus.NOT_YET;
      case 1:
        return SyncStatus.SYNCING;
      case 2:
        return SyncStatus.COMPLETE;
      default:
        return SyncStatus.NOT_YET;
    }
  }

  int toInt() {
    switch(this) {
      case SyncStatus.NOT_YET:
        return 0;
      case SyncStatus.SYNCING:
        return 1;
      case SyncStatus.COMPLETE:
        return 2;
      default:
        return 0;
    }
  }
}