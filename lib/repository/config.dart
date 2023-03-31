import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:throwtrash/repository/config_interface.dart';

class Config implements ConfigInterface {
  static Config? _instance;
  String _apiEndpoint = "";
  String _mobileApiEndpoint ="";
  String _apiErrorUrl="";

  factory Config() {
    if(_instance==null) {
      _instance = new Config._();
    }
    return _instance!;
  }

  Future<void> initialize() async {
    String configStr = await rootBundle.loadString('json/config.json');
    Map<String, dynamic> config = json.decode(configStr);
    _instance!._apiEndpoint = config["apiEndpoint"]!;
    _instance!._mobileApiEndpoint = config["mobileApiEndpoint"]!;
    _instance!._apiErrorUrl = config["apiErrorUrl"]!;
  }

  Config._();
  String get apiEndpoint => _instance!._apiEndpoint;
  String get mobileApiEndpoint => _instance!._mobileApiEndpoint;
  String get apiErrorUrl => _instance!._apiErrorUrl;
}