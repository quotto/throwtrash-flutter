/*
AccountLinkRepositoryのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/repository/account_link_repository_interface.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
void main () {
  setUpAll(() {
    // SharedPreferencesをモック化する
    SharedPreferences.setMockInitialValues({});
  });
  setUp(() {
    // SharedPreferencesをクリアする
    SharedPreferences.getInstance().then((value) {
      value.clear();
    });
  });
  group("readAccountLinkInfo", () {
    test("AccountLinkInfoが保存されている場合はAccountLinkInfoが取得できること", () async {
      // SharedPreferencesに値をセットする
      SharedPreferences.getInstance().then((value) {
        value.setString(AccountLinkRepository.ACCOUNT_LINK_TOKEN_KEY, "test_token");
        value.setString(AccountLinkRepository.ACCOUNT_LINK_URL_KEY, "https://example.com");
        value.setString(AccountLinkRepository.ACCOUNT_LINK_REDIRECT_URI_KEY, "https://example.com");
      });
      AccountLinkRepositoryInterface accountLinkRepository = AccountLinkRepository();
      AccountLinkInfo? accountLinkInfo = await accountLinkRepository.readAccountLinkInfo();
      expect(accountLinkInfo, isNotNull);
      expect(accountLinkInfo!.linkUrl, "https://example.com");
      expect(accountLinkInfo.token, "test_token");
    });
    test("AccountLinkInfoが保存されていない場合はnullが取得できること", () async {
      AccountLinkRepositoryInterface accountLinkRepository = AccountLinkRepository();
      AccountLinkInfo? accountLinkInfo = await accountLinkRepository.readAccountLinkInfo();
      expect(accountLinkInfo, isNull);
    });
  });
  group("writeAccountLinkInfo", () {
    test("AccountLinkInfoが保存できること", () async {
      AccountLinkRepositoryInterface accountLinkRepository = AccountLinkRepository();
      AccountLinkInfo accountLinkInfo = AccountLinkInfo("https://example.com", "test_token");
      bool result = await accountLinkRepository.writeAccountLinkInfo(accountLinkInfo);
      expect(result, isTrue);
      // SharedPreferencesに値がセットされていることを確認する
      await SharedPreferences.getInstance().then((value) {
        expect(value.getString(AccountLinkRepository.ACCOUNT_LINK_TOKEN_KEY), "test_token");
        expect(value.getString(AccountLinkRepository.ACCOUNT_LINK_URL_KEY), "https://example.com");
      });
    });
  });
}