abstract class CrashReportInterface {
  void reportCrash(dynamic exception, {StackTrace? stackTrace, bool? fatal});
}