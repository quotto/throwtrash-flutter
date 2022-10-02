import 'package:logger/logger.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository_interface.dart';
import 'package:throwtrash/repository/config_interface.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/start_link_exception.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountLinkService implements AccountLinkServiceInterface {
  late AccountLinkApiInterface _api;
  late AccountLinkRepositoryInterface _accountLinkRepository;
  late UserRepositoryInterface _userRepository;
  late ConfigInterface _config;
  Logger _logger = Logger();
  AccountLinkService(this._config,this._api,this._accountLinkRepository, this._userRepository);
  @override
  Future<bool> enableSkill(String code, String state) async {
    AccountLinkInfo? accountLinkInfo = await _accountLinkRepository.readAccountLinkInfo();
    if(accountLinkInfo != null) {
      Uri enableSkillUrl = Uri.parse("${this._config.mobileApiEndpoint}/enable_skill?token=${accountLinkInfo.token}&redirect_uri=${accountLinkInfo.redirectUri}&code=$code&state=$state");
      _logger.d("enable skill url: ${enableSkillUrl.toString()}");
      if(await canLaunchUrl(enableSkillUrl)) {
        return launchUrl(enableSkillUrl,);
      }
    }
    return false;
  }

  @override
  Future<AccountLinkInfo> startLink() async{
    String userId = await _userRepository.readUserId();
    if(userId.isEmpty) {
      throw StartLinkException("ユーザーIDが登録されていません");
    }
    AccountLinkInfo? accountLinkInfo = await this._api.startAccountLink(userId);
    if(accountLinkInfo != null &&
        await this._accountLinkRepository.writeAccountLinkInfo(accountLinkInfo)
    ) {
      return accountLinkInfo;
    }
    throw StartLinkException("API呼び出しに失敗しました");
  }

}