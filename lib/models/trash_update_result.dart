enum UpdateResult {
  SUCCESS,
  NO_MATCH,
  ERROR
}

class TrashUpdateResult {
  final int timestamp;
  final UpdateResult updateResult;
  TrashUpdateResult(this.timestamp, this.updateResult);
}