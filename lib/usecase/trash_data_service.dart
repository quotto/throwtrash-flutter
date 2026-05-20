import 'package:logger/logger.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_import_message.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_search_result.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/usecase/repository/fcm_interface.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/repository/trash_api_interface.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

import '../models/calendar_model.dart';
import 'repository/crash_report_interface.dart';

export 'package:throwtrash/models/trash_search_result.dart';

class TrashDataService implements TrashDataServiceInterface {
  List<TrashData> _schedule = [];
  List<ExcludeDate> _globalExcludeDates = [];
  final UserServiceInterface _userService;
  final TrashRepositoryInterface _trashRepository;
  final TrashApiInterface _trashApiInterface;
  final FcmInterface? _fcmService;
  final _logger = Logger();
  final CrashReportInterface _crashReport;

  TrashDataService(
    this._userService,
    this._trashRepository,
    this._trashApiInterface,
    this._crashReport, [
    this._fcmService,
  ]) {
    refreshTrashData();
  }

  final List<List<int>> _weekdayOfPosition = [
    [0, 7, 14, 21, 28],
    [1, 8, 15, 22, 29],
    [2, 9, 16, 23, 30],
    [3, 10, 17, 24, 31],
    [4, 11, 18, 25, 32],
    [5, 12, 19, 26, 33],
    [6, 13, 20, 27, 34],
  ];

  static final Map<String, String> _trashNameMap = {
    "burn": "もえるゴミ",
    "unburn": "もえないゴミ",
    "plastic": "プラスチック",
    "bin": "ビン",
    "can": "カン",
    "petbottle": "ペットボトル",
    "paper": "古紙",
    "resource": "資源ごみ",
    "coarse": "粗大ごみ",
    "other": "その他",
  };

  static Map<String, String> get trashNameMap => _trashNameMap;

  @override
  List<TrashData> get allTrashList => _schedule;

  @override
  List<ExcludeDate> get globalExcludeDates => _globalExcludeDates;

  @override
  Future<bool> refreshTrashData() async {
    final results = await Future.wait([
      _trashRepository.readAllTrashData(),
      _trashRepository.readGlobalExcludeDates(),
    ]);
    _schedule = results[0] as List<TrashData>;
    _globalExcludeDates = results[1] as List<ExcludeDate>;
    return true;
  }

  @override
  String getTrashName({String type = '', String trashVal = ''}) {
    if (type == "other") {
      return trashVal;
    } else {
      return _trashNameMap[type] != null ? _trashNameMap[type]! : '';
    }
  }

  /// 登録スケジュールの件数を返す
  @override
  int getScheduleCount() {
    return _schedule.length;
  }

  @override
  TrashData? getTrashDataById(String id) {
    for (int index = 0; index < _schedule.length; index++) {
      if (_schedule[index].id == id) {
        return _schedule[index];
      }
    }
    return null;
  }

  /// 新しいゴミ出し予定を追加する
  @override
  Future<bool> addTrashData(TrashData trashData) async {
    final result =
        await _trashRepository.insertTrashData(trashData) &&
        await _changeSyncStatusToSyncing();
    if (result) {
      _schedule.add(trashData);
    }
    return result;
  }

  @override
  Future<bool> updateTrashData(TrashData trashData) async {
    final result =
        await _trashRepository.updateTrashData(trashData) &&
        await _changeSyncStatusToSyncing();
    if (result) {
      final index = _schedule.indexWhere(
        (element) => element.id == trashData.id,
      );
      if (index >= 0) {
        _schedule[index] = trashData;
      }
    }
    return result;
  }

  @override
  Future<bool> updateGlobalExcludeDates(List<ExcludeDate> excludeDates) async {
    if (excludeDates.length > 10) {
      return false;
    }
    final result = await _trashRepository.writeGlobalExcludeDates(excludeDates);
    if (!result) {
      return false;
    }
    _globalExcludeDates = excludeDates;
    return await _changeSyncStatusToSyncing();
  }

  @override
  Future<bool> deleteTrashData(String id) async {
    final result =
        await _trashRepository.deleteTrashData(id) &&
        await _changeSyncStatusToSyncing();
    if (result) {
      _schedule.removeWhere((element) => element.id == id);
    }
    return result;
  }

  Future<bool> _changeSyncStatusToSyncing() async {
    return _trashRepository.setSyncStatus(SyncStatus.SYNCING);
  }

  @override
  TrashSearchInputType classifySearchInput(String input) {
    final postalCodePattern = RegExp(r'^\d{3}-?\d{4}$');
    return postalCodePattern.hasMatch(input.trim())
        ? TrashSearchInputType.postalCode
        : TrashSearchInputType.address;
  }

