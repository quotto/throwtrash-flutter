import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/repository/crash_report_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:test/test.dart';

import 'edit_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CrashReportInterface>(),
  MockSpec<TrashDataServiceInterface>(),
])
void main() {
  SharedPreferences.setMockInitialValues({});
  MockTrashDataServiceInterface _trashDataService =
      MockTrashDataServiceInterface();

  test('初期状態のテスト', () {
    EditModel model = EditModel(_trashDataService);
    expect(model.trash.id.length, 13);
    expect(model.trash.type, 'burn');
    expect(model.schedules.length, 1);
    expect(model.schedules[0].type, 'weekday');
    expect(model.schedules[0].value, '0');
  });
  group('addSchedule', () {
    test('スケジュール追加時の初期値はweekday', () {
      EditModel model = EditModel(_trashDataService);
      model.addSchedule();
      expect(model.schedules.length, 2);
      expect(model.schedules[1].type, 'weekday');
      expect(model.schedules[1].value, '0');
    });
  });
  group('changeScheduleType', () {
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
      expect(
        model.schedules[0].value['start'],
        DateTime.now().toIso8601String().substring(0, 10),
      );
    });
  });
  group('removeSchedule', () {
    test('スケジュールが正しく削除されること', () {
      EditModel model = EditModel(_trashDataService);
      model.addSchedule();
      model.changeScheduleType(0, 'month');
      model.removeSchedule(0);
      expect(model.schedules[0].type, 'weekday');
    });
    test('スケジュールが1件のみの場合は削除しない', () {
      EditModel model = EditModel(_trashDataService);
      model.removeSchedule(0);
      expect(model.schedules.length, 1);
    });
  });
  group('changeTrashType', () {
    test('TrashData.typeが変更される', () {
      EditModel model = EditModel(_trashDataService);
      model.changeTrashType('paper');
      expect(model.trash.type, 'paper');
    });
    test('TrashData.trash_valが変更される', () {
      EditModel model = EditModel(_trashDataService);
      model.changeTrashType('other');
      model.changeTrashName('段ボール');
      expect(model.trash.trashVal, '段ボール');
    });
  });
  group('loadModel', () {
    test('取得したデータで編集対象が更新される', () {
      TrashData trashData = TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [TrashSchedule('weekday', '0')],
        excludes: [],
      );
      when(_trashDataService.getTrashDataById('001')).thenReturn(trashData);

      EditModel model = EditModel(_trashDataService);
      bool result = model.loadModel('001');

      expect(result, true);
      expect(model.trash.type, 'other');
      expect(model.trash.trashVal, '家電');
    });

    test('データが存在しない場合はfalseを返す', () {
      when(_trashDataService.getTrashDataById('404')).thenReturn(null);

      EditModel model = EditModel(_trashDataService);
      bool result = model.loadModel('404');

      expect(result, false);
    });
  });
  group('loadCopiedModel', () {
    test('取得したデータを新規IDのNEWデータとしてコピーする', () {
      TrashData trashData = TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [
          TrashSchedule('weekday', '0'),
          TrashSchedule('evweek', {
            'weekday': '1',
            'interval': 2,
            'start': '2026-05-03',
          }),
        ],
        excludes: [ExcludeDate(12, 31)],
      );
      when(_trashDataService.getTrashDataById('001')).thenReturn(trashData);

      EditModel model = EditModel(_trashDataService);
      bool result = model.loadCopiedModel('001');

      expect(result, true);
      expect(model.editType, EditType.NEW);
      expect(model.trash.id, isNot('001'));
      expect(model.trash.type, 'other');
      expect(model.trash.trashVal, '家電');
      expect(model.schedules.length, 2);
      expect(model.schedules[0].type, 'weekday');
      expect(model.schedules[0].value, '0');
      expect(model.schedules[1].type, 'evweek');
      expect(model.schedules[1].value['weekday'], '1');
      expect(model.schedules[1].value['interval'], 2);
      expect(model.schedules[1].value['start'], '2026-05-03');
      expect(model.excludes.length, 1);
      expect(model.excludes[0].month, 12);
      expect(model.excludes[0].date, 31);
    });

    test('コピー後の変更がコピー元データに影響しない', () {
      TrashData trashData = TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [
          TrashSchedule('evweek', {
            'weekday': '1',
            'interval': 2,
            'start': '2026-05-03',
          }),
        ],
        excludes: [ExcludeDate(12, 31)],
      );
      when(_trashDataService.getTrashDataById('001')).thenReturn(trashData);

      EditModel model = EditModel(_trashDataService);
      model.loadCopiedModel('001');
      model.changeEvweekValue(0, '3', 4, '2026-06-01');
      model.setExcludeDate([
        [1, 1],
      ]);

      expect(trashData.schedules[0].value['weekday'], '1');
      expect(trashData.schedules[0].value['interval'], 2);
      expect(trashData.schedules[0].value['start'], '2026-05-03');
      expect(trashData.excludes.length, 1);
      expect(trashData.excludes[0].month, 12);
      expect(trashData.excludes[0].date, 31);
    });

    test('コピー後のスケジュール値を破壊的に変更してもコピー元データに影響しない', () {
      TrashData trashData = TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [
          TrashSchedule('evweek', {
            'weekday': '1',
            'interval': 2,
            'start': '2026-05-03',
          }),
        ],
        excludes: [],
      );
      when(_trashDataService.getTrashDataById('001')).thenReturn(trashData);

      EditModel model = EditModel(_trashDataService);
      model.loadCopiedModel('001');
      model.schedules[0].value['start'] = '2026-06-01';

      expect(trashData.schedules[0].value['start'], '2026-05-03');
    });

    test('データが存在しない場合はfalseを返す', () {
      when(_trashDataService.getTrashDataById('404')).thenReturn(null);

      EditModel model = EditModel(_trashDataService);
      bool result = model.loadCopiedModel('404');

      expect(result, false);
      expect(model.editType, EditType.NEW);
    });

    test('コピー後の登録では新規データとして追加する', () async {
      TrashData trashData = TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [TrashSchedule('weekday', '0')],
        excludes: [ExcludeDate(12, 31)],
      );
      when(_trashDataService.getTrashDataById('001')).thenReturn(trashData);
      when(_trashDataService.addTrashData(any)).thenAnswer((_) async => true);

      EditModel model = EditModel(_trashDataService);
      model.loadCopiedModel('001');
      bool result = await model.submitTrashData();

      final captured =
          verify(_trashDataService.addTrashData(captureAny)).captured.single
              as TrashData;
      expect(result, true);
      expect(captured.id, isNot('001'));
      expect(captured.type, 'other');
      expect(captured.trashVal, '家電');
      verifyNever(_trashDataService.updateTrashData(any));
    });
  });
}
