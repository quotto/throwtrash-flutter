/*
ActivationApiのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/usecase/repository/activation_api_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';

import 'activation_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<AppConfigProviderInterface>()])
void main(){
  // ConfigInterfaceをモック化する
  AppConfigProviderInterface mockConfig = MockAppConfigProviderInterface();
  MockClient mockClient = MockClient();
  late ActivationApi activationApi;
  setUpAll(() {
    ActivationApi.initialize(mockConfig, mockClient);
    activationApi = ActivationApi();
  });
  group("startActivation", () {
    test("startActivationでActivationCodeが取得できること", () async {
      when(mockClient.get(any,headers: {
        "content-type": "application/json;charset=utf-8",
        "Accept": "application/json"
      })).thenAnswer((_) async {
        return Response('{"code": "test_code"}', 200);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiUrl).thenReturn("https://example.com");

      ActivationApiInterface activationApi = ActivationApi();
      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode, "test_code");
    });
    test("startActivationで200以外のレスポンスの場合はブランクが返ること", () async {
      // http.Clientをモック化する
      when(mockClient.get(any,headers: {
        "content-type": "application/json;charset=utf-8",
        "Accept": "application/json"
      })).thenAnswer((_) async {
        return Response('{"error": "error"}', 500);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiUrl).thenReturn("https://example.com");

      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode.length, 0);
    });
    test("startActivationでレスポンスボディにcodeが存在しない場合はブランクが返ること", () async {
      // http.Clientをモック化する
      when(mockClient.get(any,headers: {
        "content-type": "application/json;charset=utf-8",
        "Accept": "application/json"
      })).thenAnswer((_) async {
        return Response('{"error": "error"}', 200);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiUrl).thenReturn("https://example.com");

      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode.length, 0);
    });
    test("initializeが繰り返し呼ばれた場合はエラーが発生すること", () async {
      expect(() => ActivationApi.initialize(mockConfig, mockClient), throwsStateError);
    });
  });
}