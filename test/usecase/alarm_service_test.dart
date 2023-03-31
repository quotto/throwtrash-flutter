import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/repository/alarm_repository.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/alarm_service.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/user_service.dart';

void main() {
  setUp(() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    SharedPreferences.setMockInitialValues({});
  });
  final _alarmService = AlarmService(
    UserService(UserRepository()),
    AlarmRepository(),
    TrashDataService(
      UserService(UserRepository()),
      TrashRepository(),
      TrashApi("")
    )
  );
  group("アラームメッセージの取得",(){
    test("一致するゴミが複数ある",(){
      List<TrashData> list = [
        TrashData(id: "",type: "burn", trashVal: "", schedules: [],excludes: []),
        TrashData(id: "",type: "other", trashVal: "生ごみ",schedules: [],excludes: [])
      ];
      expect(
        _alarmService.createAlarmMessage(list),
        "もえるゴミ\n生ごみ"
      );
    });
    test("一致するゴミが1つある",(){
      List<TrashData> list = [
        TrashData(id: "",type: "petbottle", trashVal: "", schedules: [],excludes: []),
      ];
      expect(
          _alarmService.createAlarmMessage(list),
          "ペットボトル"
      );
    });
    test("一致するゴミが無い",(){
      List<TrashData> list = [
      ];
      expect(
          _alarmService.createAlarmMessage(list),
          "今日出せるゴミはありません"
      );
    });
  });
}