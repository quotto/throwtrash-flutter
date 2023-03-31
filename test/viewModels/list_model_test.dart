import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/list_model.dart';

import 'calendar_model_test.mocks.dart';

@GenerateMocks([TrashDataService])
void main() {
  group('reload', ()
  {
    test('weekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 1);
      expect(listModel.trashList[0].schedules[0], '毎週日曜日');
    });
    test("monthのデータが_trashListに追加されること", () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 1);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
    });
    test("biweekのデータが_trashListに追加されること", () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでbiweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('biweek', '0-1'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 1);
      expect(listModel.trashList[0].schedules[0], '第1日曜日');
    });
    test("evweekのデータが_trashListに追加されること", () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでevweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 1);
      expect(listModel.trashList[0].schedules[0], '2週に1度の月');
    });
    test('weekdayとmonthのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでweekdayとmonthを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('weekday', '0'),
            TrashSchedule('month', '1'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎週日曜日');
      expect(listModel.trashList[0].schedules[1], '毎月1日');
    });
    test('weekdayとbiweekのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでweekdayとbiweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('weekday', '0'),
            TrashSchedule('biweek', '0-1'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎週日曜日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
    });
    test('weekdayとevweekのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでweekdayとevweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('weekday', '0'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎週日曜日');
      expect(listModel.trashList[0].schedules[1], '2週に1度の月');
    });
    test('monthとbiweekのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとbiweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
    });
    test('monthとevweekのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとevweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '2週に1度の月');
    });
    test('monthとweekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 2);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '毎週日曜日');
    });
    test('monthとbiweekとevweekのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとbiweekとevweekを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 3);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
      expect(listModel.trashList[0].schedules[2], '2週に1度の月');
    });
    test('monthとbiweekとweekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとbiweekとweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 3);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
      expect(listModel.trashList[0].schedules[2], '毎週日曜日');
    });
    test('monthとevweekとweekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとevweekとweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 3);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '2週に1度の月');
      expect(listModel.trashList[0].schedules[2], '毎週日曜日');
    });
    test('biweekとevweekとweekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでbiweekとevweekとweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 3);
      expect(listModel.trashList[0].schedules[0], '第1日曜日');
      expect(listModel.trashList[0].schedules[1], '2週に1度の月');
      expect(listModel.trashList[0].schedules[2], '毎週日曜日');
    });
    test('monthとbiweekとevweekとweekdayのデータが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListでmonthとbiweekとevweekとweekdayを含むデータを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 4);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
      expect(listModel.trashList[0].schedules[2], '2週に1度の月');
      expect(listModel.trashList[0].schedules[3], '毎週日曜日');
    });
    test('複数のTrashDataが_trashListに追加されること', () {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListで複数のTrashDataを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
        TrashData(
          id: '1234567890124',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 2);
      expect(listModel.trashList[0].id, '1234567890123');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 4);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
      expect(listModel.trashList[0].schedules[2], '2週に1度の月');
      expect(listModel.trashList[0].schedules[3], '毎週日曜日');
      expect(listModel.trashList[1].id, '1234567890124');
      expect(listModel.trashList[1].name, '燃えるゴミ');
      expect(listModel.trashList[1].schedules.length, 4);
      expect(listModel.trashList[1].schedules[0], '毎月1日');
      expect(listModel.trashList[1].schedules[1], '第1日曜日');
      expect(listModel.trashList[1].schedules[2], '2週に1度の月');
    });
  });
  group("trashListの中身を削除する", ()
  {
    test('データが複数件の時trashListの中身が削除されること', () async {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListで複数のTrashDataを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えないごみ',
          type: 'unburn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
        TrashData(
          id: '1234567890124',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // TrashDataServiceInterfaceのgetTrashNameで燃えないごみを返すようにモックする
      when(_trashDataService.getTrashName(type: 'unburn', trashVal: '燃えないごみ'))
          .thenReturn('燃えないごみ');
      // TrashDataServiceInterfaceのdeleteTrashDataで燃えるゴミを削除するようにモックする
      when(_trashDataService.deleteTrashData('1234567890124')).thenAnswer((_) => Future.value(true));
      when(_trashDataService.deleteTrashData('1234567890123')).thenAnswer((_) => Future.value(true));
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を削除
      await listModel.deleteTrashData(0);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 1);
      expect(listModel.trashList[0].id, '1234567890124');
      expect(listModel.trashList[0].name, '燃えるゴミ');
      expect(listModel.trashList[0].schedules.length, 4);
      expect(listModel.trashList[0].schedules[0], '毎月1日');
      expect(listModel.trashList[0].schedules[1], '第1日曜日');
      expect(listModel.trashList[0].schedules[2], '2週に1度の月');
      expect(listModel.trashList[0].schedules[3], '毎週日曜日');
    });
    test("データ1件の時正常に削除されること", () async {
      TrashDataServiceInterface _trashDataService = MockTrashDataServiceInterface();
      // TrashDataServiceInterfaceのallTrashListで複数のTrashDataを返すようにモックする
      when(_trashDataService.allTrashList).thenReturn([
        TrashData(
          id: '1234567890123',
          trashVal: '燃えるゴミ',
          type: 'burn',
          schedules: [
            TrashSchedule('month', '1'),
            TrashSchedule('biweek', '0-1'),
            TrashSchedule('evweek', {"interval": 2, "weekday": "1"}),
            TrashSchedule('weekday', '0'),
          ],
        ),
      ]);
      // TrashDataServiceInterfaceのgetTrashNameで燃えるゴミを返すようにモックする
      when(_trashDataService.getTrashName(type: 'burn', trashVal: '燃えるゴミ'))
          .thenReturn('燃えるゴミ');
      // TrashDataServiceInterfaceのdeleteTrashDataで燃えるゴミを削除するようにモックする
      when(_trashDataService.deleteTrashData('1234567890123')).thenAnswer((_) => Future.value(true));
      // テスト対象のインスタンスを生成
      ListModel listModel = ListModel(_trashDataService);
      // _trashListの中身を削除
      await listModel.deleteTrashData(0);
      // _trashListの中身を確認
      expect(listModel.trashList.length, 0);
    });
  });
}