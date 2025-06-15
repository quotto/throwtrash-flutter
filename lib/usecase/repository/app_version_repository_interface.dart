abstract class AppVersionRepositoryInterface {
  Future<String?> getSavedAppVersion();
  Future<void> saveAppVersion(String version);
}

