import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';

import 'account_link_model_test.mocks.dart';


@GenerateMocks([AccountLinkServiceInterface])
void main() {
  group('AccountLinkModel', () {
    late MockAccountLinkServiceInterface accountLinkService;
    late AccountLinkModel accountLinkModel;

    setUp(() {
      accountLinkService = MockAccountLinkServiceInterface();
      accountLinkModel = AccountLinkModel(accountLinkService);
    });

    test('prepareAccountLink sets accountLinkInfo when successful', () async {
      final testCode = 'test_code';
      final testAccountLinkInfo = AccountLinkInfo('test_url', 'test_token');

      when(accountLinkService.getAccountLinkInfoWithCode(testCode))
          .thenAnswer((_) async => testAccountLinkInfo);

      await accountLinkModel.prepareAccountLinkInfo(testCode);

      expect(accountLinkModel.accountLinkInfo, testAccountLinkInfo);
    });

    test('startLinkAsIOS sets accountLinkInfo and notifies listeners', () async {
      final testAccountLinkInfo = AccountLinkInfo('test_url', 'test_token');
      bool hasNotifiedListeners = false;

      when(accountLinkService.startLink(any)).thenAnswer((_) async => testAccountLinkInfo);

      accountLinkModel.addListener(() {
        hasNotifiedListeners = true;
      });

      await accountLinkModel.startLinkAsIOS();

      expect(accountLinkModel.accountLinkInfo, testAccountLinkInfo);
      expect(accountLinkModel.accountLinkType, AccountLinkType.iOS);
      expect(hasNotifiedListeners, true);
    });

    test('startLinkAsWeb sets accountLinkInfo and notifies listeners', () async {
      final testAccountLinkInfo = AccountLinkInfo('test_url', 'test_token');
      bool hasNotifiedListeners = false;

      when(accountLinkService.startLink(any)).thenAnswer((_) async => testAccountLinkInfo);

      accountLinkModel.addListener(() {
        hasNotifiedListeners = true;
      });

      await accountLinkModel.startLinkAsWeb();

      expect(accountLinkModel.accountLinkInfo, testAccountLinkInfo);
      expect(accountLinkModel.accountLinkType, AccountLinkType.Web);
      expect(hasNotifiedListeners, true);
    });
  });
}
