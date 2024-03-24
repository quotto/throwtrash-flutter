import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/firebase_options.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/repository/alarm_api.dart';
import 'package:throwtrash/repository/alarm_repository.dart';
import 'package:throwtrash/repository/config_repository.dart';
import 'package:throwtrash/repository/crashlytics_report.dart';
import 'package:throwtrash/repository/environment_provider.dart';
import 'package:throwtrash/repository/fcm_service.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:throwtrash/usecase/alarm_service.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/usecase/change_theme_service.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_repository_interface.dart';
import 'package:throwtrash/share.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/user_info.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:throwtrash/alarm.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';
import 'package:throwtrash/view_common/trash_color.dart';
import 'package:uni_links/uni_links.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/edit.dart';
import 'package:throwtrash/list.dart';
import 'package:throwtrash/repository/account_link_api.dart';
import 'package:throwtrash/usecase/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/usecase/account_link_repository_interface.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/user_repository_interface.dart';
import 'package:throwtrash/usecase/account_link_service.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/calendar_service.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:throwtrash/usecase/config_interface.dart';
import 'package:throwtrash/repository/config.dart';
import 'package:throwtrash/usecase/trash_api_interface.dart';
import 'package:http/http.dart' as http;

import 'account_link.dart';
import 'viewModels/calendar_model.dart';

late final UserServiceInterface _userService;
late final TrashDataServiceInterface _trashDataService;
late final TrashApiInterface _trashApi;
late final TrashRepositoryInterface _trashRepository;
late final ActivationApiInterface _activationApi;
late final AccountLinkServiceInterface _accountLinkService;
late final AlarmServiceInterface _alarmService;
late final ChangeThemeModel _changeThemeModel;
late final Config _config;

final _logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  Navigator.popUntil(
    navigatorKey.currentContext!,
    (route) => route.isFirst,
  );
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  _logger.d('showForegroundNotification: ${message.notification}');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: initializationSettingsDarwin
  );

  const DarwinNotificationDetails notificationDetailsDarwin = DarwinNotificationDetails();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  const NotificationDetails notificationDetails =
  NotificationDetails(iOS: notificationDetailsDarwin);
  await flutterLocalNotificationsPlugin.show(
      0, message.notification?.title, message.notification?.body, notificationDetails,
      payload: 'item x');
}

