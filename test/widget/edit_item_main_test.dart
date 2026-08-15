import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:throwtrash/edit.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_import_message.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/viewModels/edit_model.dart';

import 'widget_test.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('編集画面でその他ゴミの名称が初期表示される', (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    final trashData = TrashData(
      id: '001',
      type: 'other',
      trashVal: '家電',
      schedules: [TrashSchedule('weekday', '0')],
      excludes: [],
    );
    when(trashDataService.getTrashDataById('001')).thenReturn(trashData);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
          create: (context) => EditModel(trashDataService),
          child: EditItemMain.update('001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);
    final textField = tester.widget<TextFormField>(textFieldFinder);
    expect(textField.controller?.text, '家電');
  });

  testWidgets('その他ゴミの名称は20文字まで入力でき21文字目は入力されない',
      (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    final trashData = TrashData(
      id: '001',
      type: 'other',
      trashVal: '',
      schedules: [TrashSchedule('weekday', '0')],
      excludes: [],
    );
    when(trashDataService.getTrashDataById('001')).thenReturn(trashData);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
          create: (context) => EditModel(trashDataService),
          child: EditItemMain.update('001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextFormField);
    const inputName = 'あいうえおかきくけこさしすせそたちつてとな';
    const truncatedName = 'あいうえおかきくけこさしすせそたちつてと';
    expect(inputName.length, 21);
    await tester.enterText(textFieldFinder, inputName);
    await tester.pump();

    final textField = tester.widget<TextFormField>(textFieldFinder);
    expect(textField.controller?.text.length, 20);
    expect(textField.controller?.text, truncatedName);
    expect(textField.controller?.text, isNot(contains('な')));
  });

  testWidgets('編集対象の読み込みに失敗した場合はエラーが表示される', (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    when(trashDataService.getTrashDataById('404')).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
          create: (context) => EditModel(trashDataService),
          child: EditItemMain.update('404'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('データの読み込みに失敗しました'), findsOneWidget);
  });

  testWidgets('編集画面では取り込み結果メッセージを表示しない', (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    final trashData = TrashData(
      id: '001',
      type: 'other',
      trashVal: '家電',
      schedules: [TrashSchedule('weekday', '0')],
      excludes: [],
    );
    when(trashDataService.getTrashDataById('001')).thenReturn(trashData);
    when(
      trashDataService.consumeImportMessage(),
    ).thenAnswer((_) async => TrashImportMessage.success('ゴミ出し予定を取り込みました'));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
          create: (context) => EditModel(trashDataService),
          child: EditItemMain.update('001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ゴミ出し予定を取り込みました'), findsNothing);
    verifyNever(trashDataService.consumeImportMessage());
  });

  testWidgets('編集画面に E2E 向け key が配置される', (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
          create: (context) => EditModel(trashDataService),
          child: EditItemMain(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(Key('trash-type-dropdown')), findsOneWidget);
    expect(find.byKey(Key('schedule-form-0')), findsOneWidget);
    expect(find.byKey(Key('schedule-type-0-weekday')), findsOneWidget);
    expect(find.byKey(Key('schedule-input-0')), findsOneWidget);
    expect(find.byKey(Key('add-schedule-button')), findsOneWidget);
    expect(find.byKey(Key('open-exclude-date-settings')), findsOneWidget);
    expect(find.byKey(Key('submit')), findsOneWidget);
  });
}
