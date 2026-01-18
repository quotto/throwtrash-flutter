import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/viewModels/calendar_model.dart';
import 'package:throwtrash/usecase/calendar_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:mockito/mockito.dart';

import 'calendar_model_test.mocks.dart';

@GenerateMocks([CalendarService, TrashDataServiceInterface])
void main() {
  late MockCalendarService calendarService;
  late MockTrashDataServiceInterface trashDataService;

  setUp(() {
    calendarService = MockCalendarService();
    trashDataService = MockTrashDataServiceInterface();
    when(calendarService.generateMonthCalendar(2022, 12)).thenReturn(
        [27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 31]);
    when(calendarService.generateMonthCalendar(2023, 1)).thenReturn(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 31, 1, 2, 3, 4]);
    when(calendarService.generateMonthCalendar(2023, 2)).thenReturn(
        [29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1]);
    when(calendarService.generateMonthCalendar(2023, 3)).thenReturn(
        [26, 27, 28, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 1]);
    when(calendarService.generateMonthCalendar(2023, 4)).thenReturn(
        [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 1, 2, 3, 4, 5, 6]);
    when(calendarService.generateMonthCalendar(2023, 5)).thenReturn(
        [30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 1, 2, 3]);
    when(calendarService.generateMonthCalendar(2023, 6)).thenReturn(
        [28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 1]);
    when(calendarService.generateMonthCalendar(2023, 7)).thenReturn(
        [25, 26, 27, 28, 29, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ,29, 30, 1, 2, 3, 4, 5]);

  });

  tearDown(() => {
    reset(calendarService),
    reset(trashDataService)
  });

  test('initial calendar should be correct when same year', () async {
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    when(trashDataService.getEnableTrashList(year: anyNamed("year"), month: anyNamed("month"), targetDateList: anyNamed("targetDateList"))).thenAnswer((realInvocation) => []);

    Completer completer = Completer();
    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2023, 3, 10));

    void firstListener() {
      try {
        calendarModel.removeListener(firstListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 3);
        expect(calendarModel.currentPage, 0);
        expect(calendarModel.calendarsDateList.length, 5);
        expect(calendarModel.calendarsTrashList.length, 5);
        // 2ページ目、2023年4月の1週目の日曜日は前月の26日
        expect(calendarModel.calendarsDateList[1][0], 26);
        // 3ページ目、2023年5月の1週目の日曜日は前月の30日
        expect(calendarModel.calendarsDateList[2][0], 30);
        // 4ページ目、2023年6月の1週目の日曜日は前月の28日
        expect(calendarModel.calendarsDateList[3][0], 28);
        // 5ページ目、2023年7月の1週目の日曜日は前月の25日
        expect(calendarModel.calendarsDateList[4][0], 25);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }

    calendarModel.addListener(firstListener);
    await completer.future;
  });

  test('initial calendar should be correct when over year', () async {
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    when(trashDataService.getEnableTrashList(year: anyNamed("year"), month: anyNamed("month"), targetDateList: anyNamed("targetDateList"))).thenAnswer((realInvocation) => []);

    Completer completer = Completer();
    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2022, 12, 10));

    void firstListener() {
      try {
        calendarModel.removeListener(firstListener);
        expect(calendarModel.year, 2022);
        expect(calendarModel.month, 12);
        expect(calendarModel.currentPage, 0);
        expect(calendarModel.calendarsDateList.length, 5);
        expect(calendarModel.calendarsTrashList.length, 5);
        // 2ページ目、2023年1月の1週目の日曜日は当月の1日
        expect(calendarModel.calendarsDateList[1][0], 1);
        // 3ページ目、2023年2月の1週目の日曜日は前月の29日
        expect(calendarModel.calendarsDateList[2][0], 29);
        // 4ページ目、2023年3月の1週目の日曜日は前月の26日
        expect(calendarModel.calendarsDateList[3][0], 26);
        // 5ページ目、2023年4月の1週目の日曜日は前月の26日
        expect(calendarModel.calendarsDateList[4][0], 26);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }

    calendarModel.addListener(firstListener);
    await completer.future;
  });

  test('forward and backward should update year and month correctly', () async {
    when(calendarService.generateMonthCalendar(any, any)).thenReturn(
        [0, 0, 0, 0, 0, 0, 0]);
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    List<TrashData> sampleTrashData = [
      TrashData(id: '1', type: 'burn', trashVal: 'Sample Trash A'),
      TrashData(id: '2', type: 'unburn', trashVal: 'Sample Trash B'),
      TrashData(id: '3', type: 'plastic', trashVal: 'Sample Trash C'),
    ];
    when(trashDataService.getEnableTrashList(
        year: anyNamed('year'),
        month: anyNamed('month'),
        targetDateList: anyNamed('targetDateList')),
    ).thenReturn([sampleTrashData]);
    when(trashDataService.getTrashName(
        type: anyNamed('type'),
        trashVal: anyNamed('trashVal')
    )).thenReturn("");

    final completer = Completer();

    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2023, 3, 10));
    void fifthListener() {
      try {
        calendarModel.removeListener(fifthListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 5);
        calendarModel.addListener(fifthListener);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void fourthListener() {
      try {
        calendarModel.removeListener(fourthListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 6);
        calendarModel.addListener(fifthListener);
        calendarModel.backward();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void thirdListener() {
      try {
        calendarModel.removeListener(thirdListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 5);
        calendarModel.addListener(fourthListener);
        calendarModel.forward();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void secondListener() {
      try {
        calendarModel.removeListener(secondListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 4);
        calendarModel.addListener(thirdListener);
        calendarModel.forward();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void firstListener() {
      calendarModel.removeListener(firstListener);
      calendarModel.addListener(secondListener);
      calendarModel.forward();
    }
    calendarModel.addListener(firstListener);

    await completer.future;
  });

  test(
      'forward and backward should update year and month correctly over year', () async {
    when(calendarService.generateMonthCalendar(any, any)).thenReturn(
        [0, 0, 0, 0, 0, 0, 0]);
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    List<TrashData> sampleTrashData = [
      TrashData(id: '1', type: 'burn', trashVal: 'Sample Trash A'),
      TrashData(id: '2', type: 'unburn', trashVal: 'Sample Trash B'),
      TrashData(id: '3', type: 'plastic', trashVal: 'Sample Trash C'),
    ];
    when(trashDataService.getEnableTrashList(
        year: anyNamed('year'),
        month: anyNamed('month'),
        targetDateList: anyNamed('targetDateList')),
    ).thenReturn([sampleTrashData]);
    when(trashDataService.getTrashName(
        type: anyNamed('type'),
        trashVal: anyNamed('trashVal')
    )).thenReturn("");

    final completer = Completer();

    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2022, 12, 10));
    void thirdListener() {
      try {
        calendarModel.removeListener(thirdListener);
        expect(calendarModel.year, 2022);
        expect(calendarModel.month, 12);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void secondListener() {
      try {
        calendarModel.removeListener(secondListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 1);
        calendarModel.addListener(thirdListener);
        calendarModel.backward();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void firstListener() {
      calendarModel.removeListener(firstListener);
      calendarModel.addListener(secondListener);
      calendarModel.forward();
    }
    calendarModel.addListener(firstListener);

    await completer.future;
  });

  test('forward should update calendar list correctly when over year to February', () async {
    when(calendarService.generateMonthCalendar(any, any)).thenReturn(
        [0, 0, 0, 0, 0, 0, 0]);
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    List<TrashData> sampleTrashData = [
      TrashData(id: '1', type: 'burn', trashVal: 'Sample Trash A'),
      TrashData(id: '2', type: 'unburn', trashVal: 'Sample Trash B'),
      TrashData(id: '3', type: 'plastic', trashVal: 'Sample Trash C'),
    ];
    when(trashDataService.getEnableTrashList(
        year: anyNamed('year'),
        month: anyNamed('month'),
        targetDateList: anyNamed('targetDateList')),
    ).thenReturn([sampleTrashData]);
    when(trashDataService.getTrashName(
        type: anyNamed('type'),
        trashVal: anyNamed('trashVal')
    )).thenReturn("");

    final completer = Completer();

    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2022, 12, 10));
    void thirdListener() {
      try {
        calendarModel.removeListener(thirdListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 2);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void secondListener() {
      try {
        calendarModel.removeListener(secondListener);
        expect(calendarModel.year, 2023);
        expect(calendarModel.month, 1);
        calendarModel.addListener(thirdListener);
        calendarModel.forward();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    void firstListener() {
      calendarModel.removeListener(firstListener);
      calendarModel.addListener(secondListener);
      calendarModel.forward();
    }
    calendarModel.addListener(firstListener);

    await completer.future;
  });

  test('reload should refresh trash data', () async {
    when(calendarService.generateMonthCalendar(any, any)).thenReturn(
        [0, 0, 0, 0, 0, 0, 0]);
    when(trashDataService.refreshTrashData()).thenAnswer((_) =>
        Future.value(true));
    CalendarModel calendarModel = CalendarModel(
        calendarService, trashDataService, DateTime(2023, 3, 10));
    List<TrashData> sampleTrashData = [
      TrashData(id: '1', type: 'burn', trashVal: 'Sample Trash A'),
      TrashData(id: '2', type: 'unburn', trashVal: 'Sample Trash B'),
      TrashData(id: '3', type: 'plastic', trashVal: 'Sample Trash C'),
    ];
    when(trashDataService.syncTrashData()).thenAnswer((_) async => SyncResult.skipped);
    when(trashDataService.getEnableTrashList(
        year: anyNamed('year'),
        month: anyNamed('month'),
        targetDateList: anyNamed("targetDateList")),
    ).thenReturn([sampleTrashData]);
    when(trashDataService.getTrashName(
        type: "burn", trashVal: anyNamed("trashVal"))).thenReturn("燃えるゴミ");
    when(trashDataService.getTrashName(
        type: "unburn", trashVal: anyNamed("trashVal"))).thenReturn("燃えないごみ");
    when(trashDataService.getTrashName(
        type: "plastic", trashVal: anyNamed("trashVal"))).thenReturn("プラスチック");

    Completer completer = Completer();
    void secondListener() {
      try {
        calendarModel.removeListener(secondListener);
        expect(calendarModel.calendarsTrashList[0][0][0].trashType, 'burn');
        expect(calendarModel.calendarsTrashList[0][0][0].trashName,
            '燃えるゴミ');
        expect(calendarModel.calendarsTrashList[0][0][1].trashType, 'unburn');
        expect(calendarModel.calendarsTrashList[0][0][1].trashName,
            '燃えないごみ');
        expect(calendarModel.calendarsTrashList[0][0][2].trashType, 'plastic');
        expect(calendarModel.calendarsTrashList[0][0][2].trashName,
            'プラスチック');
        completer.complete();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }

    void firstListener() {
      try {
        calendarModel.removeListener(firstListener);
        calendarModel.addListener(secondListener);
        expect(calendarModel.calendarsDateList.length, 5);
        expect(calendarModel.calendarsTrashList.length, 5);
        calendarModel.reload();
      } catch (e) {
        completer.completeError(e);
        rethrow;
      }
    }
    calendarModel.addListener(firstListener);

    await completer.future;
  });
}