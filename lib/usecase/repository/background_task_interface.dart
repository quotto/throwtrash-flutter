abstract class BackgroundTaskInterface {
  Future<T> runTask<T>(String name, Future<T> Function() task);
}
