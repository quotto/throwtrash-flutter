import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/auto_import_dialog.dart';
import 'package:throwtrash/models/trash_search_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

import 'widget_test.mocks.dart';

void main() {
  testWidgets('AI取り込みダイアログは空入力時に実行できず50文字制限が効く', (tester) async {
    final service = MockTrashDataServiceInterface();
    await tester.pumpWidget(
      Provider<TrashDataServiceInterface>.value(
        value: service,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAutoImportDialog(context),
              child: Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('AI取り込み（β）'), findsOneWidget);
    final submitButton = tester.widget<ElevatedButton>(
      find.byKey(Key('auto-import-submit')),
    );
    expect(submitButton.onPressed, isNull);

    await tester.enterText(find.byKey(Key('auto-import-input')), 'あ' * 60);
    await tester.pump();

    final input = tester.widget<TextField>(
      find.byKey(Key('auto-import-input')),
    );
    expect(input.controller!.text.length, 50);
    final enabledSubmitButton = tester.widget<ElevatedButton>(
      find.byKey(Key('auto-import-submit')),
    );
    expect(enabledSubmitButton.onPressed, isNotNull);
    expect(find.textContaining('留意事項を読み、詳細な住所を入力しないようにしてください'), findsOneWidget);
  });

  testWidgets('留意事項リンクから新しい注意事項を表示する', (tester) async {
    final service = MockTrashDataServiceInterface();
    await tester.pumpWidget(
      Provider<TrashDataServiceInterface>.value(
        value: service,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAutoImportDialog(context),
              child: Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('auto-import-note-link')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('AIによる自動登録機能であるため誤りを含む可能性があります。'),
      findsOneWidget,
    );
    expect(find.textContaining('詳細は入力しないでください'), findsOneWidget);
    expect(find.textContaining('入力データの学習を無効化しています'), findsOneWidget);
  });

  testWidgets('初回ダイアログはキャンセルで表示済みにする', (tester) async {
    final service = MockTrashDataServiceInterface();
    when(service.markInitialSearchDialogShown()).thenAnswer((_) async => true);

    await tester.pumpWidget(
      Provider<TrashDataServiceInterface>.value(
        value: service,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAutoImportDialog(
                context,
                updateInitialDisplayStatus: true,
              ),
              child: Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('auto-import-cancel')));
    await tester.pumpAndSettle();

    verify(service.markInitialSearchDialogShown()).called(1);
    expect(find.text('AI取り込み（β）'), findsNothing);
  });

  testWidgets('実行時に開始メッセージを表示し非同期取り込みを開始する', (tester) async {
    final service = MockTrashDataServiceInterface();
    when(service.markInitialSearchDialogShown()).thenAnswer((_) async => true);
    when(
      service.importTrashSchedule('160-0023'),
    ).thenAnswer((_) async => TrashImportResult.success());

    await tester.pumpWidget(
      Provider<TrashDataServiceInterface>.value(
        value: service,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAutoImportDialog(
                  context,
                  updateInitialDisplayStatus: true,
                ),
                child: Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('auto-import-input')), '160-0023');
    await tester.pump();
    await tester.tap(find.byKey(Key('auto-import-submit')));
    await tester.pump();

    verify(service.markInitialSearchDialogShown()).called(1);
    verify(service.importTrashSchedule('160-0023')).called(1);
    expect(find.textContaining('取り込みには数分かかる可能性があります'), findsOneWidget);
  });
}
