/*
AccountLinkApiのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api.dart';
import 'package:throwtrash/usecase/repository/account_link_api_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:http/http.dart' as http;

import 'account_link_api_test.mocks.dart' as mock;

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<AppConfigProviderInterface>()])
void main () {
  late AccountLinkApi accountLinkApi;
  mock.MockClient httpClient = mock.MockClient();
  mock.MockAppConfigProviderInterface appConfigProvider = mock.MockAppConfigProviderInterface();
  setUpAll(() => {
    AccountLinkApi.initialize(appConfigProvider, httpClient)
  });
  group("startAccountLink", () {
    test("AccountLinkType=WebでstartAccountLinkでAccountLinkInfoが取得できること", () async {
      // http.Clientをモック化する
      when(httpClient.get(any)).thenAnswer((_) async {
        return Response('{"url": "https://example.com", "token": "test_token"}', 200);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi();
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNotNull);
      expect(accountLinkInfo!.linkUrl, "https://example.com");
      expect(accountLinkInfo.token, "test_token");
    });
    test("startAccountLinkでエラーが発生した場合はnullが返ること", () async {
      // http.Clientをモック化する
      when(httpClient.get(any)).thenAnswer((_) async {
        return Response('{"error": "error"}', 500);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi();
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNull);
    });
    test("startAccountLinkでレスポンスが不正な場合はnullが返ること", () async {
      // http.Clientをモック化する
      when(httpClient.get(any)).thenAnswer((_) async {
        return Response('{"error": "error"}', 200);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi();
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNull);
    });
    test("initializeが繰り返し呼ばれた場合はエラーが発生すること", () async {
      expect(() => AccountLinkApi.initialize(appConfigProvider, httpClient), throwsStateError);
    });
  });
}