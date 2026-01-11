import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:throwtrash/edit.dart';
import 'package:throwtrash/models/trash_data.dart';
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
        excludes: []);
    when(trashDataService.getTrashDataById('001')).thenReturn(trashData);

    await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
            create: (context) => EditModel(trashDataService),
            child: EditItemMain.update('001'))));

    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);
    final textField = tester.widget<TextFormField>(textFieldFinder);
    expect(textField.controller?.text, '家電');
  });

  testWidgets('編集対象の読み込みに失敗した場合はエラーが表示される', (WidgetTester tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    when(trashDataService.getTrashDataById('404')).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<EditModel>(
            create: (context) => EditModel(trashDataService),
            child: EditItemMain.update('404'))));

    await tester.pumpAndSettle();

    expect(find.text('データの読み込みに失敗しました'), findsOneWidget);
  });
}
