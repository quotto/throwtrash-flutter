import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/legal_pages.dart';

void main() {
  testWidgets('その他画面から利用規約とプライバシーポリシーを開ける', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: OtherPage(applicationVersion: '1.0.0')),
    );

    expect(find.text('利用規約'), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('ライセンス'), findsOneWidget);

    await tester.tap(find.text('利用規約'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('本利用規約は、「今日のゴミ出し」アプリの利用条件を定めるものです。'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('プライバシーポリシー'));
    await tester.pumpAndSettle();
    expect(find.textContaining('AI取り込みのために入力された郵便番号'), findsOneWidget);
  });
}
