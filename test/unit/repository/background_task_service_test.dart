import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/repository/background_task_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/background_task');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'start' ? 'task-id' : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('処理をバックグラウンドタスクで囲む', () async {
    final service = BackgroundTaskService(channel: channel);

    final result = await service.runTask('trash_search_import', () async {
      return 'done';
    });

    expect(result, 'done');
    expect(calls.map((call) => call.method), ['start', 'end']);
    expect(calls.first.arguments, {'name': 'trash_search_import'});
    expect(calls.last.arguments, {'id': 'task-id'});
  });

  test('処理が失敗してもバックグラウンドタスクを終了する', () async {
    final service = BackgroundTaskService(channel: channel);

    await expectLater(
      service.runTask<void>('trash_search_import', () async {
        throw StateError('failed');
      }),
      throwsStateError,
    );

    expect(calls.map((call) => call.method), ['start', 'end']);
  });
}
