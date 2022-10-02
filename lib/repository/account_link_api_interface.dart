import 'package:throwtrash/models/account_link_info.dart';

abstract class AccountLinkApiInterface {
  Future<AccountLinkInfo?> startAccountLink(String userId);
}