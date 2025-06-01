import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/repository/activation_api_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';

import '../models/activate_response.dart';

class ActivationApi implements ActivationApiInterface{
  final AppConfigProviderInterface _config;
  final Logger _logger = Logger();
  final http.Client _httpClient;
  static ActivationApi? _instance;

  static initialize(AppConfigProviderInterface config, http.Client httpClient) {
    if(_instance != null) {
      throw StateError("ActivationApi is already initialized");
    }
    _instance = ActivationApi._(config, httpClient);
  }

  factory ActivationApi() {
    if(_instance == null) {
      throw StateError("ActivationApi is not initialized");
    }
    return _instance!;
  }

  ActivationApi._(this._config, this._httpClient);

  @override
  Future<String> requestActivationCode(String userId) async {
    _logger.d("[GET]${this._config.mobileApiUrl}/publish_activation_code?user_id=$userId");
     Uri endpointUri = Uri.parse(
         this._config.mobileApiUrl + "/publish_activation_code?user_id=$userId");
     http.Response response = await this._httpClient.get(
       endpointUri,
       headers: {
         "content-type": "application/json;charset=utf-8",
         "Accept": "application/json",
         "X-TRASH-USERID": userId,
       }
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
      this._config.mobileApiUrl + "/activate?code=$code&user_id=$userId"
    );
    http.Response response = await this._httpClient.get(
      headers: {
        "content-type": "application/json;charset=utf-8",
        "Accept": "application/json",
        "X-TRASH-USERID": userId,
      },
      endpointUri
    );
    if(response.statusCode == 200) {
      ActivateResponse activateResponse = ActivateResponse.fromJson(jsonDecode(response.body));
      return activateResponse;
    }
    _logger.e("Error request authorization code");
    _logger.e(response.body);
    return null;
  }

}