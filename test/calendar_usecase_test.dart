import 'package:throwtrash/usecase/calendar_usecase.dart';
import 'package:test/test.dart';

void main() {
  test('2021年3月のカレンダーが正しいこと',() {
    CalendarUseCase calendarUseCase = CalendarUseCase();
    List<int> expectDateList = [28,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,1,2,3];
    List<int> actualDateList = calendarUseCase.generateMonthCalendar(2021, 3);

    for(int i=0; i<35; i++) {
      expect(actualDateList[i],expectDateList[i]);
    }
  });
  test('2021年7月のカレンダーが正しいこと',() {
    CalendarUseCase calendarUseCase = CalendarUseCase();
    List<int> expectDateList = [27,28,29,30,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
    List<int> actualDateList = calendarUseCase.generateMonthCalendar(2021, 7);

    for(int i=0; i<35; i++) {
      expect(actualDateList[i],expectDateList[i]);
    }
  });
  test('2021年8月のカレンダーが正しいこと',() {
    CalendarUseCase calendarUseCase = CalendarUseCase();
    List<int> expectDateList = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,1,2,3,4];
    List<int> actualDateList = calendarUseCase.generateMonthCalendar(2021, 8);

    for(int i=0; i<35; i++) {
      expect(actualDateList[i],expectDateList[i]);
    }
  });
}