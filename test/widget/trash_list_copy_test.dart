import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:throwtrash/list.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/list_model.dart';

import 'widget_test.mocks.dart';

void main() {
  testWidgets('一覧画面でコピーボタンが削除ボタンの左側に表示される', (tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    when(trashDataService.allTrashList).thenReturn([
      TrashData(
        id: '001',
        type: 'other',
        trashVal: '家電',
        schedules: [TrashSchedule('weekday', '0')],
        excludes: [],
      ),
    ]);
    when(
      trashDataService.getTrashName(
        type: anyNamed('type'),
        trashVal: anyNamed('trashVal'),
      ),
    ).thenReturn('家電');

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<TrashDataServiceInterface>.value(value: trashDataService),
            ChangeNotifierProvider<ListModel>(
              create: (_) => ListModel(trashDataService),
            ),
          ],
          child: TrashList(),
        ),
      ),
    );

    final copyButton = find.byKey(Key('copy-trash-001'));
    final deleteButton = find.byKey(Key('delete-trash-001'));

    expect(copyButton, findsOneWidget);
    expect(deleteButton, findsOneWidget);
    expect(
      tester.getTopLeft(copyButton).dx,
      lessThan(tester.getTopLeft(deleteButton).dx),
    );
  });

  testWidgets('コピーボタン押下で未登録のままコピー作成画面を開く', (tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    final trashData = TrashData(
      id: '001',
      type: 'other',
      trashVal: '家電',
      schedules: [TrashSchedule('weekday', '0')],
      excludes: [],
    );
    when(trashDataService.allTrashList).thenReturn([trashData]);
    when(
      trashDataService.getTrashName(
        type: anyNamed('type'),
        trashVal: anyNamed('trashVal'),
      ),
    ).thenReturn('家電');
    when(trashDataService.getTrashDataById('001')).thenReturn(trashData);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<TrashDataServiceInterface>.value(value: trashDataService),
            ChangeNotifierProvider<ListModel>(
              create: (_) => ListModel(trashDataService),
            ),
          ],
          child: TrashList(),
        ),
      ),
    );

    await tester.tap(find.byKey(Key('copy-trash-001')));
    await tester.pumpAndSettle();

    verifyNever(trashDataService.addTrashData(any));
    verifyNever(trashDataService.updateTrashData(any));
    verifyNever(trashDataService.deleteTrashData(any));
    expect(find.text('登録'), findsOneWidget);

    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.controller?.text, '家電');
  });
}
