/*
AccountLinkRepositoryのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/usecase/repository/account_link_repository_interface.dart';
import 'package:http/http.dart' as http;

import 'trash_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>(),MockSpec<http.Client>()])
void main () {
  final _preferences = MockSharedPreferences();
  AccountLinkRepository.initialize(_preferences);
  AccountLinkRepositoryInterface accountLinkRepository = AccountLinkRepository();
  group("readAccountLinkInfo", () {
    test("AccountLinkInfoが保存されている場合はAccountLinkInfoが取得できること", () async {
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_TOKEN_KEY)).thenReturn("test_token");
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_URL_KEY)).thenReturn("https://example.com");
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_REDIRECT_URI_KEY)).thenReturn("https://example.com");
      AccountLinkInfo? accountLinkInfo = await accountLinkRepository.readAccountLinkInfo();
      expect(accountLinkInfo, isNotNull);
      expect(accountLinkInfo!.linkUrl, "https://example.com");
      expect(accountLinkInfo.token, "test_token");
    });
    test("AccountLinkInfoが保存されていない場合はnullが取得できること", () async {
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_TOKEN_KEY)).thenReturn(null);
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_URL_KEY)).thenReturn(null);
      when(_preferences.getString(AccountLinkRepository.ACCOUNT_LINK_REDIRECT_URI_KEY)).thenReturn(null);
      AccountLinkInfo? accountLinkInfo = await accountLinkRepository.readAccountLinkInfo();
      expect(accountLinkInfo, isNull);
    });
  });
  group("writeAccountLinkInfo", () {
    test("AccountLinkInfoが保存できること", () async {
      when(_preferences.setString(AccountLinkRepository.ACCOUNT_LINK_TOKEN_KEY, "test_token")).thenAnswer((_) async => true);
      when(_preferences.setString(AccountLinkRepository.ACCOUNT_LINK_URL_KEY, "https://example.com")).thenAnswer((_) async => true);
      when(_preferences.setString(AccountLinkRepository.ACCOUNT_LINK_REDIRECT_URI_KEY, "https://example.com")).thenAnswer((_) async => true);
      AccountLinkInfo accountLinkInfo = AccountLinkInfo("https://example.com", "test_token");
      bool result = await accountLinkRepository.writeAccountLinkInfo(accountLinkInfo);
      expect(result, isTrue);
    });
  });
  group("initialize",() {
    test("AccountLinkRepositoryが初期化されている場合はエラーが発生すること", () {
      expect(() => AccountLinkRepository.initialize(_preferences), throwsStateError);
    });
  });
}