import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS Maestro E2E workflow', () {
    test('FlutterFire CLIをインストールしてCrashlytics build phaseを実行できる', () {
      final workflowFile = File('.github/workflows/ios-maestro-e2e.yml');
      final workflowContent = workflowFile.readAsStringSync();
      final projectFile = File('ios/Runner.xcodeproj/project.pbxproj');
      final projectContent = projectFile.readAsStringSync();

      expect(
        workflowContent,
        contains('dart pub global activate flutterfire_cli'),
      );
      expect(
        workflowContent,
        contains(r'echo "$PUB_CACHE/bin" >> "$GITHUB_PATH"'),
      );
      expect(
        projectContent,
        contains('flutterfire upload-crashlytics-symbols'),
      );
    });
  });
}
