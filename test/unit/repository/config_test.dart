/*
Configのテスト
 */
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/repository/config.dart';
import 'package:throwtrash/usecase/config_interface.dart';
import 'package:throwtrash/usecase/environment_provider_interface.dart';

void main(){
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group("Config", () {
    test("Configの初期化ができること", () async {
      // Create a fake rootBundle
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(Uint8List.fromList('{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com"}'.codeUnits));
        },
      );

      MockEnvironmentProvider environmentProvider = MockEnvironmentProvider();
      environmentProvider.setEnvironment("development", "1.0.0", "-dev", "-dev");
      Config config = Config();
      await config.initialize(environmentProvider);
      expect(config.apiEndpoint, "https://example.com");
      expect(config.mobileApiEndpoint, "https://example.com");
      expect(config.apiErrorUrl, "https://example.com");
    });
    test("複数回コンストラクタを実行した場合は同じインスタンスが返ること", () async {
      ConfigInterface config1 = Config();
      ConfigInterface config2 = Config();
      expect(config1, config2);
    });
    test("flavorがproductionの場合はバージョンにサフィックスが付与されないこと",() async{
      // Create a fake rootBundle
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(Uint8List.fromList('{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com"}'.codeUnits));
        },
      );
      const MethodChannel('dev.fluttercommunity.plus/package_info').setMockMethodCallHandler((MethodCall methodCall) async {
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
      MockEnvironmentProvider environmentProvider = MockEnvironmentProvider();
      environmentProvider.setEnvironment("production", "1.0.0", ".prod", ".prod");
      Config config = Config();
      await config.initialize(environmentProvider);
      expect(config.version, "1.0.0");
    });
    test("flavorがdevelopmentの場合はバージョンにサフィックスが付与されること",() async{
      // Create a fake rootBundle
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
            (ByteData? message) async {
          return ByteData.sublistView(Uint8List.fromList('{"apiEndpoint": "https://example.com", "mobileApiEndpoint": "https://example.com", "apiErrorUrl": "https://example.com"}'.codeUnits));
        },
      );
      const MethodChannel('dev.fluttercommunity.plus/package_info').setMockMethodCallHandler((MethodCall methodCall) async {
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
      MockEnvironmentProvider environmentProvider = MockEnvironmentProvider();
      environmentProvider.setEnvironment("development", "1.0.0", "-dev", "-dev");
      Config config = Config();
      await config.initialize(environmentProvider);
      expect(config.version, "1.0.0-dev");
    });
  });
}

class MockEnvironmentProvider implements EnvironmentProviderInterface {
  String _flavor = "";
  String _versionName = "";
  String _appNameSuffix = "";
  String _appIdSuffix = "";
  void setEnvironment(String flavor, String versionName, String appNameSuffix, String appIdSuffix) {
    this._flavor = flavor;
    this._versionName = versionName;
    this._appNameSuffix = appNameSuffix;
    this._appIdSuffix = appIdSuffix;
  }
  @override
  String get flavor => _flavor;

  @override
  String get versionName => _versionName;

  @override
  String get appNameSuffix => _appNameSuffix;

  @override
  String get appIdSuffix => _appIdSuffix;
}