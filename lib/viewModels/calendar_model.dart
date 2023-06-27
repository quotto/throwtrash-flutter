import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/calendar_service.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

import '../models/trash_data.dart';

class DisplayTrashData {
    DisplayTrashData(this.trashType,this.trashName);
    final String trashType;
    final String trashName;
}

enum LoadingStatus {
    loading,
    loaded,
    error,
}

/*
 * カレンダーのモデル
 * カレンダーの日付とゴミの種類を保持する
 */
class CalendarModel extends ChangeNotifier {
    Logger _logger = Logger();
    List<List<List<DisplayTrashData>>> _calendarsTrashList = [];
    List<List<int>> _calendarsDateList = [];
    LoadingStatus _loadingStatus = LoadingStatus.loading;
    SyncResult _syncResult = SyncResult.skipped;

    int _year = 0;
    int _month = 0;

    // カレンダーリストの実際のインデックス
    // リストに増減が発生した場合にこの値も増減させる
    int _currentPage = 0;

    // 現在年月を0とした場合の実際のカレンダー月のインデックス
    // forward/backwardごとに1ずつ増減する
    int _calendarIndex = 0;

    int get year => _year;

    int get month => _month;

    int get currentPage => _currentPage;

    List<List<List<DisplayTrashData>>> get calendarsTrashList => _calendarsTrashList;

    List<List<int>> get calendarsDateList => _calendarsDateList;

    SyncResult get syncResult => _syncResult;

    CalendarService _calendarUseCase;
    TrashDataServiceInterface _trashDataService;

    CalendarModel(this._calendarUseCase, this._trashDataService, DateTime today) {
        _year = today.year;
        _month = today.month;
        _trashDataService.refreshTrashData().then((_) async {
            for (int i = 0; i < 5; i++) {
                int tmpYear = _year;
                int tmpMonth = _month + i;
                if (tmpMonth > 12) {
                    tmpMonth = 1;
                    tmpYear++;
                }

                List<int> tmpCalendarDate = _calendarUseCase
                    .generateMonthCalendar(tmpYear, tmpMonth);
                _calendarsDateList.add(tmpCalendarDate);

                _calendarsTrashList.add(
                    _getDisplayTrashList(
                        tmpYear,
                        tmpMonth,
                        tmpCalendarDate
                    )
                );
            }
            notifyListeners();
        });
    }

    void forward() {
        _month++;
        if (_month > 12) {
            _month = 1;
            _year++;
        }

        _calendarIndex++;
        _currentPage++;
        print(
            'currentPage: $_currentPage,month:$_month, length: ${_calendarsDateList
                .length}');
        // 最後から一つ前のカレンダーを表示したら1か月分のカレンダーを追加する
        // 同時に先頭から1か月分削除する
        if (_currentPage == _calendarsDateList.length - 2) {
            int nextMonth = _month >= 11 ? 1 + (_month - 11) : _month + 2;
            int nextYear = _month >= 11 ? _year + 1 : _year;
            print('append calendar: $nextMonth');
            List<int> tmpCalendarDate = _calendarUseCase.generateMonthCalendar(
                nextYear, nextMonth);
            _calendarsDateList.add(tmpCalendarDate);
            print(tmpCalendarDate);

            _calendarsTrashList.add(
                _getDisplayTrashList(
                    nextYear,
                    nextMonth,
                    tmpCalendarDate
                )
            );

            _calendarsTrashList.removeAt(0);
            _calendarsDateList.removeAt(0);

            // 現在のページより手前を削除したので現在ページを-1する
            _currentPage--;
            print(
                'removed first, currentPage: $_currentPage,length: ${_calendarsDateList
                    .length}');
        }

        notifyListeners();
    }

    void backward() {
        _month--;
        if (_month < 1) {
            _month = 12;
            _year--;
        }

        _calendarIndex--;
        _currentPage--;
        print(
            'currentPage: $_currentPage,month:$_month, length: ${_calendarsDateList
                .length}');
        // 先頭から2つ目のカレンダーに戻ったら先頭に1か月分のカレンダーを追加する
        // 同時に最後尾の1か月分のカレンダーを削除する
        // ただし先頭が現在月==_calendarIndex=1の場合は何もしない
        if (_currentPage == 1 && _calendarIndex > 1) {
            _calendarsTrashList.removeLast();
            _calendarsDateList.removeLast();

            int beforeMonth = _month <= 2 ? 12 - (2 - _month) : _month - 2;
            int beforeYear = _month <= 2 ? year - 1 : year;

            print('insert calendar: $beforeMonth');
            List<int> tmpCalendarDate = _calendarUseCase.generateMonthCalendar(
                beforeYear, beforeMonth);
            print(tmpCalendarDate);

            _calendarsDateList.insert(0, tmpCalendarDate);
            _calendarsTrashList.insert(
                0, _getDisplayTrashList(
                beforeYear, beforeMonth, tmpCalendarDate
            )
            );
            // 現在ページより前に追加されため_currentPageを+1する
            _currentPage++;
        }
        notifyListeners();
    }

    void reload() {
        _loadingStatus = LoadingStatus.loading;
        _syncResult = SyncResult.skipped;
        notifyListeners();
        _trashDataService.syncTrashData().then((syncResult) {
            _syncResult = syncResult;
            for (int index = 0; index < _calendarsDateList.length; index++) {
                int sub = index - _currentPage;
                int targetMonth = _month + sub;
                int targetYear = _year;
                if (targetMonth > 12) {
                    targetMonth = targetMonth - 12;
                    targetYear++;
                } else if (targetMonth < 1) {
                    targetMonth = 12 - targetMonth;
                    targetYear--;
                }
                _calendarsTrashList[index] = _getDisplayTrashList(
                    targetYear, targetMonth, _calendarsDateList[index ]);
            }
            _logger.d("reload complete");
            _loadingStatus = LoadingStatus.loaded;
            notifyListeners();
        });
    }

    List<List<DisplayTrashData>> _getDisplayTrashList(int year, int month, List<int> dateList) {
        return _trashDataService.getEnableTrashList(
            year: year,
            month: month,
            targetDateList: dateList
        ).map((List<TrashData> weekList) =>
            weekList.map((TrashData trashData)=>
                DisplayTrashData(trashData.type, _trashDataService.getTrashName(
                    type: trashData.type, trashVal: trashData.trashVal
                ))
            ).toList()
        ).toList();
    }

    bool isLoading() {
        return _loadingStatus == LoadingStatus.loading;
    }
}