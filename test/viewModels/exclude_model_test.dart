import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/viewModels/exclude_date_model.dart';


void main() {
  // ExcludeViewModelのテスト
  group("addExcludeDate",(){
    test("addExcludeDateで例外日を追加したときにexcludeDatesに追加されること",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      expect(model.excludeDates.length, 1);
    });
    test("addExcludeDateで例外日を追加したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      expect(model.excludeDates[0][0], 1);
      expect(model.excludeDates[0][1], 1);
    });
    test("addExcludeDateで例外日を追加したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(2,29));
      expect(model.excludeDates[0][0], 2);
      expect(model.excludeDates[0][1], 29);
    });
    test("addExcludeDateで例外日を追加したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(12,31));
      expect(model.excludeDates[0][0], 12);
      expect(model.excludeDates[0][1], 31);
    });
  });

  group("changeMonth",() {
    test("changeMonthで月を変更したときに日付が正しく変更されること",()
    {
      ExcludeViewModel model = ExcludeViewModel.load([]);
      // modelに2月1日を追加
      model.addExcludeDate(ExcludeDate(2,1));
      model.changeMonth(0, 2);
      expect(model.excludeDates[0][0], 2);
    });
    test("indexが1の月が正しく変更されること",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      // modelに2件データを追加
      model.addExcludeDate(ExcludeDate(2,1));
      model.addExcludeDate(ExcludeDate(2,1));
      model.changeMonth(1, 2);
      expect(model.excludeDates[1][0], 2);
    });
  });
  group("changeDate",() {
    test("changeDateで日付を変更したときに日付が正しく変更されること",()
    {
      ExcludeViewModel model = ExcludeViewModel.load([]);
      // modelに2月1日を追加
      model.addExcludeDate(ExcludeDate(2,1));
      model.changeDate(0, 2);
      expect(model.excludeDates[0][1], 2);
    });
    test("indexが1の日付が正しく変更されること",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      // modelに2件データを追加
      model.addExcludeDate(ExcludeDate(2,1));
      model.addExcludeDate(ExcludeDate(2,1));
      model.changeDate(1, 2);
      expect(model.excludeDates[1][1], 2);
    });
  });

  group("removeExcludeDate",() {
    test("removeExcludeDateで例外日を削除したときにexcludeDatesから削除されること",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.removeExcludeDate(0);
      expect(model.excludeDates.length, 0);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      expect(model.excludeDates[0][0], 2);
      expect(model.excludeDates[0][1], 2);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(1);
      expect(model.excludeDates[0][0], 1);
      expect(model.excludeDates[0][1], 1);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      model.removeExcludeDate(0);
      expect(model.excludeDates.length, 0);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(1);
      model.removeExcludeDate(0);
      expect(model.excludeDates.length, 0);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      model.removeExcludeDate(0);
      model.addExcludeDate(ExcludeDate(3,3));
      expect(model.excludeDates[0][0], 3);
      expect(model.excludeDates[0][1], 3);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      model.removeExcludeDate(0);
      model.addExcludeDate(ExcludeDate(3,3));
      model.addExcludeDate(ExcludeDate(4,4));
      expect(model.excludeDates[0][0], 3);
      expect(model.excludeDates[0][1], 3);
      expect(model.excludeDates[1][0], 4);
      expect(model.excludeDates[1][1], 4);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      model.removeExcludeDate(0);
      model.addExcludeDate(ExcludeDate(3,3));
      model.addExcludeDate(ExcludeDate(4,4));
      model.removeExcludeDate(0);
      expect(model.excludeDates[0][0], 4);
      expect(model.excludeDates[0][1], 4);
    });
    test("removeExcludeDateで例外日を削除したときにexcludeDatesの中身が正しいこと",(){
      ExcludeViewModel model = ExcludeViewModel.load([]);
      model.addExcludeDate(ExcludeDate(1,1));
      model.addExcludeDate(ExcludeDate(2,2));
      model.removeExcludeDate(0);
      model.removeExcludeDate(0);
      model.addExcludeDate(ExcludeDate(3,3));
      model.addExcludeDate(ExcludeDate(4,4));
      model.removeExcludeDate(1);
      expect(model.excludeDates[0][0], 3);
      expect(model.excludeDates[0][1], 3);
    });
  });
}