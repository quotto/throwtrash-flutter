import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

class AppConfigProvider implements AppConfigProviderInterface {
  static AppConfigProvider? _instance;
  String _trashApiEndpoint = "";
  String _mobileApiUrl ="";
  String _accountLinkErrorUrl="";
  String _version="";
  String _alarmApiUrl = "";

  factory AppConfigProvider() {
    if(_instance==null) {
      throw StateError("AppConfigProvider is not initialized");
    }
    return _instance!;
  }

  static Future<void> initialize(EnvironmentProviderInterface environmentProvider) async {
    if(_instance != null) {
      throw StateError("AppConfigProvider is already initialized");
    }
    _instance = AppConfigProvider._();

    String configStr = await rootBundle.loadString('json/${environmentProvider.flavor}/config.json');
    Map<String, dynamic> config = json.decode(configStr);
    _instance!._trashApiEndpoint = config["apiEndpoint"]!;
    _instance!._mobileApiUrl = config["mobileApiEndpoint"]!;
    _instance!._accountLinkErrorUrl = config["apiErrorUrl"]!;
    _instance!._alarmApiUrl = config["alarmApiUrl"]!;

    // package_info_plusを使ってバージョン情報を取得してインスタンス変数に格納
    // flavorがdevの場合はサフィックスを付与する
    String version = environmentProvider.versionName;
    if(environmentProvider.flavor!="production") {
      version = "$version${environmentProvider.appNameSuffix}";
    }
    _instance!._version = version;
  }

  static void reset() {
    _instance = null;
  }

  AppConfigProvider._();
  String get trashApiUrl => _instance!._trashApiEndpoint;
  String get mobileApiUrl => _instance!._mobileApiUrl;
  String get accountLinkErrorUrl => _instance!._accountLinkErrorUrl;
  String get version => _instance!._version;
  String get alarmApiUrl => _instance!._alarmApiUrl;
}