Future<void> initializeService({
  required UserRepositoryInterface userRepository,
  required AccountLinkRepositoryInterface accountLinkRepository,
  required TrashRepositoryInterface trashRepository,
  required TrashApiInterface trashApi,
  required ActivationApiInterface activationApi,
  required AccountLinkApiInterface accountLinkApi,
}) async {
  _userService = UserService(
    userRepository,
  );
  await _userService.refreshUser();

  _trashDataService =
      TrashDataService(
          _userService,
          trashRepository,
          trashApi,
          CrashlyticsReport()
      );
  _config = Config();
  _accountLinkService = AccountLinkService(
      _config,
      accountLinkApi,
      accountLinkRepository,
      userRepository,
      CrashlyticsReport()
  );

  _alarmService = AlarmService(
      AlarmRepository(await SharedPreferences.getInstance()),
      AlarmApi(_config.alarmApiUrl, http.Client()),
      ConfigRepository(),
      FcmService(FirebaseMessaging.instance, ConfigRepository()),
      UserRepository()
  );

  _changeThemeModel = ChangeThemeModel(ChangeThemeService(ConfigRepository()));
  await _changeThemeModel.init();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  _logger.i('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _logger.i('Got a message whilst in the foreground!');

    if (message.notification != null) {
      _logger.i('Message also contained a notification: ${message.notification.toString()}');
    }
    _showForegroundNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _logger.i('A new onMessageOpenedApp event was published!');
    Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);
  });

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final environmentProvider = EnvironmentProvider();
  await environmentProvider.initialize();
  await Config().initialize(environmentProvider);

  _trashApi = TrashApi(Config().mobileApiEndpoint, http.Client());
  _activationApi = ActivationApi(Config(), http.Client());
  _trashRepository = TrashRepository();

  await initializeService(
      userRepository: UserRepository(),
      accountLinkRepository: AccountLinkRepository(),
      trashRepository: _trashRepository,
      trashApi: _trashApi,
      activationApi: _activationApi,
      accountLinkApi: AccountLinkApi(Config().mobileApiEndpoint, http.Client())
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<TrashDataServiceInterface>(
            create: (context) => _trashDataService,
          ),
          Provider<ConfigInterface>(
              create: (context)=> _config
          ),
          Provider<TrashApiInterface>(
              create: (context)=> _trashApi
          ),
          Provider<AccountLinkApiInterface>(
              create: (context)=> AccountLinkApi(_config.mobileApiEndpoint, http.Client())
          ),
          Provider<AccountLinkRepositoryInterface>(
            create: (context)=> AccountLinkRepository(),
          ) ,
          Provider<UserServiceInterface>(create: (context)=>_userService),
          Provider<UserRepositoryInterface>(
            create: (context)=> UserRepository(),
          ),
          Provider<AccountLinkServiceInterface>(
              create: (context)=> _accountLinkService
          ),
          Provider<ShareServiceInterface>(create: (context) => ShareService(
              _activationApi,
              _userService,
              _trashRepository,
              CrashlyticsReport()
          )),
          Provider<AlarmServiceInterface>(
              create: (context) => _alarmService
          ),
          ChangeNotifierProvider<ChangeThemeModel>(
              create: (context)=> _changeThemeModel
          )
        ],
        child: ChangeNotifierProvider<CalendarModel>(
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
                          brightness: _changeThemeModel.darkMode ? Brightness.dark : Brightness.light,
                          colorSchemeSeed: Colors.blue,
                        ),
                        home: CalendarWidget(),
                        // フォアグラウンドでプッシュ通知を受けた際にトップ画面に戻る。
                        // この実装にはトップレベルメソッドでBuildContextを取得する必要があるため,グローバル宣言したNavigatorStateを渡す
                        navigatorKey: navigatorKey,
                    )
            )
        )
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final _rollbackSnackBar = SnackBar(
    backgroundColor: Colors.amber,
    content: Text('他の端末でスケジュールが更新されました。', style: TextStyle(color: Colors.white)),
    duration: Duration(
        seconds: 1
    ),
  );
  final _failedSnackBar = SnackBar(
    backgroundColor: Colors.pink,
    content: Text('データの更新に失敗しました。', style: TextStyle(color: Colors.white)),
    duration: Duration(
        seconds: 1
    ),
  );

  final List<String> _weekdayLabel = ['日', '月', '火', '水', '木', '金', '土'];

  PageController controller = PageController(initialPage: 0);
  StreamSubscription? _sub;

  Future<void> initUniLinks(AccountLinkServiceInterface service) async {
    try {
      final initialLink = await getInitialLink();
      _logger.d("start via App Links: $initialLink");
    } on PlatformException {
      _logger.e("failed start via App Links");
    }
    _sub = uriLinkStream.listen((Uri? link) {
      _logger.d("change link stream: $link");
      String? code = link?.queryParameters["code"];
      String? state = link?.queryParameters["state"];
      if(code != null && state != null) {
        AccountLinkModel accountLinkModel = AccountLinkModel(service);
        accountLinkModel.prepareAccountLinkInfo(code).then((_) {
          Navigator.push(context,MaterialPageRoute(builder: (context)=>
              ChangeNotifierProvider<AccountLinkModel>(
                  create: (context)=>accountLinkModel,
                  child: AccountLink()
              )
          ));
        });
      } else {
        _logger.e("receive url is invalid");
      }
    }, onError: (err) {
      _logger.e("failed listen link stream: ${err.toString()}");
    });
  }

  @override
  void dispose() {
    _logger.i("calendar dispose");
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initUniLinks(_accountLinkService);

    CalendarModel calendarModel =
    Provider.of<CalendarModel>(context, listen: false);
    calendarModel.addListener(() async {
      if(!calendarModel.isLoading()) {
        if (calendarModel.syncResult == SyncResult.failed) {
          ScaffoldMessenger.of(context).showSnackBar(_failedSnackBar);
          await Future.delayed(Duration(milliseconds: 1000));
        } else if (calendarModel.syncResult == SyncResult.rollback) {
          ScaffoldMessenger.of(context).showSnackBar(_rollbackSnackBar);
          await Future.delayed(Duration(milliseconds: 1000));
        }
      }
    });
    controller.addListener(() {
      if (controller.page == controller.page!.toInt()) {
        if (controller.page! > calendarModel.currentPage) {
          calendarModel.forward();
          controller.jumpToPage(calendarModel.currentPage);
        } else if (controller.page! < calendarModel.currentPage) {
          calendarModel.backward();
          controller.jumpToPage(calendarModel.currentPage);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      calendarModel.reload();
    });
  }

  Flexible _flexibleRowWeek(
      int week, List<int> dateList, List<List<DisplayTrashData>> trashList) {
    List<Widget> calendarCellColumn = [];
    dateList.asMap().forEach((index, date) {
      double opacity = week == 1 && date > 7 || week == 5 && date <= 7 ? 0.5 : 1.0;
      calendarCellColumn.add(Expanded(
          child: Column(children: [
            Text(
              date.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: index == 0
                      ? Colors.red.shade600.withOpacity(opacity)
                      : (index == 6
                      ? Colors.blue.shade600.withOpacity(opacity)
                      : Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(opacity))),
            ),
            Wrap(runSpacing: 6.0, children: [
              for (int i = 0; i < trashList[index].length; i++)
                Container(
                    decoration: BoxDecoration(
                        color: trashColor(trashList[index][i].trashType, Theme.of(context).brightness),//_trashColorMap[trashList[index][i].trashType],
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.topCenter,
                    child: Text(trashList[index][i].trashName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        )))
            ])
          ]))
        // )
      );
    });
    return Flexible(
      flex: 3,
      child: FractionallySizedBox(
          heightFactor: 1.0,
          child: Container(
              decoration:
              BoxDecoration(
                // topのborder以外は消す
                  border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none
                  )
              ),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(children: calendarCellColumn)))),
    );
  }

  Column _calendarColumn(
      List<int> allDateList, List<List<DisplayTrashData>> allTrashList, int pageIndex) {
    Flexible week1 = _flexibleRowWeek(
        1, allDateList.sublist(0, 7), allTrashList.sublist(0, 7));
    Flexible week2 = _flexibleRowWeek(
        2, allDateList.sublist(7, 14), allTrashList.sublist(7, 14));
    Flexible week3 = _flexibleRowWeek(
        3, allDateList.sublist(14, 21), allTrashList.sublist(14, 21));
    Flexible week4 = _flexibleRowWeek(
        4, allDateList.sublist(21, 28), allTrashList.sublist(21, 28));
    Flexible week5 = _flexibleRowWeek(
        5, allDateList.sublist(28, 35), allTrashList.sublist(28, 35));

    return Column(
        key: Key('calendar_column_$pageIndex'),
        children: [
          Flexible(
              flex: 1,
              child: FractionallySizedBox(
                heightFactor: 1.0,
                child: Row(
                    key: Key('weekday_label_$pageIndex'),
                    children: _weekdayLabel.map<Widget>((weekday) {
                      return Expanded(
                          child: Text(weekday,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: weekday == '日'
                                      ? Colors.red.shade600
                                      : (weekday == '土'
                                      ? Colors.blue.shade600
                                      : Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color))));
                    }).toList()),
              )),
          week1,
          week2,
          week3,
          week4,
          week5
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(builder: (context, calendar, child) {
      return Scaffold(
          appBar: AppBar(
            title: Text('${calendar.year}年${calendar.month}月'),
            // リロードボタン
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  calendar.reload();
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: Column(
                children:[
                  Expanded(
                    child:
                    ListView(
                      // スクロールは無効化する
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          ListTile(
                              title: Text("追加"),
                              leading: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(Icons.add)),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeNotifierProvider<EditModel>(
                                                create: (context) => EditModel(
                                                  Provider.of<
                                                      TrashDataServiceInterface>(
                                                      context,
                                                      listen: false),
                                                ),
                                                child: EditItemMain()))
                                ).then((result) {
                                  if (result != null && result) {
                                    calendar.reload();
                                  }
                                });
                              }
                          ),
                          ListTile(
                              title: Text("編集"),
                              leading: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(Icons.edit)),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChangeNotifierProvider<
                                            ListModel>(
                                            create: (context) => ListModel(
                                                Provider.of<TrashDataServiceInterface>(
                                                    context,
                                                    listen: false)),
                                            child: TrashList()))
                                ).then((result) {
                                  // 編集・削除ではデータの更新有無が判別できないためリロード処理を強制実行する
                                  calendar.reload();
                                });
                              }),
                          ListTile(
                            title: Text("アラーム設定") ,
                            leading: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.alarm)),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AlarmPage()
                                  )
                              );
                            }
                          ),

                          ListTile(
                              title: Text("スケジュールの共有"),
                              leading: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(Icons.share)),
                              onTap: () async {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context)=>
                                            Share())
                                ).then((activationResult) {
                                  if(activationResult != null && activationResult) {
                                    calendar.reload();
                                  }
                                });
                              }),
                          ListTile(
                              title: Text("アレクサ連携"),
                              leading: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(Icons.speaker)),
                              onTap: () async {
                                AccountLinkModel accountLinkModel = AccountLinkModel(
                                    Provider.of<AccountLinkServiceInterface>(context, listen: false)
                                );
                                accountLinkModel.addListener(() {
                                  if(accountLinkModel.accountLinkType == AccountLinkType.iOS) {
                                    launchUrl(
                                        Uri.parse(accountLinkModel.accountLinkInfo.linkUrl),
                                        mode: LaunchMode.externalNonBrowserApplication
                                    ).then((value) {
                                      if(!value) {
                                        _logger.w("アレクサアプリがインストールされていません, ブラウザでアカウントリンクを開始します");
                                        accountLinkModel.startLinkAsWeb();
                                      }
                                    });
                                  } else {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            ChangeNotifierProvider<AccountLinkModel>(
                                                create: (context) =>
                                                accountLinkModel,
                                                child: AccountLink()
                                            )
                                        )
                                    );
                                  }
                                });
                                accountLinkModel.startLinkAsIOS();
                              }),
                          ListTile(
                            title: Text("ユーザー情報"),
                            leading: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.person)),
                            onTap: (){
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context)  => UserInfo()
                                  )
                              );
                            },
                          ),
                          ListTile(
                            title: Text("ライセンス"),
                            leading: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.info)),
                            onTap: (){
                              showLicensePage(
                                  context: context,
                                  applicationVersion: "1.0",
                                  applicationName: "今日のゴミ出し",
                                  applicationIcon: Icon(Icons.account_circle_outlined)
                              );
                            },
                          ),
                          ListTile(
                            title: Text("問い合わせ"),
                            leading: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.mail)),
                            onTap: () {
                              Uri askFormUri = Uri.parse("https://docs.google.com/forms/d/e/1FAIpQLScQiZNzcYKgto1mQYAmxmo49RTuAnvtmkk3BQ02MsVlE4OmHg/viewform");
                              launchUrl(askFormUri);
                            },
                          ),
                          Divider(
                            indent: 20,
                            endIndent: 20,
                          ),
                          ListTile(
                            title: Row(
                                children: [Switch(
                                  value: _changeThemeModel.darkMode,
                                  onChanged: (value) {
                                    _changeThemeModel.switchDarkMode();
                                  },
                                )
                                ]
                            ),
                            leading: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.dark_mode)
                            ),
                          )
                        ]
                    ),
                  ),
                  Container(
                    child: Text(
                      "Version ${_config.version}",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ]
            ),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                  onRefresh: () async {calendar.reload();},
                  child: Column(children: [
                    Flexible(
                        flex: 5,
                        child: PageView(
                          controller: controller,
                          children: new List<Column>.generate(
                              calendar.calendarsDateList.length, (index) {
                            return _calendarColumn(calendar.calendarsDateList[index],
                                calendar.calendarsTrashList[index], index);
                          }).toList(),
                        )
                    ),
                  ]
                )
              ),
              if(calendar.isLoading())
                loadingContainer
            ],
          )
      );
    });
  }

  Widget loadingContainer = Stack(
    children: [
      Container(
        color: Colors.black.withOpacity(0.5),
      ),
      Center(
          child: CircularProgressIndicator()
      )
    ],
  );
}