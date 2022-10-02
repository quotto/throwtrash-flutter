import 'package:flutter/cupertino.dart';
import 'package:throwtrash/models/exclude_date.dart';

enum ExcludeState {
  EDIT,
  COMPLETE
}

class ExcludeViewModel extends ChangeNotifier {
  // index0を月,index1を日とする配列
  final List<List<int>> _excludeDates = [];
  ExcludeState _excludeState = ExcludeState.EDIT;
  int _maxDate = 31;

  ExcludeViewModel.load(List<ExcludeDate> loadedExcludeDates)  {
    loadedExcludeDates.forEach((value){
      _excludeDates.add([value.month, value.date]);
    });
  }

  List<List<int>> get excludeDates => _excludeDates;
  ExcludeState get excludeState => _excludeState;
  int get maxDate => _maxDate;

  void addExcludeDate() {
    _excludeDates.add([1, 1]);
    notifyListeners();
  }

  void changeMonth(int index, int month) {
    _excludeDates[index][0] = month;
    if(month == 2) {
      if(_excludeDates[index][1] > 29) {
        _excludeDates[index][1] = 29;
      }
      _maxDate = 29;
    } else if([4,6,9,11].contains(month)) {
      if(_excludeDates[index][1] > 30) {
        _excludeDates[index][1] = 30;
      }
      _maxDate = 30;
    } else {
      _maxDate = 31;
    }
    notifyListeners();
  }

  void changeDate(int index, int date) {
    _excludeDates[index][1] = date;
    notifyListeners();
  }

  void removeExcludeDate(int index) {
    _excludeDates.removeAt(index);
    notifyListeners();
  }

  void setExcludeDates() {
    _excludeState = ExcludeState.COMPLETE;
    notifyListeners();
  }
}