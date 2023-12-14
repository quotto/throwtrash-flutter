import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../usecase/change_theme_service_interface.dart';

class ChangeThemeModel extends ChangeNotifier{
  late bool _darkMode;
  bool get darkMode => _darkMode;
  final ChangeThemeServiceInterface _changeThemeServiceInterface;
  ChangeThemeModel(this._changeThemeServiceInterface);

  Future<void> init() async {
    _darkMode = await _changeThemeServiceInterface.readDarkMode();
  }

  Future<void> switchDarkMode() async {
    _darkMode = !_darkMode;
    _changeThemeServiceInterface.switchDarkMode(_darkMode).catchError((e) {
        log(e.toString());
      }
    );
    notifyListeners();
  }
}