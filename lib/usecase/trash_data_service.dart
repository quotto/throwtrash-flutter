//TODO: DIでデータ取得用repositoryが必要
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/repository/trash_api_interface.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class TrashDataService implements TrashDataServiceInterface {
  List<TrashData> _schedule = [];
  final UserServiceInterface _userService;
  final TrashRepositoryInterface _trashRepository;
  final TrashApiInterface _trashApiInterface;
  final _logger = Logger();

  TrashDataService(this._userService,this._trashRepository, this._trashApiInterface) {
    refreshTrashData();
  }

  final List<List<int>> _weekdayOfPosition = [
    [0,7,14,21,28],
    [1,8,15,22,29],
    [2,9,16,23,30],
    [3,10,17,24,31],
    [4,11,18,25,32],
    [5,12,19,26,33],
    [6,13,20,27,34]
  ];

  static Map<String,String> _trashNameMap = {
    "burn": "もえるゴミ",
    "unburn": "もえないゴミ",
    "plastic": "プラスチック",
    "bin": "ビン",
    "can": "カン",
    "petbottle": "ペットボトル",
    "paper": "古紙",
    "resource": "資源ごみ",
    "coarse": "粗大ごみ",
    "other": "その他"
  };

  @override
  static Map<String, String> get TrashNameMap => _trashNameMap;

  @override
  List<TrashData> get allTrashList => _schedule;

  @override
  Future<bool> refreshTrashData() {
    return _trashRepository.readAllTrashData().then((allTrashData) {
      _schedule = allTrashData;
      return true;
    });
  }

  // TODO: 後で消す
  set schedule(testData) => _schedule=testData;

  @override
  String getTrashName({String type='', String trashVal=''}) {
    if(type == "other") {
      return trashVal;
    } else{
      return _trashNameMap[type] != null ? _trashNameMap[type]! : '';
    }
  }


  /// @param month 月（Calendarではなく通常の数え月）
  @override
  DateTime _getComputeCalendar({required int year, required int month, required int date, required int pos}) {
    int actualMonth = month;
    if(pos < 7 && date > 7) {
      actualMonth = month - 1;
    } else if(pos > 27 && date < 7) {
      actualMonth = month+1;
    }

    return new DateTime(year,actualMonth, date);
  }

  /// dateとposの情報から当該月の前月/当月/翌月を判定してその月を返す
  /// @param month 判定対象の月
  /// @param date 判定対象の日
  /// @param pos カレンダー上の月日の位置インデックス
  int _getActualMonth({required int month, required int date, required int pos}) {
    if (pos < 7 && date > 7) {
      return month - 1 == 0 ? 12 : month - 1;
    } else if (pos > 27 && date < 7) {
      return month + 1 == 13 ? 1 : month + 1;
    }
    return month;
  }

  /// 登録スケジュールの件数を返す
  @override
  int getScheduleCount() {
    return _schedule.length;
  }

  /// 新しいゴミ出し予定を追加する
  @override
  Future<bool> addTrashData(TrashData trashData)  async {
    bool result = await _trashRepository.insertTrashData(trashData);
    if(result) {
      refreshTrashData();
      int lastUpdateTimeStamp = await _updateAllTrashData();
      _trashRepository.updateLastUpdateTime(lastUpdateTimeStamp);
    }
    return result;
  }

  @override
  Future<bool> updateTrashData(TrashData trashData) async {
    bool result = await _trashRepository.updateTrashData(trashData);
    if(result) {
      refreshTrashData();
      int lastUpdateTimeStamp = await _updateAllTrashData();
      _trashRepository.updateLastUpdateTime(lastUpdateTimeStamp);
    }
    return result;
  }

  @override
  Future<bool> deleteTrashData(String id) async {
    bool result = await _trashRepository.deleteTrashData(id);
    if(result) {
      refreshTrashData();
      int lastUpdateTimeStamp = await _updateAllTrashData();
      _trashRepository.updateLastUpdateTime(lastUpdateTimeStamp);
    }
    return result;
  }

  Future<int> _updateAllTrashData() async {
    List<TrashData> allTrashList = await _trashRepository.readAllTrashData();
    int lastUpdateTimeStamp = 0;
    if (_userService.user.id.isEmpty) {
      // ユーザーIDがローカルに保存されていなければAPIに対して新規登録する
      _logger.d("User is not registered, register trash data");
      RegisterResponse? registerResponse = await _trashApiInterface.registerUserAndTrashData(allTrashList);
      if(registerResponse != null) {
        lastUpdateTimeStamp = registerResponse.timestamp;
        if(await _userService.registerUser(registerResponse.id)){
          await _userService.refreshUser();
        }
      }
    } else {
      // ユーザーIDがローカルに保存されていればAPIに対して更新する
      _logger.d("User is registered, update trash data");
      int? resultUpdateTime = await _trashApiInterface.updateTrashData(_userService.user.id,allTrashList);
      if(resultUpdateTime != null) {
        lastUpdateTimeStamp = resultUpdateTime;
      }
    }

    // APIによる更新がエラー（タイムスタンプが0）の場合はローカルのタイムスタンプを採用する
    if(lastUpdateTimeStamp == 0) {
      lastUpdateTimeStamp = DateTime.now().millisecondsSinceEpoch;
    }
    return lastUpdateTimeStamp;
  }


  /// 5週間分全てのゴミを返す
  /// @param
  /// month 計算対象（現在CalendarViewに設定されている月。1月スタート）
  /// dataSet カレンダーに表示する日付のリスト
  ///
  /// @return カレンダーのポジションごとのゴミ捨てリスト
  @override
  List<List<String>> getEnableTrashList(
      {required int year, required int month, required List<int> targetDateList
      }) {
    List<List<String>> resultArray = new List.generate(35,(index)=>[]);

    _schedule.forEach((trash) {
      String trashName = getTrashName(type: trash.type, trashVal: trash.trash_val);
      List<String> excludeList = trash.excludes.map((excludeDate) {
        return "${excludeDate.month}-${excludeDate.date}";
      }).toList();
      trash.schedules.forEach((schedule) {
        switch (schedule.type) {
          case 'weekday':
            _weekdayOfPosition[int.parse((schedule.value as String))].forEach((
                pos) {
              if (!excludeList.contains(
                  "${_getActualMonth(month: month,
                      date: targetDateList[pos],
                      pos: pos)}-${targetDateList[pos]}"
              )) {
                resultArray[pos].add(trashName);
              }
            });
            break;
          case 'month':
            int pos = 0;
            targetDateList.forEach((date) {
              if (int.parse(schedule.value) == date) {
                if (!excludeList.contains(
                    "${_getActualMonth(month: month,
                        date: targetDateList[pos],
                        pos: pos)}-$date")) {
                  resultArray[pos].add(trashName);
                }
              }
              pos++;
            });
            break;
          case 'biweek':
            List<String> dayOfWeek = schedule.value.split("-");
            if (dayOfWeek.length == 2) {
              _weekdayOfPosition[int.parse(dayOfWeek[0])].forEach((pos) {
                DateTime computeCalendar = _getComputeCalendar(
                    year: year,
                    month: month,
                    date: targetDateList[pos],
                    pos: pos);
                if (int.parse(dayOfWeek[1]) == (computeCalendar.day/7).ceil()) {
                  if (!excludeList.contains(
                      "${_getActualMonth(month: month,
                          date: targetDateList[pos],
                          pos: pos)}-${targetDateList[pos]}")) {
                    resultArray[pos].add(trashName);
                  }
                }
              });
            }
            break;
          case 'evweek':
            if (schedule.value['start'] != null &&
                schedule.value['weekday'] != null) {
              String startDate = schedule.value['start'];
              int weekday = int.parse(schedule.value['weekday']);
              _weekdayOfPosition[weekday].forEach((pos) {
                int interval = schedule.value['interval'] != null ? schedule
                    .value['interval'] : 2;

                // カレンダーの1週目および5週目は月が変わっている日にちがあるため
                // カレンダー上のインデックスと日付の関係からカレンダー上の日付の実際の月を求める
                int actualMonth = _getActualMonth(month: month, date: targetDateList[pos],
                    pos: pos);
                // actualMonth≠monthとなった場合、年が前年または翌年の可能性があるため実際の年を求める
                int actualYear = actualMonth == 12 && month == 1 ? year - 1 :
                                  (actualMonth == 1 && month == 12 ? year + 1 : year);
                // ISO8601形式とするため、月日を0埋めする
                String strTargetDate = _convertISO8601(year: actualYear, month: month, date: targetDateList[pos]);
                if (_isEvWeek(
                    startDate, strTargetDate, interval) &&
                    !excludeList.contains(
                        "$actualMonth-${targetDateList[pos]}")
                ) {
                  resultArray[pos].add(trashName);
                }
              });
            }
            break;
        }
      });
    });
    return resultArray;
  }

  bool _isEvWeek(String startDate, String targetDate, int interval) {
    DateTime startCal = DateTime.parse(startDate);
    DateTime targetCal = DateTime.parse(targetDate);
    int targetWeekday = targetCal.weekday == 7 ? 0 : targetCal.weekday;
    targetCal = targetCal.add(Duration(days: -1 * targetWeekday));
    int diffDate = ((targetCal.millisecondsSinceEpoch - startCal.millisecondsSinceEpoch) / 1000 / 60 / 60 / 24).round();
    return diffDate % interval == 0;
  }

  @override
  List<TrashData> getTrashOfToday({required int year, required int month, required int date}) {
    _logger.d("get trash at $year/$month/$date");
    List<TrashData> matchList = _schedule.where((trashData)=>trashData.isMatchOfDay(year, month, date)).toList();
    return matchList;
  }

  String _convertISO8601({required int year, required int month, required int date}) {
    // ISO8601形式とするため、月日を0埋めする
    String strMonth = month < 10 ? '0$month' : month.toString();
    String strDate = date < 10 ? '0$date' : date.toString();
    return '$year-$strMonth-$strDate';
  }

  @override
  TrashData? getTrashDataById(String id) {
    for(int index=0; index<_schedule.length; index++) {
      if(_schedule[index].id == id) {
        return _schedule[index];
      }
    }
    return null;
  }

  @override
  void importTrashSchedule(List<TrashData> allTrashData, updateTime) async {
    _trashRepository.truncateAllTrashData();

    List<Future<bool>> taskList = [];
    allTrashData.forEach((trashData) {
      taskList.add(_trashRepository.insertTrashData(trashData));
    });
    await Future.wait(taskList);

    await _trashRepository.updateLastUpdateTime(updateTime);
  }

  @override
  void syncFromRemote() {
    // TODO: implement syncFromRemote
  }

  @override
  void syncToRemote() {
    // TODO: implement syncToRemote
  }
}