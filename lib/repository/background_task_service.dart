import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/repository/background_task_interface.dart';

class BackgroundTaskService implements BackgroundTaskInterface {
  BackgroundTaskService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('throwtrash/background_task');

  final MethodChannel _channel;
  final _logger = Logger();

  @override
  Future<T> runTask<T>(String name, Future<T> Function() task) async {
    final taskId = await _startTask(name);
    try {
      return await task();
    } finally {
      if (taskId != null) {
        await _endTask(taskId);
      }
    }
  }

  Future<String?> _startTask(String name) async {
    try {
      return await _channel.invokeMethod<String>('start', <String, String>{
        'name': name,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      _logger.w('バックグラウンドタスクの開始に失敗しました: $error');
      return null;
    }
  }

  Future<void> _endTask(String taskId) async {
    try {
      await _channel.invokeMethod<void>('end', <String, String>{'id': taskId});
    } on MissingPluginException {
      return;
    } on PlatformException catch (error) {
      _logger.w('バックグラウンドタスクの終了に失敗しました: $error');
    }
  }
}