  @override
  Future<TrashImportResult> importTrashSchedule(String input) async {
    final trimmedInput = input.trim();
    final searchResult = await _trashApiInterface.searchTrashSchedule(
      trimmedInput,
      classifySearchInput(trimmedInput),
    );
    if (!searchResult.success) {
      await _trashRepository.saveImportMessage(
        TrashImportMessage.error(searchResult.message),
      );
      await _fcmService?.showLocalNotification('自動取り込み', searchResult.message);
      return TrashImportResult.failure(searchResult.message);
    }

    final replaceResult = await _trashRepository.replaceAllTrashData(
      searchResult.trashes,
    );
    if (!replaceResult) {
      final message = '自動取り込み結果の保存に失敗しました。';
      await _trashRepository.saveImportMessage(
        TrashImportMessage.error(message),
      );
      await _fcmService?.showLocalNotification('自動取り込み', message);
      return TrashImportResult.failure(message);
    }
    await _changeSyncStatusToSyncing();
    await refreshTrashData();
    final importResult = TrashImportResult.success(searchResult.message);
    await _trashRepository.saveImportMessage(
      TrashImportMessage.success(importResult.message),
    );
    await _fcmService?.showLocalNotification('自動取り込み', importResult.message);
    return importResult;
  }

  @override
  Future<bool> shouldShowInitialSearchDialog() {
    return _trashRepository.shouldShowInitialSearchDialog();
  }

  @override
  Future<bool> markInitialSearchDialogShown() {
    return _trashRepository.markInitialSearchDialogShown();
  }

  @override
  Future<TrashImportMessage?> consumeImportMessage() {
    return _trashRepository.consumeImportMessage();
  }

  /// 5週間分全てのゴミを返す
  /// @param
  /// month 計算対象（現在CalendarViewに設定されている月。1月スタート）
  /// dataSet カレンダーに表示する日付のリスト
  ///
  /// @return カレンダーのポジションごとのゴミ捨てリスト
  @override
  List<List<TrashData>> getEnableTrashList({
    required int year,
    required int month,
    required List<int> targetDateList,
  }) {
    List<List<TrashData>> resultArray = List.generate(35, (index) => []);

    for (var trash in _schedule) {
      List<String> excludeList = trash.excludes.map((excludeDate) {
        return "${excludeDate.month}-${excludeDate.date}";
      }).toList();
      for (var schedule in trash.schedules) {
        switch (schedule.type) {
          case 'weekday':
            for (var pos
                in _weekdayOfPosition[int.parse((schedule.value as String))]) {
              final actualMonth = _getActualMonth(
                month: month,
                date: targetDateList[pos],
                pos: pos,
              );
              if (!_isExcludedDate(
                excludeList,
                actualMonth,
                targetDateList[pos],
              )) {
                resultArray[pos].add(trash);
              }
            }
            break;
          case 'month':
            int pos = 0;
            for (var date in targetDateList) {
              if (int.parse(schedule.value) == date) {
                final actualMonth = _getActualMonth(
                  month: month,
                  date: targetDateList[pos],
                  pos: pos,
                );
                if (!_isExcludedDate(excludeList, actualMonth, date)) {
                  resultArray[pos].add(trash);
                }
              }
              pos++;
            }
            break;
          case 'biweek':
            List<String> dayOfWeek = schedule.value.split("-");
            if (dayOfWeek.length == 2) {
              for (var pos in _weekdayOfPosition[int.parse(dayOfWeek[0])]) {
                DateTime computeCalendar = _getComputeCalendar(
                  year: year,
                  month: month,
                  date: targetDateList[pos],
                  pos: pos,
                );
                if (int.parse(dayOfWeek[1]) ==
                    (computeCalendar.day / 7).ceil()) {
                  final actualMonth = _getActualMonth(
                    month: month,
                    date: targetDateList[pos],
                    pos: pos,
                  );
                  if (!_isExcludedDate(
                    excludeList,
                    actualMonth,
                    targetDateList[pos],
                  )) {
                    resultArray[pos].add(trash);
                  }
                }
              }
            }
            break;
          case 'evweek':
            if (schedule.value['start'] != null &&
                schedule.value['weekday'] != null) {
              String startDate = schedule.value['start'];
              int weekday = int.parse(schedule.value['weekday']);
              for (var pos in _weekdayOfPosition[weekday]) {
                int interval = schedule.value['interval'] ?? 2;

                // カレンダーの1週目および5週目は月が変わっている日にちがあるため
                // カレンダー上のインデックスと日付の関係からカレンダー上の日付の実際の月を求める
                int actualMonth = _getActualMonth(
                  month: month,
                  date: targetDateList[pos],
                  pos: pos,
                );
                // actualMonth≠monthとなった場合、年が前年または翌年の可能性があるため実際の年を求める
                int actualYear = actualMonth == 12 && month == 1
                    ? year - 1
                    : (actualMonth == 1 && month == 12 ? year + 1 : year);
                // ISO8601形式とするため、月日を0埋めする
                String strTargetDate = _convertISO8601(
                  year: actualYear,
                  month: actualMonth,
                  date: targetDateList[pos],
                );
                if (_isEvWeek(startDate, strTargetDate, interval) &&
                    !_isExcludedDate(
                      excludeList,
                      actualMonth,
                      targetDateList[pos],
                    )) {
                  resultArray[pos].add(trash);
                }
              }
            }
            break;
        }
      }
    }
    return resultArray;
  }

