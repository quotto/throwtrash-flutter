/*
Configのテスト
 */

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/app_config_provider.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

import 'config_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EnvironmentProviderInterface>()])
void main(){
  group("Config", () {
    MockEnvironmentProviderInterface environmentProvider = MockEnvironmentProviderInterface();
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(
              Uint8List.fromList(
                  '{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com", "alarmApiUrl": "https://alarm.com"}'.codeUnits
              )
          );
        },
      );
    });
    tearDown(() {
      AppConfigProvider.reset();
      clearInteractions(environmentProvider);
    });
    test("複数回コンストラクタを実行した場合は同じインスタンスが返ること", () async {
      when(environmentProvider.flavor).thenReturn("development");
      when(environmentProvider.versionName).thenReturn("1.0.0");
      when(environmentProvider.appNameSuffix).thenReturn("-dev");
      when(environmentProvider.appIdSuffix).thenReturn("-dev");
      when(environmentProvider.alarmApiKey).thenReturn("alarmApiKey");
      await AppConfigProvider.initialize(environmentProvider);
      AppConfigProviderInterface config1 = AppConfigProvider();
      AppConfigProviderInterface config2 = AppConfigProvider();
      expect(config1, config2);
    });
    test("flavorがproductionの場合はバージョンにサフィックスが付与されないこと",() async{
      // Create a fake rootBundle
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(
              Uint8List.fromList(
                  '{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com", "alarmApiUrl": "https://alarm.com"}'.codeUnits
              )
          );
        },
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('dev.fluttercommunity.plus/package_info'),  (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{
            'appName': 'net.mythrowaway',
            'packageName': 'net.mythrowaway',
            'version': '1.0.0',
            'buildNumber': '1',
          };
        }
        return null;
      });
      when(environmentProvider.flavor).thenReturn("production");
      when(environmentProvider.versionName).thenReturn("1.0.0");
      when(environmentProvider.appNameSuffix).thenReturn(".prod");
      when(environmentProvider.appIdSuffix).thenReturn(".prod");
      when(environmentProvider.alarmApiKey).thenReturn("alarmApiKey");
      await AppConfigProvider.initialize(environmentProvider);
      AppConfigProvider config = AppConfigProvider();
      expect(config.version, "1.0.0");
    });
    test("flavorがdevelopmentの場合はバージョンにサフィックスが付与されること",() async{
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(
              Uint8List.fromList(
                  '{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com", "alarmApiUrl": "https://alarm.com"}'.codeUnits
              )
          );
        },
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('dev.fluttercommunity.plus/package_info'),  (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{
            'appName': 'net.mythrowaway',
            'packageName': 'net.mythrowaway',
            'version': '1.0.0',
            'buildNumber': '1',
          };
        }
        return null;
      });

      when(environmentProvider.flavor).thenReturn("development");
      when(environmentProvider.versionName).thenReturn("1.0.0");
      when(environmentProvider.appNameSuffix).thenReturn("-dev");
      when(environmentProvider.appIdSuffix).thenReturn("-dev");
      when(environmentProvider.alarmApiKey).thenReturn("alarmApiKey");
      await AppConfigProvider.initialize(environmentProvider);
      AppConfigProviderInterface config = AppConfigProvider();
      expect(config.trashApiUrl, "https://example.com");
      expect(config.mobileApiUrl, "https://example.com");
      expect(config.accountLinkErrorUrl, "https://example.com");
      expect(config.alarmApiUrl, "https://alarm.com");
      expect(config.version, "1.0.0-dev");
    });
  });
}