import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';

import '../viewModels/account_link_model.dart';

class AccountLinkApi implements AccountLinkApiInterface {
  String _accountLinkApiUrl = "";
  final Logger _logger = Logger();
  late http.Client _httpClient;


  AccountLinkApi(this._accountLinkApiUrl, this._httpClient);

  @override
  Future<AccountLinkInfo?> startAccountLink(String userId, AccountLinkType accountLinkType) async {
    Uri endpointUri = Uri.parse("${this._accountLinkApiUrl}/start_link?user_id=$userId&platform=${accountLinkType.toStringValue()}");
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
      }
      return null;
    } else {
      _logger.e("error start link: ${response.body.toString()}");
      return null;
    }
  }
}