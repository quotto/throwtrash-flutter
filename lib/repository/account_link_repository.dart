import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/repository/account_link_repository_interface.dart';

class AccountLinkRepository implements AccountLinkRepositoryInterface {
  static const String ACCOUNT_LINK_TOKEN_KEY = "ACCOUNT_LINK_TOKEN";
  static const String ACCOUNT_LINK_URL_KEY = "ACCOUNT_LINK_URL";
  static const String ACCOUNT_LINK_REDIRECT_URI_KEY = "ACCOUNT_LINK_REDIRECT_URI";
  static AccountLinkRepository? _instance;

  final SharedPreferences _preferences;
  final Logger _logger = Logger();

  AccountLinkRepository._(this._preferences);

  static void initialize(SharedPreferences preferences) {
    if(_instance != null) {
      throw StateError('AccountLinkRepository is already initialized');
    }
    _instance = AccountLinkRepository._(preferences);
  }

  factory AccountLinkRepository() {
    if(_instance == null) {
      throw StateError('AccountLinkRepository is not initialized');
    }
    return _instance!;
  }

  @override
  Future<AccountLinkInfo?> readAccountLinkInfo() async {
    String? token = this._preferences.getString(ACCOUNT_LINK_TOKEN_KEY);
    String? url = this._preferences.getString(ACCOUNT_LINK_URL_KEY);
    if(token != null && url != null) {
      AccountLinkInfo accountLinkInfo = AccountLinkInfo(url, token);
      return accountLinkInfo;
    }
    _logger.w("AccountLinkInfoが保存されていません");
    return null;
  }

  @override
  Future<bool> writeAccountLinkInfo(AccountLinkInfo info) async {
    bool result = await this._preferences.setString(ACCOUNT_LINK_TOKEN_KEY, info.token)
      && await this._preferences.setString(ACCOUNT_LINK_URL_KEY, info.linkUrl);
    return result;
  }
}