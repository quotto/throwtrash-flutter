// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/usecase/trash_data_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/usecase/crash_report_interface.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [CrashReportInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockCrashReportInterface extends _i1.Mock
    implements _i2.CrashReportInterface {
  MockCrashReportInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void reportCrash(
    dynamic exception, {
    StackTrace? stackTrace,
    bool? fatal,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #reportCrash,
          [exception],
          {
            #stackTrace: stackTrace,
            #fatal: fatal,
          },
        ),
        returnValueForMissingStub: null,
      );
}
