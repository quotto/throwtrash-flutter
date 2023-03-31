/*
AccountLinkApiのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_api.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
void main () {
  group("startAccountLink", () {
    test("AccountLinkType=WebでstartAccountLinkでAccountLinkInfoが取得できること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"url": "https://example.com", "token": "test_token"}', 200);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi("https://example.com", mockClient);
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNotNull);
      expect(accountLinkInfo!.linkUrl, "https://example.com");
      expect(accountLinkInfo.token, "test_token");
    });
    test("startAccountLinkでエラーが発生した場合はnullが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 500);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi("https://example.com", mockClient);
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNull);
    });
    test("startAccountLinkでレスポンスが不正な場合はnullが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 200);
      });

      AccountLinkApiInterface accountLinkApi = AccountLinkApi("https://example.com", mockClient);
      AccountLinkInfo? accountLinkInfo = await accountLinkApi.startAccountLink("test_user_id", AccountLinkType.Web);
      expect(accountLinkInfo, isNull);
    });
  });
}