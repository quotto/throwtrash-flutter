import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:throwtrash/main.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/usecase/account_link_service_interface.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/sync_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';

import 'widget_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TrashDataServiceInterface>(),
  MockSpec<ChangeThemeModel>(),
  MockSpec<AccountLinkServiceInterface>(),
  MockSpec<AppConfigProviderInterface>()
])
void main() {
  final trashDataService = MockTrashDataServiceInterface();
  final mockTrashNameMap = {
    "burn": "燃えるゴミ",
    "unburn": "燃えないゴミ",
    "other": "その他"
  };

  // アプリのmain関数で初期化される変数をテスト実行前に初期化する。
  setUpAll(() async{
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('dev.fluttercommunity.plus/package_info'), ((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{
          'appName': '今日のゴミ出し',
          'packageName': 'com.example.myapp',
          'version': '1.0.0',
          'buildNumber': '1'
        };
      }
      return null;
    }));
  });
  setUp(() async {
    when(trashDataService.syncTrashData()).thenAnswer((realInvocation) => Future.value(SyncResult.success));
    when(trashDataService.getTrashName(type: anyNamed("type"), trashVal: anyNamed("trashVal"))).thenAnswer(
            (realInvocation) {
              return mockTrashNameMap[realInvocation.namedArguments[Symbol("type")]!]!;
            }
    );
  });
  testWidgets('アプリ起動後のカレンダー画面の確認テスト', (WidgetTester tester) async {
    // モックの作成
    // 5 * 7 列のカレンダーを表示するため、5週間分のデータを返す
    final result = List<List<TrashData>>.generate(35, (index) => [], growable: false);
    result[0].add(TrashData(id: "01", type: "burn", trashVal: ""));
    result[0].add(TrashData(id: "02", type: "unburn", trashVal: ""));
    result[34].add(TrashData(id: "03", type: "other", trashVal: "その他"));
    when(trashDataService.getEnableTrashList(year: anyNamed("year"), month: anyNamed("month"),targetDateList: anyNamed("targetDateList"))).thenAnswer((realInvocation) => result);

    final accountLinkService = MockAccountLinkServiceInterface();
    final changeThemeModel = MockChangeThemeModel();
    final appConfigProvider = MockAppConfigProviderInterface();
    when(appConfigProvider.version).thenReturn("1.0.0");
    await tester.pumpWidget(
        MultiProvider(
            providers: [
              Provider<TrashDataServiceInterface>(
                create: (context) => trashDataService,
              ),
              Provider<AccountLinkServiceInterface>(
                  create: (context)=> accountLinkService
              ),
              Provider<AppConfigProviderInterface>(
                  create: (context)=> appConfigProvider
              ),
              ChangeNotifierProvider<ChangeThemeModel>(
                  create: (context)=> changeThemeModel
              )],
            child: MyApp()
        // MyApp()
      )
    );

    // インジケーターが表示されることを確認
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // AppBarタイトルにテスト実施時の年月が表示されるまで最大10秒待つ
    DateTime now = DateTime.now();
    await tester.pumpAndSettle(Duration(seconds: 10));
    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);

    // インジケーターが表示されないことを確認
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // key=weekday_labelのコンポーネントの子要素が7つあること
    // またテキストが順番に日月火水木金土であること
    final weekdayTexts = ['日', '月', '火', '水', '木', '金', '土'];
    final childrenExpanded = find.descendant(of: find.byKey(Key('weekday_label_0')), matching: find.byType(Expanded));
    expect(
      childrenExpanded,
      findsNWidgets(7)
    );
    int i=0;
    childrenExpanded.evaluate().forEach((element) {
      expect(
        find.descendant(of: find.byWidget(element.widget), matching: find.text(weekdayTexts[i])),
        findsOneWidget
      );
      i++;
    });

    // key=calendar_columnのコンポーネントの子要素が6つあること
    final childrenColumn = find.descendant(of: find.byKey(Key('calendar_column_0')), matching: find.byType(Flexible));
    expect(
      childrenColumn,
      findsNWidgets(6)
    );
    // key=calendar_columnの2番目以降の子コンポーネントの子要素が7つあること
    // またそれぞれのテキストが数字であること
    i=0;
    childrenColumn.evaluate().forEach((element) {
      if(i>0){
        final childrenExpanded = find.descendant(of: find.byWidget(element.widget), matching: find.byType(Expanded));
        expect(
          childrenExpanded,
          findsNWidgets(7)
        );
        childrenExpanded.evaluate().forEach((element) {
          final childrenTexts = find.descendant(of: find.byWidget(element.widget), matching: find.byType(Text));
          final dateText = childrenTexts.first.evaluate().single.widget as Text;
          expect(
            int.tryParse(dateText.data!),
            isNotNull
          );
        });
      }
      i++;
    });

    // カレンダーの最初の日のゴミ出し情報が表示されていること
    final secondColumn = childrenColumn.at(1).evaluate().single.widget;
    final secondColumnExpanded = find.descendant(of: find.byWidget(secondColumn), matching: find.byType(Expanded));
    final secondColumnExpandedTexts = find.descendant(of: find.byWidget(secondColumnExpanded.first.evaluate().single.widget), matching: find.byType(Text));
    expect(
      secondColumnExpandedTexts,
      findsNWidgets(3)
    );
    expect(
      (secondColumnExpandedTexts.at(1).evaluate().single.widget as Text).data,
      "燃えるゴミ"
    );
    expect(
      (secondColumnExpandedTexts.at(2).evaluate().single.widget as Text).data,
      "燃えないゴミ"
    );

    // カレンダーの最後の日のゴミ出し情報が表示されていること
    final lastColumn = childrenColumn.at(5).evaluate().single.widget;
    final lastColumnExpanded = find.descendant(of: find.byWidget(lastColumn), matching: find.byType(Expanded));
    final lastColumnExpandedTexts = find.descendant(of: find.byWidget(lastColumnExpanded.last.evaluate().single.widget), matching: find.byType(Text));
    expect(
      lastColumnExpandedTexts,
      findsNWidgets(2)
    );
    expect(
      (lastColumnExpandedTexts.at(1).evaluate().single.widget as Text).data,
      "その他"
    );

  });
}
