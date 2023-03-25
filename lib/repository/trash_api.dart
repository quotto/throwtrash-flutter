import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/repository/trash_api_interface.dart';

import '../models/trash_data_response.dart';

class TrashApi implements TrashApiInterface {
  String _mobileApiEndpoint = "";
  final _logger = Logger();
  String _platform = "web";
  TrashApi(this._mobileApiEndpoint) {
    if(Platform.isAndroid) {
      _platform = "android";
    } else if(Platform.isIOS) {
      _platform = "ios";
    }
  }

  @override
  Future<RegisterResponse?> registerUserAndTrashData(List<TrashData> allTrashData) async {
    _logger.d("Register user and trash data@${this._mobileApiEndpoint}/register");
    _logger.d(jsonEncode(allTrashData));
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/register");
    http.Response response = await http.post(
        endpointUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"platform": _platform})
    );

    if(response.statusCode == 200) {
      Map<String,dynamic> body = jsonDecode(response.body);
      _logger.d("Success register: " + body.toString());
      return RegisterResponse(body["id"] as String, body["timestamp"] as int);
    }
    _logger.d("Error register: " + response.body);
    return null;
  }

  @override
  Future<TrashUpdateResult> updateTrashData(String id, List<TrashData> localSchedule, int timestamp) async{
    _logger.d("Update trash data");
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/update");
    http.Response response = await http.post(
        endpointUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id": id, "description": jsonEncode(localSchedule), "platform": _platform, "timestamp": timestamp})
    );

    if(response.statusCode == 200) {
      Map<String,dynamic> body = jsonDecode(response.body);
      _logger.d("Success update: " + body.toString());
      return TrashUpdateResult(body["timestamp"] as int, UpdateResult.SUCCESS);
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
    http.Response response = await http.get(endpointUri);
    if(response.statusCode == 200) {
      _logger.d(response.body);
      TrashResponse trashResponse = TrashResponse.fromJson(jsonDecode(response.body));
      _logger.d(trashResponse.description);
      List<TrashData> trashDataList = (jsonDecode(trashResponse.description) as List<dynamic>).map<TrashData>((element) {
        _logger.d(element);
        return TrashDataResponse.fromJson(element).toTrashData();
      }).toList();
      return TrashSyncResult(trashDataList, trashResponse.timestamp, SyncResult.SUCCESS);
    } else {
      _logger.e("failed get remote trash data cause by: ${response.body}");
      return TrashSyncResult([], -1, SyncResult.ERROR);
    }
  }

}