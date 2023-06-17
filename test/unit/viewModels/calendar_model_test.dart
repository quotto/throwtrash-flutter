import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:throwtrash/viewmodels/calendar_model.dart';
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
    when(trashDataService.syncTrashData()).thenAnswer((_) async => {});
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