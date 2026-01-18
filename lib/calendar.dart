import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/share.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/user_info.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:throwtrash/viewModels/calendar_model.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:throwtrash/view_common/trash_color.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_link.dart';
import 'alarm.dart';
import 'edit.dart';
import 'list.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  Logger _logger = Logger();
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
    AccountLinkServiceInterface accountLinkService
      = Provider.of<AccountLinkServiceInterface>(context, listen: false);
    initUniLinks(accountLinkService);

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
                              title: Text("通知設定") ,
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
                          Consumer<ChangeThemeModel>(
                            builder: (context, changeThemeModel, child) =>
                              ListTile(
                                title: Row(
                                    children: [Switch(
                                      value: changeThemeModel.darkMode,
                                      onChanged: (value) {
                                        changeThemeModel.switchDarkMode();
                                      },
                                    )
                                    ]
                                ),
                                leading: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Icon(Icons.dark_mode)
                                ),
                              )
                            )
                        ]
                    ),
                  ),
                  Container(
                    child: Text(
                      "Version ${Provider.of<AppConfigProviderInterface>(context).version}",
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
