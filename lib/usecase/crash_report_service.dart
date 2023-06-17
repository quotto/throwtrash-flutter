/*
CrashReportService
クラッシュレポートをFirebase Crashlyticsに送信する
 */
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashReportService {
  static CrashReportService? _instance;

  factory CrashReportService() {
    if(_instance==null) {
      _instance = new CrashReportService._();
    }
    return _instance!;
  }

  CrashReportService._();

  void initialize() {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  void recordError(dynamic exception, {StackTrace? stack, bool fatal=true}) {
    FirebaseCrashlytics.instance.recordError(exception, stack, fatal: fatal );
  }
}