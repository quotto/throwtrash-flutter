import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/url_launcher_interface.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';

import 'account_link_model_test.mocks.dart';


@GenerateMocks([AccountLinkServiceInterface, UrlLauncherInterface])
void main() {
  group('AccountLinkModel', () {
    late MockAccountLinkServiceInterface accountLinkService;
    late AccountLinkModel accountLinkModel;
    late MockUrlLauncherInterface urlLauncher;

    setUp(() {
      accountLinkService = MockAccountLinkServiceInterface();
      urlLauncher = MockUrlLauncherInterface();
      accountLinkModel = AccountLinkModel(accountLinkService, urlLauncher);
    });

    test('prepareAccountLink sets accountLinkInfo when successful', () async {
      final testCode = 'test_code';
      final testAccountLinkInfo = AccountLinkInfo('test_url', 'test_token');

      when(accountLinkService.getAccountLinkInfoWithCode(testCode))
          .thenAnswer((_) async => testAccountLinkInfo);

      await accountLinkModel.prepareAccountLink(testCode);

      expect(accountLinkModel.accountLinkInfo, testAccountLinkInfo);
    });

    test('startLink sets accountLinkInfo and notifies listeners', () async {
      final testAccountLinkInfo = AccountLinkInfo('test_url', 'test_token');
      bool hasNotifiedListeners = false;

      when(accountLinkService.startLink(any)).thenAnswer((_) async => testAccountLinkInfo);
      when(urlLauncher.canLaunchUrl(any)).thenAnswer((_) async => true);

      accountLinkModel.addListener(() {
        hasNotifiedListeners = true;
      });

      await accountLinkModel.startLink();

      expect(accountLinkModel.accountLinkInfo, testAccountLinkInfo);
      expect(hasNotifiedListeners, true);
      verify(urlLauncher.canLaunchUrl(Uri.parse(
          "https://alexa.amazon.com/spa/skill-account-linking-consent"
      ))).called(1);
    });
  });
}
