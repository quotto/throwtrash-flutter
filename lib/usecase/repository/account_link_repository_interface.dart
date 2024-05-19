import 'package:throwtrash/models/account_link_info.dart';

abstract class AccountLinkRepositoryInterface {
  Future<bool> writeAccountLinkInfo(AccountLinkInfo info);
  Future<AccountLinkInfo?> readAccountLinkInfo();
}