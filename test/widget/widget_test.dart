import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:throwtrash/main.dart';
import 'package:throwtrash/usecase/account_link_api_interface.dart';
import 'package:throwtrash/repository/account_link_repository.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/repository/trash_repository.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:http/http.dart' as http;

import 'widget_test.mocks.dart';

@GenerateMocks([http.Client,AccountLinkApiInterface, ActivationApiInterface])
void main() {
  // アプリのmain関数で初期化される変数をテスト実行前に初期化する。
  setUpAll(() async{
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // TrashApiのためのhttp.Clientをモック化
    final mockClient = MockClient();
    // postメソッドのモックを作成
    when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"id":"123456", "timestamp": 9999999999}', 200));

    // AccountLinkApiInterfaceのモックを作成
    AccountLinkApiInterface mockAccountLinkApi = MockAccountLinkApiInterface();

    // ActivationApiInterfaceのモックを作成
    ActivationApiInterface mockActivationApi = MockActivationApiInterface();

    await initializeService(
      userRepository: UserRepository(),
      trashRepository: TrashRepository(),
      accountLinkRepository: AccountLinkRepository(),
      trashApi: TrashApi("",mockClient),
      accountLinkApi: mockAccountLinkApi,
      activationApi: mockActivationApi,
    );
  });
  testWidgets('アプリ起動後のカレンダー画面の確認テスト', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

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
          expect(
            find.descendant(of: find.byWidget(element.widget), matching: find.byType(Text)),
            findsOneWidget
          );
        });
      }
      i++;
    });
  });
}
