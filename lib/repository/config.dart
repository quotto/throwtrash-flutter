import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:throwtrash/usecase/config_interface.dart';
import 'package:throwtrash/usecase/environment_provider_interface.dart';

class Config implements ConfigInterface {
  static Config? _instance;
  String _apiEndpoint = "";
  String _mobileApiEndpoint ="";
  String _apiErrorUrl="";
  String _version="";

  factory Config() {
    if(_instance==null) {
      _instance = new Config._();
    }
    return _instance!;
  }

  Future<void> initialize(EnvironmentProviderInterface environmentProvider) async {
    String configStr = await rootBundle.loadString('json/${environmentProvider.flavor}/config.json');
    Map<String, dynamic> config = json.decode(configStr);
    _instance!._apiEndpoint = config["apiEndpoint"]!;
    _instance!._mobileApiEndpoint = config["mobileApiEndpoint"]!;
    _instance!._apiErrorUrl = config["apiErrorUrl"]!;

    // package_info_plusを使ってバージョン情報を取得してインスタンス変数に格納
    // flavorがdevの場合はサフィックスを付与する
    String version = environmentProvider.versionName;
    if(environmentProvider.flavor!="production") {
      version = "$version${environmentProvider.appNameSuffix}";
    }
    _instance!._version = version;
  }

  Config._();
  String get apiEndpoint => _instance!._apiEndpoint;
  String get mobileApiEndpoint => _instance!._mobileApiEndpoint;
  String get apiErrorUrl => _instance!._apiErrorUrl;
  String get version => _instance!._version;
}