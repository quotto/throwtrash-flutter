import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';
import 'package:http/http.dart' as http;

class AccountLinkApi implements AccountLinkApiInterface {
  String _accountLinkApiUrl = "";
  final Logger _logger = Logger();
  String _platform = "web";
  AccountLinkApi(this._accountLinkApiUrl) {
    if (Platform.isAndroid) {
      _platform = "android";
    } else if (Platform.isIOS) {
      _platform = "ios";
    }
  }

  @override
  Future<AccountLinkInfo?> startAccountLink(String userId) async {
    Uri endpointUri = Uri.parse("${this._accountLinkApiUrl}/start_link?user_id=$userId&platform=$_platform");
    http.Response response = await http.get(
      endpointUri
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      AccountLinkInfo accountLinkInfo = AccountLinkInfo();
      if(body.containsKey("url") && body.containsKey("token")) {
        accountLinkInfo.linkUrl = body["url"];
        String? redirectUri = Uri
            .parse(accountLinkInfo.linkUrl)
            .queryParameters["redirect_uri"];
        String? token = body["token"];
        if (redirectUri != null && token != null) {
          accountLinkInfo.redirectUri = redirectUri;
          accountLinkInfo.token = token;
          _logger.d("response start link: ${body.toString()}");
          return accountLinkInfo;
        } else {
          _logger.e("start account link invalid response body");
        }
      }
      return null;
    } else {
      _logger.e("error start link: ${response.body.toString()}");
      return null;
    }
  }
}