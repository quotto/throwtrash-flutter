/*
Configのテスト
 */
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/repository/config.dart';
import 'package:throwtrash/usecase/config_interface.dart';

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

      ConfigInterface config = Config();
      await config.initialize();
      expect(config.apiEndpoint, "https://example.com");
      expect(config.mobileApiEndpoint, "https://example.com");
      expect(config.apiErrorUrl, "https://example.com");
    });
    test("複数回コンストラクタを実行した場合は同じインスタンスが返ること", () async {
      ConfigInterface config1 = Config();
      ConfigInterface config2 = Config();
      expect(config1, config2);
    });
  });
}