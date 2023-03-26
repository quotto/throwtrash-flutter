class CalendarService {
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
}