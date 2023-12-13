import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../usecase/change_theme_service_interface.dart';

class ChangeThemeModel extends ChangeNotifier{
  bool _darkMode = false;
  bool get darkMode => _darkMode;
  final ChangeThemeServiceInterface _changeThemeServiceInterface;
  ChangeThemeModel(this._changeThemeServiceInterface);
  Future<void> switchDarkMode() async {
    _darkMode = !_darkMode;
    _changeThemeServiceInterface.switchDarkMode(_darkMode).catchError((e) {
        log(e.toString());
      }
    );
    notifyListeners();
  }
}