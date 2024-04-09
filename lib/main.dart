import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/firebase_options.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/repository/alarm_api.dart';
import 'package:throwtrash/repository/alarm_repository.dart';
import 'package:throwtrash/repository/config_repository.dart';
import 'package:throwtrash/repository/crashlytics_report.dart';
import 'package:throwtrash/repository/environment_provider.dart';
import 'package:throwtrash/repository/fcm_service.dart';
import 'package:throwtrash/usecase/alarm_service.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/usecase/change_theme_service.dart';
import 'package:throwtrash/usecase/change_theme_service_interface.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';
import 'package:throwtrash/repository/account_link_api.dart';
import 'package:throwtrash/usecase/repository/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/usecase/repository/account_link_repository_interface.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/account_link_service.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/calendar_service.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/repository/app_config_provider.dart';
import 'package:http/http.dart' as http;

import 'calendar.dart';
import 'viewModels/calendar_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _initializeRepository() async {
  await EnvironmentProvider.initialize();
  await AppConfigProvider().initialize(EnvironmentProvider());
  TrashRepository.initialize(await SharedPreferences.getInstance());
  UserRepository.initialize(await SharedPreferences.getInstance());
  AccountLinkRepository.initialize(await SharedPreferences.getInstance());
  ActivationApi.initialize(AppConfigProvider(), http.Client());
  AccountLinkApi.initialize(AppConfigProvider(), http.Client());
  AlarmRepository.initialize(await SharedPreferences.getInstance());
  AlarmApi.initialize(AppConfigProvider(), EnvironmentProvider(), http.Client());
  TrashApi.initialize(AppConfigProvider(), http.Client());
  ConfigRepository.initialize(await SharedPreferences.getInstance());
  FcmService.initialize(FirebaseMessaging.instance, ConfigRepository(), navigatorKey);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await _initializeRepository();

  UserServiceInterface userService = UserService(
      UserRepository()
  );
  await userService.refreshUser();

  TrashDataServiceInterface trashDataService =
  TrashDataService(
      userService,
      TrashRepository(),
      TrashApi(),
      CrashlyticsReport()
  );
  AccountLinkServiceInterface accountLinkService = AccountLinkService(
      AppConfigProvider(),
      AccountLinkApi(),
      AccountLinkRepository(),
      UserRepository(),
      CrashlyticsReport()
  );

  AlarmServiceInterface alarmService = AlarmService(
      AlarmRepository(),
      AlarmApi(),
      ConfigRepository(),
      FcmService(),
      UserRepository()
  );


  ChangeThemeModel changeThemeModel = ChangeThemeModel(ChangeThemeService(ConfigRepository()));
  await changeThemeModel.init();

  runApp(
      MultiProvider(
          providers: [
            Provider<TrashDataServiceInterface>(
              create: (context) => trashDataService,
            ),
            Provider<AppConfigProviderInterface>(
                create: (context)=> AppConfigProvider()
            ),
            Provider<AccountLinkApiInterface>(
                create: (context)=> AccountLinkApi()
            ),
            Provider<AccountLinkRepositoryInterface>(
              create: (context)=> AccountLinkRepository(),
            ) ,
            Provider<UserServiceInterface>(create: (context)=>userService),
            Provider<UserRepositoryInterface>(
              create: (context)=> UserRepository(),
            ),
            Provider<ChangeThemeServiceInterface>(
                create: (context)=> ChangeThemeService(ConfigRepository())
            ),
            Provider<AccountLinkServiceInterface>(
                create: (context)=> accountLinkService
            ),
            Provider<ShareServiceInterface>(create: (context) => ShareService(
                ActivationApi(),
                userService,
                TrashRepository(),
                CrashlyticsReport()
            )),
            Provider<AlarmServiceInterface>(
                create: (context) => alarmService
            ),
            ChangeNotifierProvider<ChangeThemeModel>(
                create: (context)=> changeThemeModel
            )],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarModel>(
        create: (context) => CalendarModel(
            CalendarService(),
            Provider.of<TrashDataServiceInterface>(
                context,
                listen: false),
            DateTime.now()
        ),
        child: Consumer<ChangeThemeModel>(
            builder: (context, changeThemeModel, child) =>
                MaterialApp (
                  theme: ThemeData(
                    brightness: changeThemeModel.darkMode ? Brightness.dark : Brightness.light,
                    colorSchemeSeed: Colors.blue,
                  ),
                  home: CalendarWidget(),
                  // フォアグラウンドでプッシュ通知を受けた際にトップ画面に戻る。
                  // この実装にはトップレベルメソッドでBuildContextを取得する必要があるため,グローバル宣言したNavigatorStateを渡す
                  navigatorKey: navigatorKey,
                )
        )
    );
  }
}