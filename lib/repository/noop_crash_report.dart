import 'package:throwtrash/usecase/repository/crash_report_interface.dart';

class NoopCrashReport implements CrashReportInterface {
  @override
  void reportCrash(dynamic exception, {StackTrace? stackTrace, bool? fatal}) {}
}
