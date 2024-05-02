import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:throwtrash/models/calendar_model.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashRepository implements TrashRepositoryInterface {
  static const TRASH_DATA_KEY = 'TRASH_DATA';
  static const LAST_UPDATE_TIME_KEY = 'LAST_UPDATE_TIME';
  static const SYNC_STATUS_KEY = 'SYNC_STATUS_KEY';
  final _logger = Logger();
  late final SharedPreferences _preferences;

  static TrashRepository? _instance;
  TrashRepository._(this._preferences);
  static void initialize(SharedPreferences _preferences) {
    if(_instance != null) throw StateError('TrashRepository is already initialized');
    _instance = TrashRepository._(_preferences);
  }
  factory TrashRepository() {
    if(_instance == null) {
      throw StateError('TrashRepository is not initialized');
    }
    return _instance!;
  }

  @override
  Future<List<TrashData>> readAllTrashData() async {
    List<String>? rawList = this._preferences.getStringList(TRASH_DATA_KEY);

    if(rawList != null && rawList.isNotEmpty) {
      _logger.d("Read all trash data: " + rawList.join("\n"));
      return rawList.map<TrashData>((element) {
        return TrashData.fromJson(jsonDecode(element));
      }).toList();
    } else {
      _logger.w("Trash data is empty");
      return [];
    }
  }

  @override
  Future<bool> insertTrashData(TrashData trashData) async {
    _logger.d("Insert trash data: " + json.encode(trashData.toJson()));
    List<String>? allTrashData  = this._preferences.getStringList(TRASH_DATA_KEY);
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

    return this._preferences.setStringList(TRASH_DATA_KEY, allTrashData);
  }

  @override
  Future<bool> updateTrashData(TrashData trashData) async {
    _logger.d("Update trash data: " + json.encode(trashData.toJson()));
    List<String>? allTrashData  = this._preferences.getStringList(TRASH_DATA_KEY);
    if(allTrashData != null && allTrashData.isNotEmpty) {
      for(int index=0; index < allTrashData.length; index++) {
        TrashData data  = TrashData.fromJson(jsonDecode(allTrashData[index]));
        if(data.id == trashData.id) {
          allTrashData[index] = jsonEncode(trashData.toJson());
          return this._preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e("Failed update trash data, trash data not exists: " + trashData.id);
    return false;
  }

  @override
  Future<bool> deleteTrashData(String id) async {
    _logger.d("Delete trash data: $id");
    List<String>? allTrashData  = this._preferences.getStringList(TRASH_DATA_KEY);
    if(allTrashData != null && allTrashData.length > 0) {
      for (int index = 0; index < allTrashData.length; index++) {
        TrashData trashData = TrashData.fromJson(
            jsonDecode(allTrashData[index]));
        if(trashData.id == id) {
          allTrashData.removeAt(index);
          return await this._preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e("Failed delete trash data, trash data not exists: $id");
    return false;
  }

  @override
  Future<int> getLastUpdateTime() async {
    int? preferenceValue = this._preferences.getInt(LAST_UPDATE_TIME_KEY);
    int lastUpdateTime = preferenceValue == null ? 0 : preferenceValue;
    _logger.d("get lastUpdateTimeStamp: $lastUpdateTime");
    return lastUpdateTime;
  }

  @override
  Future<bool> updateLastUpdateTime(int updateTimestamp) async {
    _logger.d("Update lastUpdateTime: $updateTimestamp");
    return await this._preferences.setInt(LAST_UPDATE_TIME_KEY, updateTimestamp);
  }

  @override
  Future<bool> truncateAllTrashData() async{
    _logger.d("truncate trash data");
    return await this._preferences.remove(TRASH_DATA_KEY);
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    _logger.d("get sync status");
    int? value = this._preferences.getInt(SYNC_STATUS_KEY);
    if(value == null) {
      return SyncStatus.SYNCING;
    } else {
      return SyncStatusHelper.toSyncStatus(value);
    }
  }

  @override
  Future<bool> setSyncStatus(SyncStatus syncStatus) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setInt(SYNC_STATUS_KEY, syncStatus.toInt());
  }

}