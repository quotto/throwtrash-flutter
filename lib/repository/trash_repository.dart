import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashRepository implements TrashRepositoryInterface {
  static const TRASH_DATA_KEY = 'TRASH_DATA';
  static const LAST_UPDATE_TIME_KEY = 'LAST_UPDATE_TIME';
  final _logger = Logger();

  @override
  Future<List<TrashData>> readAllTrashData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? rawList = preferences.getStringList(TRASH_DATA_KEY);

    if(rawList != null && rawList.isNotEmpty) {
      _logger.d("Read all trash data: " + rawList.join("\n"));
      return rawList.map<TrashData>((element) {
        return TrashData.fromJson(jsonDecode(element));
      }).toList();
    }
    _logger.w("Trash data is empty");
    return [];
  }

  @override
  Future<bool> insertTrashData(TrashData trashData) async {
    _logger.d("Insert trash data: " + json.encode(trashData.toJson()));
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? allTrashData  = preferences.getStringList(TRASH_DATA_KEY);
    if(allTrashData != null && allTrashData.isNotEmpty) {
      bool check = allTrashData.every((element) {
        TrashData data  = TrashData.fromJson(jsonDecode(element));
        return data.id != trashData.id;
      });
      if(!check) {
        _logger.e("Failed insert trash data, trash data exist: " + trashData.id);
        return false;
      }
      allTrashData.add(jsonEncode(trashData.toJson()));
    } else {
      allTrashData = [jsonEncode(trashData.toJson())];
    }

    return preferences.setStringList(TRASH_DATA_KEY, allTrashData);
  }

  @override
  Future<bool> updateTrashData(TrashData trashData) async {
    _logger.d("Update trash data: " + json.encode(trashData.toJson()));
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? allTrashData  = preferences.getStringList(TRASH_DATA_KEY);
    if(allTrashData != null && allTrashData.isNotEmpty) {
      for(int index=0; index < allTrashData.length; index++) {
        TrashData data  = TrashData.fromJson(jsonDecode(allTrashData[index]));
        if(data.id == trashData.id) {
          allTrashData[index] = jsonEncode(trashData.toJson());
          return preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e("Failed update trash data, trash data not exists: " + trashData.id);
    return false;
  }

  @override
  Future<bool> deleteTrashData(String id) async {
    _logger.d("Delete trash data: $id");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? allTrashData  = preferences.getStringList(TRASH_DATA_KEY);
    if(allTrashData != null && allTrashData.length > 0) {
      for (int index = 0; index < allTrashData.length; index++) {
        TrashData trashData = TrashData.fromJson(
            jsonDecode(allTrashData[index]));
        if(trashData.id == id) {
          allTrashData.removeAt(index);
          return await preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e("Failed delete trash data, trash data not exists: $id");
    return false;
  }

  @override
  Future<int> getLastUpdateTime() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? lastUpdateTimestamp = preferences.getInt(LAST_UPDATE_TIME_KEY);
    lastUpdateTimestamp = lastUpdateTimestamp == null ? 0 : lastUpdateTimestamp;
    _logger.d("get lastUpdateTimeStamp: $lastUpdateTimestamp");
    return lastUpdateTimestamp;
  }

  @override
  Future<bool> updateLastUpdateTime(int updateTimestamp) async {
    _logger.d("Update lastUpdateTime: $updateTimestamp");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setInt(LAST_UPDATE_TIME_KEY, updateTimestamp);
  }

  @override
  Future<bool> truncateAllTrashData() async{
    _logger.d("truncate trash data");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(TRASH_DATA_KEY) && await preferences.remove(LAST_UPDATE_TIME_KEY);
  }

}