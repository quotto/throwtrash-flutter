import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/repository/account_link_api_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';

import '../viewModels/account_link_model.dart';

class AccountLinkApi implements AccountLinkApiInterface {
  final Logger _logger = Logger();
  final AppConfigProviderInterface _configProvider;
  final http.Client _httpClient;
  static AccountLinkApi? _instance;


  AccountLinkApi._(this._configProvider, this._httpClient);

  static initialize(AppConfigProviderInterface configProvider, http.Client httpClient) {
    if(_instance != null) {
      throw StateError("AccountLinkApi is already initialized");
    }
    _instance = AccountLinkApi._(configProvider, httpClient);
  }

  factory AccountLinkApi() {
    if(_instance == null) {
      throw StateError("AccountLinkApi is not initialized");
    }
    return _instance!;
  }

  @override
  Future<AccountLinkInfo?> startAccountLink(String userId, AccountLinkType accountLinkType) async {
    Uri endpointUri = Uri.parse("${this._configProvider.mobileApiUrl}/start_link?user_id=$userId&platform=${accountLinkType.toStringValue()}");
    http.Response response = await this._httpClient.get(
      endpointUri
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      if(body.containsKey("url") && body.containsKey("token")) {
        AccountLinkInfo accountLinkInfo = AccountLinkInfo(body["url"], body["token"]);
        _logger.d("response start link: ${body.toString()}");
        return accountLinkInfo;

      } else {
        _logger.e("start account link invalid response body");
        _logger.e(body.toString());
      }
      return null;
    } else {
      _logger.e("error start link: ${response.body.toString()}");
      return null;
    }
  }
}