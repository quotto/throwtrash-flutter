import 'package:flutter/cupertino.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

enum EditState {
  EDIT,
  PROCESSING,
  COMPLETE,
  ERROR
}

enum EditType {
  NEW,
  UPDATE
}

class EditModel extends ChangeNotifier {
  final TrashDataServiceInterface _trashDataService;
  late TrashData _trashData;
  EditState _editState = EditState.EDIT;
  EditType _editType = EditType.NEW;


  EditModel(this._trashDataService) {
    _trashData = TrashData(
        id: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
        type: 'burn',
        trashVal: '',
        schedules: [TrashSchedule('weekday', '0')],
        excludes: []
    );
  }

  bool loadModel(String id) {
    if(id.isNotEmpty) {
      TrashData? findData = _trashDataService.getTrashDataById(id);
      if(findData != null) {
        _trashData = findData;
        _editType = EditType.UPDATE;
        return true;
      }
    }
    return false;
  }

  TrashData get trash => _trashData;
  List<TrashSchedule> get schedules => _trashData.schedules;
  List<ExcludeDate> get excludes => _trashData.excludes;
  EditState get editState => _editState;
  EditType get editType => _editType;

  void changeTrashType(String changedTrashType) {
    _trashData.type = changedTrashType;
    if(changedTrashType != 'other') {
      _trashData.trashVal = '';
    }

    notifyListeners();
  }

  void changeTrashName(String changedTrashName) {
    // この処理ではViewに変更を通知しない…本当か？
    if(_trashData.type == 'other') {
      _trashData.trashVal = changedTrashName;
    }
  }

  void changeScheduleType(int index, String changedScheduleType) {
    dynamic scheduleValue = (){
      switch(changedScheduleType) {
        case 'weekday':
          return '0';
        case 'month':
          return '1';
        case 'biweek':
          return '0-1';
        case 'evweek':
          return {'weekday': '0', 'start': DateTime.now().toIso8601String().substring(0,10), 'interval': 2};
      }
    }();
    TrashSchedule newTrashSchedule = TrashSchedule(changedScheduleType, scheduleValue);
    _trashData.schedules[index] = newTrashSchedule;

    notifyListeners();
  }

  void changeValue(int index, String changedValue) {
    _trashData.schedules[index].value = changedValue;

    notifyListeners();
  }

  void changeEvweekValue(int index, String weekday, int interval, String start) {
    _trashData.schedules[index].value = {
      'weekday': weekday,
      'interval': interval,
      'start': start
    };

    notifyListeners();
  }

  void addSchedule() {
    _trashData.schedules.add(
        TrashSchedule('weekday', '0')
    );
    notifyListeners();
  }

  void removeSchedule(int index) {
    if(_trashData.schedules.length > 1) {
      _trashData.schedules.removeAt(index);
    }
    notifyListeners();
  }

  Future<bool> submitTrashData() async {
    if(_editType == EditType.NEW) {
      return _registerTrashData();
    } else if(_editType == EditType.UPDATE) {
      return _updateTrashData();
    }
    return false;
  }

  Future<bool> _registerTrashData() async {
    if(_editState != EditState.PROCESSING && _editState != EditState.COMPLETE) {
      _editState = EditState.PROCESSING;
      return _trashDataService.addTrashData(_trashData).then((result) {
        _editState = result ? EditState.COMPLETE : EditState.ERROR;
        return result;
      });
    }
    return false;
  }

  Future<bool> _updateTrashData()  async {
    if(_editState != EditState.PROCESSING && _editState != EditState.COMPLETE) {
      _editState = EditState.PROCESSING;
      notifyListeners();
      return _trashDataService.updateTrashData(_trashData).then((result) {
        _editState = result ? EditState.COMPLETE : EditState.ERROR;
        return result;
      });
    }
    return false;
  }

  void setExcludeDate(List<List<int>> excludeDate) {
    _trashData.excludes.clear();
    excludeDate.forEach((element) {
      _trashData.excludes.add(ExcludeDate(element[0], element[1]));
    });
  }
}