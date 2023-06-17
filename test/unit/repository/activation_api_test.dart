/*
ActivationApiのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:http/http.dart' as http;
import 'package:throwtrash/usecase/config_interface.dart';

import 'package:http/src/mock_client.dart' as httpMock;

import 'activation_api_test.mocks.dart';

@GenerateMocks([http.Client, ConfigInterface])
void main(){
  // ConfigInterfaceをモック化する
  ConfigInterface mockConfig = MockConfigInterface();
  group("startActivation", () {
    test("startActivationでActivationCodeが取得できること", () async {
      // http.Clientをモック化する
      http.Client mockClient = httpMock.MockClient((request) async {
        return Response('{"code": "test_code"}', 200);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiEndpoint).thenReturn("https://example.com");

      ActivationApiInterface activationApi = ActivationApi(mockConfig, mockClient);
      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode, "test_code");
    });
    test("startActivationで200以外のレスポンスの場合はブランクが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = httpMock.MockClient((request) async {
        return Response('{"error": "error"}', 500);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiEndpoint).thenReturn("https://example.com");

      ActivationApiInterface activationApi = ActivationApi(mockConfig, mockClient);
      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode.length, 0);
    });
    test("startActivationでレスポンスボディにcodeが存在しない場合はブランクが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = httpMock.MockClient((request) async {
        return Response('{"error": "error"}', 200);
      });
      // ConfigInterfaceをモック化する
      when(mockConfig.mobileApiEndpoint).thenReturn("https://example.com");

      ActivationApiInterface activationApi = ActivationApi(mockConfig, mockClient);
      String? activationCode = await activationApi.requestActivationCode("test_user_id");
      expect(activationCode.length, 0);
    });
  });
}