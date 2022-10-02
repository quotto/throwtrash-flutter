class CalendarUseCase {
  // まだ一度もDBと同期していない状態、アプリインストール時の初期状態
  static const SYNC_NO = 0;
  // ローカルでデータ更新済みの状態、DB同期済みであればアプリ起動時の初期状態
  static const SYNC_WAITING = 1;
  // ローカル更新後にDBに保存した状態
  static const SYNC_COMPLETE = 2;

  List<int> generateMonthCalendar(int year, int month) {
    // 出力値算出用のインスタンス
    DateTime computeCalendar = DateTime(year,month,1);

    List<int> dateArray = [];
    // 日曜日の場合は戻す必要がないため1日目の曜日から-1する
    if(computeCalendar.weekday != 7) {
      computeCalendar =
          computeCalendar.add(Duration(days: -1 * computeCalendar.weekday));
    }

    for(int i=1; i<36; i++) {
      dateArray.add(computeCalendar.day);
      computeCalendar = computeCalendar.add(Duration(days:1));
    }
    return dateArray;
  }

/**
 * クラウド上のDBに登録されたデータを同期する
 * ID未発行→DBに新規に登録
 * DBのタイムスタンプ>ローカルのタイムスタンプ→ローカルのデータを更新
 * DBのタイムスタンプ<ローカルのタイムスタンプ→DBへ書き込み
 */
void syncData() {
//   if(config.getSyncState() == SYNC_WAITING) {
//     val userId:String? = config.getUserId()
//     val localSchedule: ArrayList<TrashData> = persist.getAllTrashSchedule()
//     if(userId == null || userId.isEmpty()) {
//       Log.i(this.javaClass.simpleName,"ID not exists,Register.")
//       apiAdapter.register(localSchedule)?.let { info ->
//   config.setUserId(info.first)
//   config.setTimestamp(info.second)
//   config.setSyncState(SYNC_COMPLETE)
//   Log.i(this.javaClass.simpleName,"Registered new id -> ${info.first}")
//   }
//   } else {
//   apiAdapter.sync(userId)?.let { data ->
//   val localTimestamp = config.getTimeStamp()
//   Log.i(this.javaClass.simpleName,"Local Timestamp=$localTimestamp")
//   if(data.second > localTimestamp) {
//   Log.i(this.javaClass.simpleName,"Local data is old, updated from DB(DB Timestamp=${data.second}")
//   config.setTimestamp(data.second)
//   persist.importScheduleList(data.first)
//   trashManager.refresh()
//   } else if(data.second < localTimestamp && localSchedule.size > 0) {
//   // ローカルのタイムスタンプが大きい場合でも登録スケジュールが0の場合はUpdateしない
//   apiAdapter.update(userId, localSchedule)
//       ?.let { timestamp ->
//   Log.i(this.javaClass.simpleName,"Local Timestamp is newer(DB Timestamp=${data.second}")
//   config.setTimestamp(timestamp)
//   }
//   }
//   config.setSyncState(SYNC_COMPLETE)
//   }
//   }
// }
}
}