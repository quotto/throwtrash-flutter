import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';

abstract class AccountLinkServiceInterface {
  Future<AccountLinkInfo> startLink(AccountLinkType accountLinkType);
  Future<AccountLinkInfo?> getAccountLinkInfoWithCode(String code);
}