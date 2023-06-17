import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:throwtrash/firebase_options.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/repository/crashlytics_report.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:throwtrash/usecase/trash_repository_interface.dart';
import 'package:throwtrash/share.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/user_info.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:timezone/data/latest.dart' as tz;

late final UserServiceInterface _userService;
late final TrashDataServiceInterface _trashDataService;
late final TrashApiInterface _trashApi;
late final TrashRepositoryInterface _trashRepository;
late final ActivationApiInterface _activationApi;
late final AccountLinkServiceInterface _accountLinkService;
late final Config _config;

final _logger = Logger();

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

  await Config().initialize();

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
          ))
        ],
        child: MaterialApp(
          title: '今日のゴミ出し',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.pinkAccent)),
          home: ChangeNotifierProvider<CalendarModel>(
              create: (context) => CalendarModel(
                  CalendarService(),
                  Provider.of<TrashDataServiceInterface>(
                      context,
                      listen: false),
                  DateTime.now()
              ),
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
  final Map<String, Color> _trashColorMap = {
  "burn": Colors.red,
  "unburn": Colors.blue,
  "plastic": Colors.green,
  "bin": Colors.orange,
  "can": Colors.pink,
  "petbottle": Colors.lightGreen,
  "paper": Colors.brown,
  "resource": Colors.teal,
  "coarse": Colors.deepOrangeAccent,
  "other": Colors.grey,
  };
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

    tz.initializeTimeZones();

    CalendarModel calendarModel =
    Provider.of<CalendarModel>(context, listen: false);
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

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Flexible _flexibleRowWeek(
      int week, List<int> dateList, List<List<DisplayTrashData>> trashList) {
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
                          : Theme.of(context).textTheme.bodyLarge!.color)),
                ),
                Wrap(runSpacing: 6.0, children: [
                  for (int i = 0; i < trashList[index].length; i++)
                    Container(
                        decoration: BoxDecoration(
                            color: _trashColorMap[trashList[index][i].trashType],
                            borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.topCenter,
                        child: Text(trashList[index][i].trashName,
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
                                      ? _sundayColor
                                      : (weekday == '土'
                                      ? _saturdayColor
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
            child: ListView(
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
                        calendar.reload();
                      });
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
                )
              ],
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
                        )),
                  ]
                  )),
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
