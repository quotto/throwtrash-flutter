import 'package:throwtrash/models/account_link_info.dart';

abstract class AccountLinkServiceInterface {
  Future<AccountLinkInfo> startLink();
  Future<bool> enableSkill(String code, String state);
}