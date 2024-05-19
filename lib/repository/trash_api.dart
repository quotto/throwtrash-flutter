import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/trash_api_interface.dart';

import '../models/trash_data_response.dart';

class TrashApi implements TrashApiInterface {
  final AppConfigProviderInterface _configProvider;
  final http.Client _httpClient;
  final _logger = Logger();
  late final String _mobileApiEndpoint;
  String _platform = "web";
  TrashApi._(this._configProvider, this._httpClient) {
    if(Platform.isAndroid) {
      _platform = "android";
    } else if(Platform.isIOS) {
      _platform = "ios";
    }
    this._mobileApiEndpoint = this._configProvider.mobileApiUrl;
  }

  static TrashApi? _instance;

  static initialize(AppConfigProviderInterface configProvider, http.Client httpClient) {
    if(_instance != null) {
      throw StateError("TrashApi is already initialized");
    }
    _instance = TrashApi._(configProvider, httpClient);
  }

  factory TrashApi() {
    if(_instance == null) {
      throw StateError("TrashApi is not initialized");
    }
    return _instance!;
  }

  @override
  Future<RegisterResponse?> registerUserAndTrashData(List<TrashData> allTrashData) async {
    _logger.d("Register user and trash data@${this._mobileApiEndpoint}/register");
    _logger.d(jsonEncode(allTrashData));
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/register");
    http.Response response = await this._httpClient.post(
        endpointUri,
        headers: {"content-type": "application/json;charset=utf-8"},
        body: json.encode({"platform": _platform})
    );

    if(response.statusCode == 200) {
      Map<String,dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d("Success register: " + body.toString());
      return body.containsKey("id") && body.containsKey("timestamp") ? RegisterResponse(body["id"] as String, body["timestamp"] as int) : null;
    }
    _logger.d("Error register: " + response.body);
    return null;
  }

  @override
  Future<TrashUpdateResult> updateTrashData(String id, List<TrashData> localSchedule, int timestamp) async{
    _logger.d("Update trash data");
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/update");
    http.Response response = await this._httpClient.post(
        endpointUri,
        headers: {"content-type": "application/json;charset=utf-8", "Accept": "application/json"},
        body: json.encode({"id": id, "description": jsonEncode(localSchedule), "platform": _platform, "timestamp": timestamp})
    );

    if(response.statusCode == 200) {
      Map<String,dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d("Success update: " + body.toString());
      return body.containsKey("timestamp") ? TrashUpdateResult(body["timestamp"] as int, UpdateResult.SUCCESS) : TrashUpdateResult(-1, UpdateResult.ERROR);
    } else if(response.statusCode == 400) {
      return TrashUpdateResult(-1, UpdateResult.NO_MATCH);
    } else {
      _logger.d("Error update: " + response.body);
      return TrashUpdateResult(-1, UpdateResult.ERROR);
    }
  }

  @override
  Future<TrashSyncResult> syncTrashData(String userId) async {
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/sync?user_id=$userId");
    http.Response response = await this._httpClient.get(endpointUri, headers: {"content-type":"text/html;charset=utf8","Accept": "application/json"});
    if(response.statusCode == 200) {
      try {
        TrashApiSyncDataResponse trashResponse = TrashApiSyncDataResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
        _logger.d(trashResponse.description);
        List<TrashData> trashDataList = (jsonDecode(
            trashResponse.description) as List<dynamic>).map<TrashData>((
            element) {
          _logger.d(element);
          return TrashDataResponse.fromJson(element).toTrashData();
        }).toList();
        return TrashSyncResult(
            trashDataList, trashResponse.timestamp, TrashApiSyncStatus.SUCCESS);
      } catch(e) {
        _logger.e("failed decode remote trash data cause by: $e");
        return TrashSyncResult([], -1, TrashApiSyncStatus.ERROR);
      }
    } else {
      _logger.e("failed get remote trash data cause by: ${response.body}");
      return TrashSyncResult([], -1, TrashApiSyncStatus.ERROR);
    }
  }

}