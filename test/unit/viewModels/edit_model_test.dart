import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/crash_report_interface.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'edit_model_test.mocks.dart';

@GenerateMocks([CrashReportInterface])
void main(){
  SharedPreferences.setMockInitialValues({});
  final _crashReport = MockCrashReportInterface();
  TrashDataServiceInterface _trashDataService =
  TrashDataService(
    UserService(UserRepository()),
    TrashRepository(),
    TrashApi("", http.Client()),
    _crashReport
  );

  test('初期状態のテスト',(){
    EditModel model = EditModel(_trashDataService);
    expect(model.trash.id.length, 13);
    expect(model.trash.type, 'burn');
    expect(model.schedules.length, 1);
    expect(model.schedules[0].type, 'weekday');
    expect(model.schedules[0].value, '0');
  });
  group('addSchedule',() {
    test('スケジュール追加時の初期値はweekday', () {
      EditModel model = EditModel(_trashDataService);
      model.addSchedule();
      expect(model.schedules.length, 2);
      expect(model.schedules[1].type, 'weekday');
      expect(model.schedules[1].value, '0');
    });
  });
  group('changeScheduleType',() {
    test('weekdayの初期値は0', () {
      EditModel model = EditModel(_trashDataService);
      model.changeScheduleType(0, 'weekday');
      expect(model.schedules[0].type, 'weekday');
      expect(model.schedules[0].value, '0');
    });
    test('monthの初期値は1', () {
      EditModel model = EditModel(_trashDataService);
      model.changeScheduleType(0, 'month');
      expect(model.schedules[0].type, 'month');
      expect(model.schedules[0].value, '1');
    });
    test('biweekの初期値は0-1', () {
      EditModel model = EditModel(_trashDataService);
      model.changeScheduleType(0, 'biweek');
      expect(model.schedules[0].type, 'biweek');
      expect(model.schedules[0].value, '0-1');
    });
    test('evweekの初期値はweekday=0,interval=2,start=現在年月日', () {
      EditModel model = EditModel(_trashDataService);
      model.changeScheduleType(0, 'evweek');
      expect(model.schedules[0].type, 'evweek');
      expect(model.schedules[0].value['weekday'], '0');
      expect(model.schedules[0].value['interval'], 2);
      expect(model.schedules[0].value['start'],
          DateTime.now().toIso8601String().substring(0, 10));
    });
  });
  group('removeSchedule',(){
    test('スケジュールが正しく削除されること',(){
      EditModel model = EditModel(_trashDataService);
      model.addSchedule();
      model.changeScheduleType(0, 'month');
      model.removeSchedule(0);
      expect(model.schedules[0].type, 'weekday');
    });
    test('スケジュールが1件のみの場合は削除しない',(){
      EditModel model = EditModel(_trashDataService);
      model.removeSchedule(0);
      expect(model.schedules.length, 1);
    });
  });
  group('changeTrashType',(){
    test('TrashData.typeが変更される',()
    {
      EditModel model = EditModel(_trashDataService);
      model.changeTrashType('paper');
      expect(model.trash.type, 'paper');
    });
    test('TrashData.trash_valが変更される',(){
      EditModel model = EditModel(_trashDataService);
      model.changeTrashType('other');
      model.changeTrashName('段ボール');
      expect(model.trash.trashVal, '段ボール');
    });
  });
}