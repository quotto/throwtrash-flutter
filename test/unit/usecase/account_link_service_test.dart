import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/account_link_api_interface.dart';
import 'package:throwtrash/usecase/repository/account_link_repository_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/crash_report_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/account_link_service.dart';
import 'package:throwtrash/usecase/start_link_exception.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';

import 'account_link_service_test.mocks.dart';


@GenerateMocks([
  AccountLinkApiInterface,
  AccountLinkRepositoryInterface,
  UserRepositoryInterface,
  AppConfigProviderInterface,
  CrashReportInterface
])
void main() {
  group('AccountLinkService', () {
    late MockAccountLinkApiInterface accountLinkApi;
    late MockAccountLinkRepositoryInterface accountLinkRepository;
    late MockUserRepositoryInterface userRepository;
    late MockAppConfigProviderInterface config;
    late AccountLinkService accountLinkService;
    late MockCrashReportInterface crashReport;

    setUp(() {
      accountLinkApi = MockAccountLinkApiInterface();
      accountLinkRepository = MockAccountLinkRepositoryInterface();
      userRepository = MockUserRepositoryInterface();
      config = MockAppConfigProviderInterface();
      crashReport = MockCrashReportInterface();
      accountLinkService = AccountLinkService(
          config,
          accountLinkApi,
          accountLinkRepository,
          userRepository,
      crashReport);
    });

    test('getAccountLinkInfoWithCode returns correct AccountLinkInfo when savedAccountLink is not null', () async {
      final testCode = 'test_code';
      final testLinkUrl = 'https://example.com/link_url?redirect_uri=https://example.com/redirect_uri&state=test_state';
      final testToken = 'test_token';
      final testApiEndpoint = 'https://api.example.com';
      final savedAccountLink = AccountLinkInfo(testLinkUrl, testToken);

      when(config.mobileApiUrl).thenReturn(testApiEndpoint);
      when(accountLinkRepository.readAccountLinkInfo()).thenAnswer((_) async => savedAccountLink);

      final accountLinkInfo = await accountLinkService.getAccountLinkInfoWithCode(testCode);

      expect(accountLinkInfo!.linkUrl, '$testApiEndpoint/enable_skill?code=$testCode&redirect_uri=https://example.com/redirect_uri&state=test_state');
      expect(accountLinkInfo.token, testToken);
    });

    test('getAccountLinkInfoWithCode returns null when savedAccountLink is null', () async {
      final testCode = 'test_code';

      when(accountLinkRepository.readAccountLinkInfo()).thenAnswer((_) async => null);

      final accountLinkInfo = await accountLinkService.getAccountLinkInfoWithCode(testCode);

      expect(accountLinkInfo, null);
    });

    test('startLink returns AccountLinkInfo when successful', () async {
      final testUserId = 'test_user_id';
      final testLinkUrl = 'https://example.com/link_url';
      final testToken = 'test_token';
      final accountLinkType = AccountLinkType.Web;
      final accountLinkInfo = AccountLinkInfo(testLinkUrl, testToken);

      when(userRepository.readUser()).thenAnswer((_) async => User(testUserId));
      when(accountLinkApi.startAccountLink(testUserId, accountLinkType)).thenAnswer((_) async => accountLinkInfo);
      when(accountLinkRepository.writeAccountLinkInfo(accountLinkInfo)).thenAnswer((_) async => true);

      final result = await accountLinkService.startLink(accountLinkType);

      expect(result.linkUrl, testLinkUrl);
      expect(result.token, testToken);
    });

    test('startLink throws StartLinkException when userId is empty', () async {
      final accountLinkType = AccountLinkType.Web;

      when(userRepository.readUser()).thenAnswer((_) async => null);

      expect(() => accountLinkService.startLink(accountLinkType), throwsA(isA<StartLinkException>()));
    });

    test('startLink throws StartLinkException when API call fails', () async {
      final testUserId = 'test_user_id';
      final accountLinkType = AccountLinkType.Web;

      when(userRepository.readUser()).thenAnswer((_) async => User(testUserId));
      when(accountLinkApi.startAccountLink(testUserId, accountLinkType)).thenAnswer((_) async => null);

      expect(() => accountLinkService.startLink(accountLinkType), throwsA(isA<StartLinkException>()));
    });
  });
}
