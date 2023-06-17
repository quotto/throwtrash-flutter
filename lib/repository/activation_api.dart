import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:throwtrash/usecase/config_interface.dart';

import '../models/activate_response.dart';

class ActivationApi implements ActivationApiInterface{
  final ConfigInterface _config;
  final Logger _logger = Logger();
  final http.Client _httpClient;
  ActivationApi(this._config, this._httpClient);
  @override
  Future<String> requestActivationCode(String userId) async {
    _logger.d("[GET]${this._config.mobileApiEndpoint}/publish_activation_code?user_id=$userId");
     Uri endpointUri = Uri.parse(
         this._config.mobileApiEndpoint + "/publish_activation_code?user_id=$userId");
     http.Response response = await this._httpClient.get(
       endpointUri
     );
     if(response.statusCode == 200) {
       Map<String,dynamic> responseBody = jsonDecode(response.body);
       return responseBody.containsKey("code") ? responseBody["code"] : "";
     }
     _logger.e("Error request activation code");
     _logger.e(response.body);
     return "";

  }

  @override
  Future<ActivateResponse?> requestAuthorizationActivationCode(String code, String userId) async{
    Uri endpointUri = Uri.parse(
      this._config.mobileApiEndpoint + "/activate?code=$code&user_id=$userId"
    );
    http.Response response = await this._httpClient.get(endpointUri);
    if(response.statusCode == 200) {
      ActivateResponse activateResponse = ActivateResponse.fromJson(jsonDecode(response.body));
      return activateResponse;
    }
    _logger.e("Error request authorization code");
    _logger.e(response.body);
    return null;
  }

}