import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/repository/activation_api_interface.dart';
import 'package:throwtrash/repository/config_interface.dart';

class ActivationApi implements ActivationApiInterface{
  final ConfigInterface _config;
  final Logger _logger = Logger();
  ActivationApi(this._config);
  @override
  Future<String> requestActivationCode(String userId) async {
    _logger.d("[GET]${this._config.mobileApiEndpoint}/publish_activation_code?user_id=$userId");
     Uri endpointUri = Uri.parse(
         this._config.mobileApiEndpoint + "/publish_activation_code?user_id=$userId");
     http.Response response = await http.get(
       endpointUri
     );
     if(response.statusCode == 200) {
       Map<String,dynamic> responseBody = jsonDecode(response.body);
       return responseBody["code"];
     }
     _logger.e("Error request activation code");
     _logger.e(response.body);
     return "";

  }

  @override
  Future<TrashResponse?> requestAuthorizationActivationCode(String code) async{
    Uri endpointUri = Uri.parse(
      this._config.mobileApiEndpoint + "/activate?code=$code"
    );
    http.Response response = await http.get(endpointUri);
    if(response.statusCode == 200) {
      TrashResponse trashResponse = TrashResponse.fromJson(jsonDecode(response.body));
      return trashResponse;
    }
    _logger.e("Error request authorization code");
    _logger.e(response.body);
    return null;
  }

}