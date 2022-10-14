import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:throwtrash/firebase_options.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/repository/activation_api_interface.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:throwtrash/share.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/user_info.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/alarm.dart';
import 'package:throwtrash/edit.dart';
import 'package:throwtrash/list.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/repository/account_link_api.dart';
import 'package:throwtrash/repository/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/repository/account_link_repository_interface.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/account_link_service.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/alarm_service.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/usecase/calendar_usecase.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';
import 'package:throwtrash/repository/alarm_repository_interface.dart';
import 'package:throwtrash/repository/alarm_repository.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:throwtrash/viewModels/alarm_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'package:throwtrash/repository/config_interface.dart';
import 'package:throwtrash/repository/config.dart';
import 'package:throwtrash/repository/trash_api_interface.dart';

import 'viewModels/calendar_model.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

late final UserServiceInterface _userService;
late final TrashDataServiceInterface _trashDataService;
late final TrashApiInterface _trashApi;
late final TrashRepositoryInterface _trashRepository;
late final ActivationApiInterface _activationApi;
late final AlarmRepositoryInterface _alarmRepository;
late final AccountLinkServiceInterface _accountLinkService;
late final Config _config;

final _logger = Logger();

@pragma('vm:entry-point')
void executeWorkManager()  {
  Workmanager().executeTask((taskName, inputData) async {
    await Config().initialize();
    TrashDataServiceInterface trashDataService = TrashDataService(
      UserService(
        UserRepository(),
      ),
      TrashRepository(),
      TrashApi(Config().mobileApiEndpoint),
    );
    AlarmServiceInterface alarmService = AlarmService(
        UserService(
          UserRepository(),
        ),
        AlarmRepository(),
        trashDataService
    );

    await trashDataService.refreshTrashData();

    _logger.d("exec work manager task $taskName");
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    DateTime today = DateTime.now();

    List<TrashData> matchTrash = trashDataService.getTrashOfToday(year: today.year, month: today.month, date: today.day);
    String message = alarmService.createAlarmMessage(matchTrash);

    await _flutterLocalNotificationsPlugin.show(
        0,
        "今日出せるゴミ",
        message,
        platformChannelSpecifics);

    alarmService.reserveNextAlarm();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await Config().initialize();

  _userService = UserService(
      UserRepository()
  );
  await _userService.refreshUser();

  _trashApi = TrashApi(Config().mobileApiEndpoint);
  _trashDataService =
      TrashDataService(
          _userService,
          TrashRepository(),
          _trashApi
      );
  _alarmRepository = AlarmRepository();
  _config = Config();
  _accountLinkService = AccountLinkService(
      _config,
      AccountLinkApi(_config.mobileApiEndpoint),
      AccountLinkRepository(),
      UserRepository()
  );

  _trashRepository = TrashRepository();
  _activationApi = ActivationApi(_config);

  Workmanager().initialize(
      executeWorkManager,
      isInDebugMode: true);
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
          Provider<AlarmRepositoryInterface>(
              create: (context) => _alarmRepository),
          Provider<AlarmServiceInterface>(
            create: (context) => AlarmService(
                _userService,
                _alarmRepository,
                _trashDataService
            ),
          ),
          Provider<ConfigInterface>(
              create: (context)=> _config
          ),
          Provider<TrashApiInterface>(
              create: (context)=> _trashApi
          ),
          Provider<AccountLinkApiInterface>(
              create: (context)=> AccountLinkApi(_config.mobileApiEndpoint)
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
              _trashDataService
          ))
        ],
        child: MaterialApp(
          // Application name
          title: 'Flutter Hello World',
          // Application theme data, you can set the colors for the application as
          // you want
          theme: ThemeData(
              primarySwatch: Colors.blue, accentColor: Colors.pinkAccent),
          // A widget which will be started on application startup
          home: ChangeNotifierProvider<CalendarModel>(
              create: (context) => CalendarModel(
                  CalendarUseCase(),
                  Provider.of<TrashDataServiceInterface>(context,
                      listen: false)),
              child: CalendarWidget()),
        ));
  }

}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final Color _sundayColor = Colors.redAccent;
  final Color _saturdayColor = Colors.blue;
  final Color _notThisMonthColor = Colors.grey[300]!;
  final List<String> _weekdayLabel = ['日', '月', '火', '水', '木', '金', '土'];
  PageController controller = PageController(initialPage: 0);
  late StreamSubscription _sub;

  Future<void> initUniLinks(AccountLinkServiceInterface service) async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      _logger.d("start via App Links: $initialLink");
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      _logger.e("failed start via App Links");
    }
    _sub = uriLinkStream.listen((Uri? link) {
      // Parse the link and warn the user, if it is not correct
      _logger.d("change link stream: $link");
      String? code = link?.queryParameters["code"];
      String? state = link?.queryParameters["state"];
      if(code != null && state != null) {
        service.enableSkill(code, state);
      } else {
        _logger.e("receive url is invalid");
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      _logger.e("failed listen link stream: ${err.toString()}");
    });
  }

  @override
  void dispose() {
    _logger.i("calendar dispose");
    _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initUniLinks(_accountLinkService);

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          print('onDidReceiveLocalNotifications');
        });
    const MacOSInitializationSettings macOSInitializationSettings =
    MacOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
        macOS: macOSInitializationSettings);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          print('Notification was selected: $payload');
        }
      },
    );

    CalendarModel calendarModel =
    Provider.of<CalendarModel>(context, listen: false);
    controller.addListener(() {
      if (controller.page == controller.page!.toInt()) {
        if (controller.page! > calendarModel.currentPage) {
          print('forward: ${controller.page!}');
          calendarModel.forward();
          controller.jumpToPage(calendarModel.currentPage);
        } else if (controller.page! < calendarModel.currentPage) {
          print('backward: ${controller.page!}');
          calendarModel.backward();
          controller.jumpToPage(calendarModel.currentPage);
        }
      }
    });
    super.initState();
  }

  Flexible _flexibleRowWeek(
      int week, List<int> dateList, List<List<String>> trashList) {
    List<Widget> calendarCellColumn = [];
    dateList.asMap().forEach((index, date) {
      calendarCellColumn.add(Expanded(
          child: DecoratedBox(
              decoration: BoxDecoration(
                  color: (week == 1 && date > 7 || week == 5 && date <= 7)
                      ? _notThisMonthColor
                      : Theme.of(context).canvasColor,
                  border: (week == 1 && date > 7 || week == 5 && date <= 7)
                      ? Border.all(color: _notThisMonthColor)
                      : Border.all(color: Theme.of(context).canvasColor)),
              child: Column(children: [
                Text(
                  date.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: index == 0
                          ? _sundayColor
                          : (index == 6
                          ? _saturdayColor
                          : Theme.of(context).textTheme.bodyText1!.color)),
                ),
                Wrap(runSpacing: 6.0, children: [
                  for (int i = 0; i < trashList[index].length; i++)
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.topCenter,
                        child: Text(trashList[index][i],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            )))
                ])
              ]))));
    });
    return Flexible(
      flex: 3,
      child: FractionallySizedBox(
          heightFactor: 1.0,
          child: Container(
              decoration:
              BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(children: calendarCellColumn)))),
    );
  }

  Column _calendarColumn(
      List<int> allDateList, List<List<String>> allTrashList) {
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

    return Column(children: [
      Flexible(
          flex: 1,
          child: FractionallySizedBox(
            heightFactor: 1.0,
            child: Row(
                children: _weekdayLabel.map<Widget>((weekday) {
                  return Expanded(
                      child: Text(weekday,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: weekday == '日'
                                  ? _sundayColor
                                  : (weekday == '土'
                                  ? _saturdayColor
                                  : Theme.of(context)
                                  .textTheme
                                  .bodyText1!
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
      if (calendar.calendarsTrashList.length == 0) {
        return Scaffold(body: Container(child: Text('')));
      }
      return Scaffold(
          appBar: AppBar(
            title: Text('${calendar.year}年${calendar.month}月'),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                    title: Text("追加"),
                    leading: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Icon(Icons.add)),
                    onTap: () {
                      throw new Error();
                      // Navigator.of(context).pop();
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             ChangeNotifierProvider<EditModel>(
                      //                 create: (context) => EditModel(
                      //                   Provider.of<
                      //                       TrashDataServiceInterface>(
                      //                       context,
                      //                       listen: false),
                      //                 ),
                      //                 child: EditItemMain()))).then((result) {
                      //   if (result != null && result) {
                      //     calendar.reload();
                      //   }
                      // });
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
                                  child: TrashList()))).then((result) {
                        calendar.reload();
                      });
                    }),
                ListTile(
                    title: Text("通知"),
                    leading: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Icon(Icons.alarm)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChangeNotifierProvider<AlarmModel>(
                                      create: (context) => AlarmModel(
                                          Provider.of<AlarmRepositoryInterface>(
                                              context,
                                              listen: false),
                                          Provider.of<AlarmServiceInterface>(
                                              context,
                                              listen: false)),
                                      child: AlarmView())));
                    }),
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
                      );
                    }),
                ListTile(
                    title: Text("アレクサ連携"),
                    leading: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Icon(Icons.speaker)),
                    onTap: () async {
                      ConfigInterface config =  Provider.of<ConfigInterface>(context,listen: false);
                      AccountLinkRepositoryInterface repo = AccountLinkRepository();
                      AccountLinkApiInterface api = AccountLinkApi(config.mobileApiEndpoint);
                      UserRepositoryInterface userRepo = UserRepository();
                      AccountLinkServiceInterface _accountLinkService = AccountLinkService(config,api,repo,userRepo);
                      AccountLinkInfo info = await _accountLinkService.startLink();
                      launchUrl(Uri.parse(info.linkUrl),mode: LaunchMode.externalApplication);
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
                )
              ],
            ),
          ),
          body: Column(children: [
            Flexible(
                flex: 5,
                child: PageView(
                  controller: controller,
                  children: new List<Column>.generate(
                      calendar.calendarsDateList.length, (index) {
                    return _calendarColumn(calendar.calendarsDateList[index],
                        calendar.calendarsTrashList[index]);
                  }).toList(),
                )),
          ]));
    });
  }
}