  /// @param month 月（Calendarではなく通常の数え月）
  DateTime _getComputeCalendar({
    required int year,
    required int month,
    required int date,
    required int pos,
  }) {
    int actualMonth = month;
    if (pos < 7 && date > 7) {
      actualMonth = month - 1;
    } else if (pos > 27 && date < 7) {
      actualMonth = month + 1;
    }

    return DateTime(year, actualMonth, date);
  }

  /// dateとposの情報から当該月の前月/当月/翌月を判定してその月を返す
  /// @param month 判定対象の月
  /// @param date 判定対象の日
  /// @param pos カレンダー上の月日の位置インデックス
  int _getActualMonth({
    required int month,
    required int date,
    required int pos,
  }) {
    if (pos < 7 && date > 7) {
      return month - 1 == 0 ? 12 : month - 1;
    } else if (pos > 27 && date < 7) {
      return month + 1 == 13 ? 1 : month + 1;
    }
    return month;
  }

  bool _isEvWeek(String startDate, String targetDate, int interval) {
    // Web,Androidアプリでは日付フォーマットをyyyy-m-ddの形式で設定するが、
    // DartのDateTime.parseではそのフォーマットがエラーとなるため数字に分解して計算する
    List<String> startDates = startDate.split("-");
    DateTime startCal = DateTime.utc(
      int.parse(startDates[0]),
      int.parse(startDates[1]),
      int.parse(startDates[2]),
    );
    DateTime targetCal = DateTime.parse(targetDate);
    int targetWeekday = targetCal.weekday == 7 ? 0 : targetCal.weekday;
    targetCal = targetCal.add(Duration(days: -1 * targetWeekday));
    int diffDate =
        ((targetCal.millisecondsSinceEpoch - startCal.millisecondsSinceEpoch) /
                1000 /
                60 /
                60 /
                24)
            .round();
    return diffDate % interval == 0;
  }

  @override
  List<TrashData> getTrashOfToday({
    required int year,
    required int month,
    required int date,
  }) {
    _logger.d("get trash at $year/$month/$date");
    if (_isGlobalExcludeDate(month, date)) {
      return [];
    }
    List<TrashData> matchList = _schedule
        .where((trashData) => trashData.isMatchOfDay(year, month, date))
        .toList();
    return matchList;
  }

  bool _isExcludedDate(List<String> localExcludeList, int month, int date) {
    if (localExcludeList.contains("$month-$date")) {
      return true;
    }
    return _isGlobalExcludeDate(month, date);
  }

  bool _isGlobalExcludeDate(int month, int date) {
    return _globalExcludeDates.any((excludeDate) {
      return excludeDate.month == month && excludeDate.date == date;
    });
  }

  String _convertISO8601({
    required int year,
    required int month,
    required int date,
  }) {
    // ISO8601形式とするため、月日を0埋めする
    String strMonth = month < 10 ? '0$month' : month.toString();
    String strDate = date < 10 ? '0$date' : date.toString();
    return '$year-$strMonth-$strDate';
  }

  Future<void> _registerNewUserAndTrashDataList() async {
    List<TrashData> localTrashList = await _trashRepository.readAllTrashData();
    RegisterResponse? registerResponse = await _trashApiInterface
        .registerUserAndTrashData(localTrashList);
    if (registerResponse == null) {
      _logger.e('Failed register new user and trash data list');
      _crashReport.reportCrash(
        Exception('Failed register new user and trash data list'),
        fatal: true,
      );
      return;
    } else {
      _logger.d(
        'Register user: ${registerResponse.id}, timestamp: ${registerResponse.timestamp}',
      );
      await _trashRepository.updateLastUpdateTime(registerResponse.timestamp);
      await _userService.registerUser(registerResponse.id);
      _userService.refreshUser();
    }
  }

