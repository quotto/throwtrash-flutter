abstract class ConfigInterface {
  String get apiEndpoint;
  String get mobileApiEndpoint;
  String get apiErrorUrl;
  Future<void> initialize();
}