import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/account_link_repository_interface.dart';

class AccountLinkRepository implements AccountLinkRepositoryInterface {
  static const String ACCOUNT_LINK_TOKEN_KEY = "ACCOUNT_LINK_TOKEN";
  static const String ACCOUNT_LINK_URL_KEY = "ACCOUNT_LINK_URL";
  static const String ACCOUNT_LINK_REDIRECT_URI_KEY = "ACCOUNT_LINK_REDIRECT_URI";
  final Logger _logger = Logger();
  @override
  Future<AccountLinkInfo?> readAccountLinkInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString(ACCOUNT_LINK_TOKEN_KEY);
    String? url = preferences.getString(ACCOUNT_LINK_URL_KEY);
    if(token != null && url != null) {
      AccountLinkInfo accountLinkInfo = AccountLinkInfo(url, token);
      return accountLinkInfo;
    }
    _logger.w("AccountLinkInfoが保存されていません");
    return null;
  }

  @override
  Future<bool> writeAccountLinkInfo(AccountLinkInfo info) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool result = await preferences.setString(ACCOUNT_LINK_TOKEN_KEY, info.token)
      && await preferences.setString(ACCOUNT_LINK_URL_KEY, info.linkUrl);
    return result;
  }
  
}