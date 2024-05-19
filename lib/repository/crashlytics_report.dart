/*
CrashReportService
クラッシュレポートをFirebase Crashlyticsに送信する
 */
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../usecase/repository/crash_report_interface.dart';

class CrashlyticsReport implements CrashReportInterface {
  static CrashlyticsReport? _instance;

  factory CrashlyticsReport() {
    if(_instance==null) {
      _instance = new CrashlyticsReport._();
    }
    return _instance!;
  }

  CrashlyticsReport._();

  void initialize() {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  @override
  void reportCrash(dynamic exception, {StackTrace? stackTrace, bool? fatal}) {
    FirebaseCrashlytics.instance.recordError(exception, stackTrace, fatal: fatal != null ? fatal : true);
  }
}
