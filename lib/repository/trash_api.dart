import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/repository/trash_api_interface.dart';

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
    _logger.d("Register user and trash data");
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/register");
    http.Response response = await http.post(
        endpointUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"description": jsonEncode(allTrashData), "platform": _platform})
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
  Future<int?> updateTrashData(String id, List<TrashData> allTrashData) async{
    _logger.d("Update trash data");
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/update");
    http.Response response = await http.post(
        endpointUri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id": id, "description": jsonEncode(allTrashData), "platform": _platform})
    );

    if(response.statusCode == 200) {
      Map<String,dynamic> body = jsonDecode(response.body);
      _logger.d("Success update: " + body.toString());
      return body["timestamp"] as int;
    }
    _logger.d("Error update: " + response.body);
    return null;
  }

  @override
  Future<TrashResponse?> getRemoteTrashData(String userId) async {
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/sync?user_id=$userId}");
    http.Response response = await http.get(endpointUri);
    if(response.statusCode == 200) {
      TrashResponse trashResponse = TrashResponse.fromJson(json.decode(response.body));
      return trashResponse;
    } else {
      _logger.e("failed get remote trash data cause by: ${response.body}");
      return null;
    }
  }
  
}