  Future<void> _updateLocalTimestamp(int remoteTimestamp) async {
    await _trashRepository.updateLastUpdateTime(remoteTimestamp);
  }

  Future<void> _syncRemoteToLocal(
    List<TrashData> remoteTrashDataList,
    List<ExcludeDate> remoteGlobalExcludes,
    int remoteTimestamp,
  ) async {
    await _trashRepository.updateLastUpdateTime(remoteTimestamp);
    await _trashRepository.truncateAllTrashData();
    await _trashRepository.writeGlobalExcludeDates(remoteGlobalExcludes);
    List<Future> insertFutures = [];
    for (var trashData in remoteTrashDataList) {
      insertFutures.add(_trashRepository.insertTrashData(trashData));
    }
    await Future.wait(insertFutures);
  }

  Future<SyncResult> _syncTrashData() async {
    List<TrashData> localSchedule = await _trashRepository.readAllTrashData();
    List<ExcludeDate> localGlobalExcludes = await _trashRepository
        .readGlobalExcludeDates();
    if (localSchedule.isEmpty && localGlobalExcludes.isEmpty) {
      _logger.w(
        'Not update local to remote because local schedule is nothing.',
      );
      return SyncResult.skipped;
    }

    TrashSyncResult trashSyncResult = await _trashApiInterface.syncTrashData(
      _userService.user.id,
    );
    if (trashSyncResult.syncResult == TrashApiSyncStatus.ERROR) {
      _logger.e('Failed sync, please try later.');
      _crashReport.reportCrash(Exception('Failed sync'), fatal: true);
      return SyncResult.failed;
    }

    int localTimestamp = await _trashRepository.getLastUpdateTime();
    _logger.d('Local Timestamp=$localTimestamp');

    SyncResult syncResult = SyncResult.skipped;
    if (trashSyncResult.timestamp == localTimestamp &&
        await _trashRepository.getSyncStatus() == SyncStatus.SYNCING) {
      final response = await _trashApiInterface.updateTrashData(
        _userService.user.id,
        localSchedule,
        localGlobalExcludes,
        localTimestamp,
      );
      switch (response.updateResult) {
        case UpdateResult.SUCCESS:
          _logger.d("Update succeed local to remote");
          await _updateLocalTimestamp(response.timestamp);
          // 同期ステータスを同期済みにする
          await _trashRepository.setSyncStatus(SyncStatus.COMPLETE);
          syncResult = SyncResult.success;
          break;
        case UpdateResult.NO_MATCH:
          // 同期確認からアップデートの間に他のユーザーがデータを更新したケース
          _logger.d(
            'Local timestamp $localTimestamp is not match remote timestamp ${response.timestamp},try sync to local from remote',
          );
          await _syncRemoteToLocal(
            trashSyncResult.allTrashDataList,
            trashSyncResult.globalExcludes,
            trashSyncResult.timestamp,
          );
          await refreshTrashData();
          // 同期ステータスを同期済みにする
          await _trashRepository.setSyncStatus(SyncStatus.COMPLETE);
          syncResult = SyncResult.rollback;
          break;
        default:
          _logger.e('Failed update to remote from local, please try later.');
          _crashReport.reportCrash(
            Exception('Failed update to remote from local'),
            fatal: true,
          );
          syncResult = SyncResult.failed;
          break;
      }
    } else if (trashSyncResult.timestamp != localTimestamp) {
      _logger.d(
        'Local timestamp $localTimestamp is not match remote timestamp ${trashSyncResult.timestamp},try sync to local from remote',
      );
      await _syncRemoteToLocal(
        trashSyncResult.allTrashDataList,
        trashSyncResult.globalExcludes,
        trashSyncResult.timestamp,
      );
      syncResult = SyncResult.rollback;
    } else {
      _logger.d('Local timestamp equal remote timestamp, skip update.');
      syncResult = SyncResult.skipped;
    }
    await refreshTrashData();
    return syncResult;
  }

  @override
  Future<SyncResult> syncTrashData() async {
    if (_userService.user.id.isEmpty) {
      _logger.d('User is empty, register new user');
      await _registerNewUserAndTrashDataList();
    }
    _logger.d('Sync data');
    return await _syncTrashData();
  }
}
