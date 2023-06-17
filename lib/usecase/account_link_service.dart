import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/account_link_api_interface.dart';
import 'package:throwtrash/usecase/account_link_repository_interface.dart';
import 'package:throwtrash/usecase/config_interface.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/crash_report_interface.dart';
import 'package:throwtrash/usecase/user_repository_interface.dart';
import 'package:throwtrash/usecase/start_link_exception.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';

class AccountLinkService implements AccountLinkServiceInterface {
  late AccountLinkApiInterface _api;
  late AccountLinkRepositoryInterface _accountLinkRepository;
  late UserRepositoryInterface _userRepository;
  late ConfigInterface _config;
  final Logger _logger = Logger();
  final CrashReportInterface _crashReport;

  AccountLinkService(this._config,this._api,this._accountLinkRepository, this._userRepository, this._crashReport);

  @override
  Future<AccountLinkInfo?> getAccountLinkInfoWithCode(String code) async {
    AccountLinkInfo? savedAccountLink =  await _accountLinkRepository.readAccountLinkInfo();

    if(savedAccountLink != null) {
      // savedAccountLink.linkUriからredirect_uriパラメータの値を取得する
      String redirectUri = Uri.parse(savedAccountLink.linkUrl).queryParameters["redirect_uri"]!;
      // savedAccountLink.linkUriからstateパラメータの値を取得する
      String state = Uri.parse(savedAccountLink.linkUrl).queryParameters["state"]!;
      return AccountLinkInfo(
          "${this._config.mobileApiEndpoint}/enable_skill?code=$code&redirect_uri=$redirectUri&state=$state",
          savedAccountLink.token
      );
    }else {
      _logger.e("アカウントリンク情報が保存されていません");
      _crashReport.reportCrash(Exception("アカウントリンク情報が保存されていません"), fatal: true);
      return null;
    }
  }

  @override
  Future<AccountLinkInfo> startLink(AccountLinkType accountLinkType) async{
    String userId = await _userRepository.readUserId();
    if(userId.isEmpty) {
      throw StartLinkException("ユーザーIDが登録されていません");
    }
    AccountLinkInfo? accountLinkInfo = await this._api.startAccountLink(userId, accountLinkType);
    if(accountLinkInfo != null) {
      await this._accountLinkRepository.writeAccountLinkInfo(accountLinkInfo);
      return accountLinkInfo;
    }
    _logger.e("アカウントリンク開始URLの取得に失敗しました");
    _crashReport.reportCrash(Exception("アカウントリンク開始URLの取得に失敗しました"), fatal: true);
    throw StartLinkException("API呼び出しに失敗しました");
  }
}