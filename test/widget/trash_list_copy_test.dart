import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:throwtrash/list.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_import_message.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/view_common/app_feedback.dart';
import 'package:throwtrash/viewModels/list_model.dart';

import 'widget_test.mocks.dart';

void main() {
  Future<void> pumpTrashList(
    WidgetTester tester,
    MockTrashDataServiceInterface trashDataService,
  ) async {
    when(trashDataService.allTrashList).thenReturn([]);
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
  }

  testWidgets('一覧画面で取り込み成功メッセージが正常系背景色で一度だけ表示される', (tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    when(
      trashDataService.consumeImportMessage(),
    ).thenAnswer((_) async => TrashImportMessage.success('ゴミ出し予定を取り込みました'));

    await pumpTrashList(tester, trashDataService);
    await tester.pump();

    expect(find.text('ゴミ出し予定を取り込みました'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppFeedbackColors.successBackground);

    await tester.pump();
    verify(trashDataService.consumeImportMessage()).called(1);
  });

  testWidgets('一覧画面で取り込み失敗メッセージが異常系背景色で一度だけ表示される', (tester) async {
    final trashDataService = MockTrashDataServiceInterface();
    when(
      trashDataService.consumeImportMessage(),
    ).thenAnswer((_) async => TrashImportMessage.error('自動取り込み結果の保存に失敗しました。'));

    await pumpTrashList(tester, trashDataService);
    await tester.pump();

    expect(find.text('自動取り込み結果の保存に失敗しました。'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppFeedbackColors.errorBackground);

    await tester.pump();
    verify(trashDataService.consumeImportMessage()).called(1);
  });

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
    when(trashDataService.consumeImportMessage()).thenAnswer((_) async => null);
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
    when(trashDataService.consumeImportMessage()).thenAnswer((_) async => null);
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

  testWidgets('一覧画面に E2E 向け key が配置される', (tester) async {
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
    when(trashDataService.consumeImportMessage()).thenAnswer((_) async => null);
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
    await tester.pumpAndSettle();

    expect(find.byKey(Key('trash-row-001')), findsOneWidget);
    expect(find.byKey(Key('edit-trash-001')), findsOneWidget);
    expect(find.byKey(Key('copy-trash-001')), findsOneWidget);
    expect(find.byKey(Key('delete-trash-001')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.identifier == 'trash-list-other',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('編集'), findsOneWidget);
    expect(find.byTooltip('削除'), findsOneWidget);
  });
}
