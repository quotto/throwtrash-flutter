import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository_interface.dart';
import 'package:throwtrash/repository/config_interface.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/start_link_exception.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountLinkService implements AccountLinkServiceInterface {
  late AccountLinkApiInterface _api;
  late AccountLinkRepositoryInterface _accountLinkRepository;
  late UserRepositoryInterface _userRepository;
  late ConfigInterface _config;
  Logger _logger = Logger();
  AccountLinkService(this._config,this._api,this._accountLinkRepository, this._userRepository);
  @override
  Future<AccountLinkInfo?> getAccountLinkInfoWithCode(String code) async {
    AccountLinkInfo? savedAccountLink =  await _accountLinkRepository.readAccountLinkInfo();
    return savedAccountLink != null ? AccountLinkInfo(
      "${this._config.mobileApiEndpoint}/enable_skill?code=$code&redirect_uri=${savedAccountLink!.linkUrl}",
      savedAccountLink!.token
    ) : null;
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
    throw StartLinkException("API呼び出しに失敗しました");
  }

}