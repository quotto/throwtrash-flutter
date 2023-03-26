import 'package:flutter/cupertino.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';

import '../models/account_link_info.dart';
import '../usecase/url_launcher_interface.dart';

enum AccountLinkType {
  iOS,
  Web
}

extension AccountLinkTypeExtension on AccountLinkType {
  String toStringValue() {
    switch(this) {
      case AccountLinkType.iOS:
        return "ios";
      case AccountLinkType.Web:
        return "web";
      default:
        return "ios";
    }
  }
}

class AccountLinkModel extends ChangeNotifier {
  late AccountLinkServiceInterface _accountLinkService;
  late UrlLauncherInterface _urlLauncher;
  AccountLinkModel(this._accountLinkService, this._urlLauncher);

  late AccountLinkInfo _accountLinkInfo;
  AccountLinkInfo get accountLinkInfo => _accountLinkInfo;

  AccountLinkType _accountLinkType = AccountLinkType.iOS;
  AccountLinkType get accountLinkType => _accountLinkType;

  Future<void> prepareAccountLink(String code) async {
    return _accountLinkService.getAccountLinkInfoWithCode(code).then((accountLinkInfo){
      if(accountLinkInfo != null) {
        _accountLinkInfo = accountLinkInfo;
      }
    });
  }

  Future<void> startLink() async {
    if (!await _urlLauncher.canLaunchUrl(Uri.parse(
        "https://alexa.amazon.com/spa/skill-account-linking-consent"))) {
      _accountLinkType = AccountLinkType.Web;
    }
    _accountLinkInfo = await _accountLinkService.startLink(_accountLinkType);
    notifyListeners();
  }
}