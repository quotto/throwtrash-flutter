import 'package:throwtrash/models/account_link_info.dart';

import '../viewModels/account_link_model.dart';

abstract class AccountLinkApiInterface {
  Future<AccountLinkInfo?> startAccountLink(String userId,AccountLinkType accountLinkType);
}