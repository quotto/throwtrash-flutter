// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:throwtrash/models/calendar_model.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_import_message.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashRepository implements TrashRepositoryInterface {
  static const TRASH_DATA_KEY = 'TRASH_DATA';
  static const LAST_UPDATE_TIME_KEY = 'LAST_UPDATE_TIME';
  static const SYNC_STATUS_KEY = 'SYNC_STATUS_KEY';
  static const GLOBAL_EXCLUDES_KEY = 'GLOBAL_EXCLUDES';
  static const INITIAL_SEARCH_DIALOG_SHOWN_KEY = 'INITIAL_SEARCH_DIALOG_SHOWN';
  static const IMPORT_MESSAGE_KEY = 'IMPORT_MESSAGE';
  final _logger = Logger();
  late final SharedPreferences _preferences;

  static TrashRepository? _instance;
  TrashRepository._(this._preferences);
  static void initialize(SharedPreferences preferences) {
    if (_instance != null) {
      throw StateError('TrashRepository is already initialized');
    }
    _instance = TrashRepository._(preferences);
  }

  factory TrashRepository() {
    if (_instance == null) {
      throw StateError('TrashRepository is not initialized');
    }
    return _instance!;
  }

  @override
  Future<List<TrashData>> readAllTrashData() async {
    List<String>? rawList = _preferences.getStringList(TRASH_DATA_KEY);

    if (rawList != null && rawList.isNotEmpty) {
      _logger.d("Read all trash data: ${rawList.join("\n")}");
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
    _logger.d("Insert trash data: ${json.encode(trashData.toJson())}");
    List<String>? allTrashData = _preferences.getStringList(TRASH_DATA_KEY);
    if (allTrashData != null && allTrashData.isNotEmpty) {
      bool check = allTrashData.every((element) {
        TrashData data = TrashData.fromJson(jsonDecode(element));
        return data.id != trashData.id;
      });
      if (!check) {
        _logger.e(
          "Failed insert trash data, trash data exist: ${trashData.id}",
        );
        return false;
      }
      allTrashData.add(jsonEncode(trashData.toJson()));
    } else {
      allTrashData = [jsonEncode(trashData.toJson())];
    }

    return _preferences.setStringList(TRASH_DATA_KEY, allTrashData);
  }

  @override
  Future<bool> replaceAllTrashData(List<TrashData> allTrashData) async {
    _logger.d('Replace all trash data: ${allTrashData.length}');
    final rawList = allTrashData.map((trashData) {
      return jsonEncode(trashData.toJson());
    }).toList();
    return _preferences.setStringList(TRASH_DATA_KEY, rawList);
  }

  @override
  Future<bool> replaceAllTrashData(List<TrashData> allTrashData) async {
    _logger.d('Replace all trash data: ${allTrashData.length}');
    final rawList = allTrashData.map((trashData) {
      return jsonEncode(trashData.toJson());
    }).toList();
    return _preferences.setStringList(TRASH_DATA_KEY, rawList);
  }

  @override
  Future<bool> updateTrashData(TrashData trashData) async {
    _logger.d("Update trash data: ${json.encode(trashData.toJson())}");
    List<String>? allTrashData = _preferences.getStringList(TRASH_DATA_KEY);
    if (allTrashData != null && allTrashData.isNotEmpty) {
      for (int index = 0; index < allTrashData.length; index++) {
        TrashData data = TrashData.fromJson(jsonDecode(allTrashData[index]));
        if (data.id == trashData.id) {
          allTrashData[index] = jsonEncode(trashData.toJson());
          return _preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e(
      "Failed update trash data, trash data not exists: ${trashData.id}",
    );
    return false;
  }

  @override
  Future<bool> deleteTrashData(String id) async {
    _logger.d("Delete trash data: $id");
    List<String>? allTrashData = _preferences.getStringList(TRASH_DATA_KEY);
    if (allTrashData != null && allTrashData.isNotEmpty) {
      for (int index = 0; index < allTrashData.length; index++) {
        TrashData trashData = TrashData.fromJson(
          jsonDecode(allTrashData[index]),
        );
        if (trashData.id == id) {
          allTrashData.removeAt(index);
          return await _preferences.setStringList(TRASH_DATA_KEY, allTrashData);
        }
      }
    }
    _logger.e("Failed delete trash data, trash data not exists: $id");
    return false;
  }

  @override
  Future<int> getLastUpdateTime() async {
    int? preferenceValue = _preferences.getInt(LAST_UPDATE_TIME_KEY);
    int lastUpdateTime = preferenceValue ?? 0;
    _logger.d("get lastUpdateTimeStamp: $lastUpdateTime");
    return lastUpdateTime;
  }

  @override
  Future<bool> updateLastUpdateTime(int updateTimestamp) async {
    _logger.d("Update lastUpdateTime: $updateTimestamp");
    return await _preferences.setInt(LAST_UPDATE_TIME_KEY, updateTimestamp);
  }

  @override
  Future<bool> truncateAllTrashData() async {
    _logger.d("truncate trash data");
    return await _preferences.remove(TRASH_DATA_KEY);
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    _logger.d("get sync status");
    int? value = _preferences.getInt(SYNC_STATUS_KEY);
    if (value == null) {
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

  @override
  Future<List<ExcludeDate>> readGlobalExcludeDates() async {
    List<String>? rawList = _preferences.getStringList(GLOBAL_EXCLUDES_KEY);
    if (rawList == null || rawList.isEmpty) {
      return [];
    }
    return rawList.map((element) {
      return ExcludeDate.fromJson(jsonDecode(element));
    }).toList();
  }

  @override
  Future<bool> writeGlobalExcludeDates(List<ExcludeDate> excludeDates) async {
    final rawList = excludeDates.map((element) {
      return jsonEncode(element.toJson());
    }).toList();
    return _preferences.setStringList(GLOBAL_EXCLUDES_KEY, rawList);
  }

  @override
  Future<bool> shouldShowInitialSearchDialog() async {
    return !(_preferences.getBool(INITIAL_SEARCH_DIALOG_SHOWN_KEY) ?? false);
  }

  @override
  Future<bool> markInitialSearchDialogShown() async {
    return _preferences.setBool(INITIAL_SEARCH_DIALOG_SHOWN_KEY, true);
  }

  @override
  Future<bool> saveImportMessage(TrashImportMessage message) async {
    return _preferences.setString(
      IMPORT_MESSAGE_KEY,
      jsonEncode(message.toJson()),
    );
  }

  @override
  Future<TrashImportMessage?> consumeImportMessage() async {
    final rawMessage = _preferences.getString(IMPORT_MESSAGE_KEY);
    if (rawMessage == null) {
      return null;
    }
    await _preferences.remove(IMPORT_MESSAGE_KEY);
    try {
      final json = jsonDecode(rawMessage);
      if (json is Map<String, dynamic>) {
        return TrashImportMessage.fromJson(json);
      }
    } on FormatException {
      return TrashImportMessage.fromLegacyMessage(rawMessage);
    }
    return TrashImportMessage.fromLegacyMessage(rawMessage);
  }
}
