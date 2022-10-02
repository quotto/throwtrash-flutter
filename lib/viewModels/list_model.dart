import 'package:flutter/cupertino.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

class TrashListData {
  final String id;
  final String name;
  final List<String> schedules;

  TrashListData({required this.id, required this.name, required this.schedules});
}

class ListModel extends ChangeNotifier {
  final List<String> _weekdayLabel = [
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土'
  ];
  final TrashDataServiceInterface _trashDataService;
  final List<TrashListData> _trashList = [];

  ListModel(this._trashDataService) {
    _reload();
  }

  void _reload() {
    _trashList.clear();
    _trashDataService.allTrashList.forEach((element) {
      List<String> schedules = [];
      element.schedules.forEach((schedule) {
        switch(schedule.type) {
          case 'weekday':
            schedules.add('毎週${_weekdayLabel[int.parse(schedule.value)]}曜日');
            break;
          case 'month':
            schedules.add('毎月${schedule.value}日');
            break;
          case 'biweek':
            List<String> value = (schedule.value as String).split('-');
            schedules.add('第${value[1]}${_weekdayLabel[int.parse(value[0])]}曜日');
            break;
          case 'evweek':
            schedules.add(
                '${schedule.value['interval']}週に1度の${_weekdayLabel[int.parse(schedule.value['weekday'])]}'
            );
            break;
        }
      });
      _trashList.add(TrashListData(
          id: element.id,
          name: _trashDataService.getTrashName(type: element.type, trashVal: element.trash_val),
          schedules: schedules
      ));
    });
  }


  List<TrashListData> get trashList => _trashList;

  Future<bool> deleteTrashData(int index) {
    return _trashDataService.deleteTrashData(_trashList[index].id).then((result) {
      if(result) {
        _trashList.removeAt(index);
        notifyListeners();
      }
      return result;
    });
  }

  void reload() {
    _reload();
    notifyListeners();
  }
}