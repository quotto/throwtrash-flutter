import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/auto_import_dialog.dart';
import 'package:throwtrash/legal_pages.dart';
import 'package:throwtrash/share.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/user_info.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:throwtrash/viewModels/calendar_model.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/exclude_date_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:throwtrash/view_common/app_feedback.dart';
import 'package:throwtrash/view_common/trash_color.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_link.dart';
import 'alarm.dart';
import 'edit.dart';
import 'exclude_date.dart';
import 'list.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final Logger _logger = Logger();
  final _rollbackSnackBar = AppFeedbackSnackBar.warning(
    '他の端末でスケジュールが更新されました。',
    duration: Duration(seconds: 1),
  );
  final _failedSnackBar = AppFeedbackSnackBar.error(
    'データの更新に失敗しました。',
    duration: Duration(seconds: 1),
  );

  final List<String> _weekdayLabel = ['日', '月', '火', '水', '木', '金', '土'];

  PageController controller = PageController(initialPage: 0);
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Widget _identified(String id, Widget child) {
    return Semantics(identifier: id, child: child);
  }

  Future<void> initUniLinks(AccountLinkServiceInterface service) async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      _logger.d("start via App Links: $initialLink");
    } on PlatformException {
      _logger.e("failed start via App Links");
    }
    _sub = _appLinks.uriLinkStream.listen(
      (Uri link) {
        _logger.d("change link stream: $link");
        String? code = link.queryParameters["code"];
        String? state = link.queryParameters["state"];
        if (code != null && state != null) {
          AccountLinkModel accountLinkModel = AccountLinkModel(service);
          accountLinkModel.prepareAccountLinkInfo(code).then((_) {
            if (!mounted) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<AccountLinkModel>(
                  create: (context) => accountLinkModel,
                  child: AccountLink(),
                ),
              ),
            );
          });
        } else {
          _logger.e("receive url is invalid");
        }
      },
      onError: (err) {
        _logger.e("failed listen link stream: ${err.toString()}");
      },
    );
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
    AccountLinkServiceInterface accountLinkService =
        Provider.of<AccountLinkServiceInterface>(context, listen: false);
    initUniLinks(accountLinkService);

    CalendarModel calendarModel = Provider.of<CalendarModel>(
      context,
      listen: false,
    );
    calendarModel.addListener(() async {
      if (!calendarModel.isLoading()) {
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
      final trashDataService = Provider.of<TrashDataServiceInterface>(
        context,
        listen: false,
      );
      trashDataService.shouldShowInitialSearchDialog().then((shouldShow) {
        if (shouldShow && mounted) {
          showAutoImportDialog(context, updateInitialDisplayStatus: true);
        }
      });
    });
  }

  List<String> _trashTypes(List<List<DisplayTrashData>> trashList) {
    return trashList
        .expand((trashListByDate) => trashListByDate)
        .map((trash) => trash.trashType)
        .toSet()
        .toList();
  }

  Widget _trashTypeMarker(String trashType) {
    return SizedBox(
      width: 1,
      height: 1,
      child: Semantics(
        container: true,
        identifier: 'calendar-trash-$trashType',
        label: 'calendar-trash-$trashType',
      ),
    );
  }

  DateTime _calendarCellDate(int year, int month, int week, int date) {
    if (week == 1 && date > 7) {
      return DateTime(year, month - 1, date);
    }
    if (week == 5 && date <= 7) {
      return DateTime(year, month + 1, date);
    }
    return DateTime(year, month, date);
  }

  String _formatDialogDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}年$month月$day日';
  }

  void _showTrashDialog(DateTime date, List<DisplayTrashData> trashList) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: Key('calendar-day-dialog'),
          title: Text(_formatDialogDate(date)),
          content: trashList.isEmpty
              ? Text('出せるゴミはありません')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final trash in trashList)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(trash.trashName),
                        ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              key: Key('calendar-day-dialog-close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _trashLabel(DisplayTrashData trash) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: trashColor(trash.trashType, Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.topCenter,
      child: Text(
        trash.trashName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: 8),
      ),
    );
  }

  Widget _overflowLabel(int hiddenCount) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        '...+$hiddenCount',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _calendarDayCell({
    required int pageIndex,
    required int cellIndex,
    required int year,
    required int month,
    required int week,
    required int weekdayIndex,
    required int date,
    required List<DisplayTrashData> trashList,
  }) {
    final opacity = week == 1 && date > 7 || week == 5 && date <= 7 ? 0.5 : 1.0;
    final displayTrashList = trashList.take(3).toList();
    final hiddenCount = trashList.length - displayTrashList.length;
    final cellDate = _calendarCellDate(year, month, week, date);
    final textColor = weekdayIndex == 0
        ? Colors.red.shade600.withValues(alpha: opacity)
        : (weekdayIndex == 6
              ? Colors.blue.shade600.withValues(alpha: opacity)
              : Theme.of(
                  context,
                ).textTheme.bodyLarge!.color?.withValues(alpha: opacity));

    return Expanded(
      child: InkWell(
        key: Key('calendar-day-$pageIndex-$cellIndex'),
        onTap: () {
          _showTrashDialog(cellDate, trashList);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            children: [
              Text(
                date.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final trash in displayTrashList)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _trashLabel(trash),
                    ),
                  if (hiddenCount > 0) _overflowLabel(hiddenCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Flexible _flexibleRowWeek(
    int year,
    int month,
    int pageIndex,
    int week,
    List<int> dateList,
    List<List<DisplayTrashData>> trashList,
  ) {
    List<Widget> calendarCellColumn = [];
    dateList.asMap().forEach((index, date) {
      calendarCellColumn.add(
        _calendarDayCell(
          pageIndex: pageIndex,
          cellIndex: ((week - 1) * 7) + index,
          year: year,
          month: month,
          week: week,
          weekdayIndex: index,
          date: date,
          trashList: trashList[index],
        ),
      );
    });
    return Flexible(
      flex: 3,
      child: FractionallySizedBox(
        heightFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            // topのborder以外は消す
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(children: calendarCellColumn),
          ),
        ),
      ),
    );
  }

  Column _calendarColumn(
    int year,
    int month,
    List<int> allDateList,
    List<List<DisplayTrashData>> allTrashList,
    int pageIndex,
  ) {
    Flexible week1 = _flexibleRowWeek(
      year,
      month,
      pageIndex,
      1,
      allDateList.sublist(0, 7),
      allTrashList.sublist(0, 7),
    );
    Flexible week2 = _flexibleRowWeek(
      year,
      month,
      pageIndex,
      2,
      allDateList.sublist(7, 14),
      allTrashList.sublist(7, 14),
    );
    Flexible week3 = _flexibleRowWeek(
      year,
      month,
      pageIndex,
      3,
      allDateList.sublist(14, 21),
      allTrashList.sublist(14, 21),
    );
    Flexible week4 = _flexibleRowWeek(
      year,
      month,
      pageIndex,
      4,
      allDateList.sublist(21, 28),
      allTrashList.sublist(21, 28),
    );
    Flexible week5 = _flexibleRowWeek(
      year,
      month,
      pageIndex,
      5,
      allDateList.sublist(28, 35),
      allTrashList.sublist(28, 35),
    );

    return Column(
      key: Key('calendar_column_$pageIndex'),
      children: [
        ..._trashTypes(allTrashList).map(_trashTypeMarker),
        Flexible(
          flex: 1,
          child: FractionallySizedBox(
            heightFactor: 1.0,
            child: Row(
              key: Key('weekday_label_$pageIndex'),
              children: _weekdayLabel.map<Widget>((weekday) {
                return Expanded(
                  child: Text(
                    weekday,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: weekday == '日'
                          ? Colors.red.shade600
                          : (weekday == '土'
                                ? Colors.blue.shade600
                                : Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        week1,
        week2,
        week3,
        week4,
        week5,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (context, calendar, child) {
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => _identified(
                'open-drawer',
                IconButton(
                  key: Key('open-drawer'),
                  tooltip: 'メニューを開く',
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
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
              children: [
                Expanded(
                  child: ListView(
                    // スクロールは無効化する
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      _identified(
                        'drawer-add',
                        ListTile(
                          key: Key('drawer-add'),
                          title: Text("追加"),
                          leading: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider<EditModel>(
                                      create: (context) => EditModel(
                                        Provider.of<TrashDataServiceInterface>(
                                          context,
                                          listen: false,
                                        ),
                                      ),
                                      child: EditItemMain(),
                                    ),
                              ),
                            ).then((result) {
                              if (result != null && result) {
                                calendar.reload();
                              }
                            });
                          },
                        ),
                      ),
                      _identified(
                        'drawer-edit',
                        ListTile(
                          key: Key('drawer-edit'),
                          title: Text("編集"),
                          leading: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.edit),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider<ListModel>(
                                      create: (context) => ListModel(
                                        Provider.of<TrashDataServiceInterface>(
                                          context,
                                          listen: false,
                                        ),
                                      ),
                                      child: TrashList(),
                                    ),
                              ),
                            ).then((result) {
                              // 編集・削除ではデータの更新有無が判別できないためリロード処理を強制実行する
                              calendar.reload();
                            });
                          },
                        ),
                      ),
                      _identified(
                        'drawer-global-exclude',
                        ListTile(
                          key: Key('drawer-global-exclude'),
                          title: Text("例外日"),
                          leading: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.event_busy),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            final trashDataService =
                                Provider.of<TrashDataServiceInterface>(
                                  context,
                                  listen: false,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider<ExcludeViewModel>(
                                      create: (context) =>
                                          ExcludeViewModel.load(
                                            trashDataService.globalExcludeDates,
                                          ),
                                      child: ExcludeDateView(
                                        showGlobalDescription: true,
                                      ),
                                    ),
                              ),
                            ).then((result) async {
                              if (result != null) {
                                final viewModel = result as ExcludeViewModel;
                                final newExcludeDates = viewModel.excludeDates
                                    .map((value) {
                                      return ExcludeDate(value[0], value[1]);
                                    })
                                    .toList();
                                final updateResult = await trashDataService
                                    .updateGlobalExcludeDates(newExcludeDates);
                                if (updateResult) {
                                  calendar.reload();
                                }
                              }
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text("通知設定"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.alarm),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlarmPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text("スケジュールの共有"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.share),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Share()),
                          ).then((activationResult) {
                            if (activationResult != null && activationResult) {
                              calendar.reload();
                            }
                          });
                        },
                      ),
                      ListTile(
                        title: Text("アレクサ連携"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.speaker),
                        ),
                        onTap: () async {
                          AccountLinkModel accountLinkModel = AccountLinkModel(
                            Provider.of<AccountLinkServiceInterface>(
                              context,
                              listen: false,
                            ),
                          );
                          accountLinkModel.addListener(() {
                            if (accountLinkModel.accountLinkType ==
                                AccountLinkType.iOS) {
                              launchUrl(
                                Uri.parse(
                                  accountLinkModel.accountLinkInfo.linkUrl,
                                ),
                                mode: LaunchMode.externalNonBrowserApplication,
                              ).then((value) {
                                if (!value) {
                                  _logger.w(
                                    "アレクサアプリがインストールされていません, ブラウザでアカウントリンクを開始します",
                                  );
                                  accountLinkModel.startLinkAsWeb();
                                }
                              });
                            } else {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider<AccountLinkModel>(
                                        create: (context) => accountLinkModel,
                                        child: AccountLink(),
                                      ),
                                ),
                              );
                            }
                          });
                          accountLinkModel.startLinkAsIOS();
                        },
                      ),
                      ListTile(
                        title: Text("ユーザー情報"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.person),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserInfo()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text("その他"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.more_horiz),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherPage(
                                applicationVersion:
                                    Provider.of<AppConfigProviderInterface>(
                                      context,
                                      listen: false,
                                    ).version,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text("問い合わせ"),
                        leading: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(Icons.mail),
                        ),
                        onTap: () {
                          Uri askFormUri = Uri.parse(
                            "https://docs.google.com/forms/d/e/1FAIpQLScQiZNzcYKgto1mQYAmxmo49RTuAnvtmkk3BQ02MsVlE4OmHg/viewform",
                          );
                          launchUrl(askFormUri);
                        },
                      ),
                      Divider(indent: 20, endIndent: 20),
                      Consumer<ChangeThemeModel>(
                        builder: (context, changeThemeModel, child) => ListTile(
                          title: Row(
                            children: [
                              Switch(
                                value: changeThemeModel.darkMode,
                                onChanged: (value) {
                                  changeThemeModel.switchDarkMode();
                                },
                              ),
                            ],
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(Icons.dark_mode),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Version ${Provider.of<AppConfigProviderInterface>(context).version}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  calendar.reload();
                },
                child: Column(
                  children: [
                    Flexible(
                      flex: 5,
                      child: PageView(
                        controller: controller,
                        children: List<Column>.generate(
                          calendar.calendarsDateList.length,
                          (index) {
                            final pageDate = DateTime(
                              calendar.year,
                              calendar.month + index - calendar.currentPage,
                            );
                            return _calendarColumn(
                              pageDate.year,
                              pageDate.month,
                              calendar.calendarsDateList[index],
                              calendar.calendarsTrashList[index],
                              index,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              if (calendar.isLoading()) loadingContainer,
            ],
          ),
        );
      },
    );
  }

  Widget loadingContainer = Stack(
    children: [
      Container(color: Colors.black.withValues(alpha: 0.5)),
      Center(child: CircularProgressIndicator()),
    ],
  );
}
