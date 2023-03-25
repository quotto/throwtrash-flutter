import 'package:throwtrash/models/trash_data.dart';

abstract class TrashDataServiceInterface {
  static Map<String, String> get trashNameMap=> {};

  Future<bool> refreshTrashData();

  List<TrashData> get allTrashList;
  String getTrashName({String type='', String trashVal=''});

  /// 登録スケジュールの件数を返す
  int getScheduleCount();

  /// 新しいゴミ出し予定を追加する
  Future<bool> addTrashData(TrashData trashData);
  Future<bool> deleteTrashData(String id);
  TrashData? getTrashDataById(String id);
  Future<bool> updateTrashData(TrashData trashData);
  Future<void> syncTrashData();

  /// 5週間分全てのゴミを返す
  /// @param
  /// month 計算対象（現在CalendarViewに設定されている月。1月スタート）
  /// dataSet カレンダーに表示する日付のリスト
  ///
  /// @return カレンダーのポジションごとのゴミ捨てリスト
  List<List<TrashData>> getEnableTrashList(
      {required int year, required int month, required List<int> targetDateList
      });

  List<TrashData> getTrashOfToday({required int year, required int month, required int date});
}