// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/usecase/change_theme_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/usecase/config_repository_interface.dart' as _i2;

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

/// A class which mocks [ConfigRepositoryInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockConfigRepositoryInterface extends _i1.Mock
    implements _i2.ConfigRepositoryInterface {
  @override
  _i3.Future<bool> saveDarkMode(bool? isDarkMode) => (super.noSuchMethod(
        Invocation.method(
          #saveDarkMode,
          [isDarkMode],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<bool?> readDarkMode() => (super.noSuchMethod(
        Invocation.method(
          #readDarkMode,
          [],
        ),
        returnValue: _i3.Future<bool?>.value(),
        returnValueForMissingStub: _i3.Future<bool?>.value(),
      ) as _i3.Future<bool?>);

  @override
  _i3.Future<String?> getDeviceToken() => (super.noSuchMethod(
        Invocation.method(
          #getDeviceToken,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
        returnValueForMissingStub: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<bool> saveDeviceToken(String? deviceToken) => (super.noSuchMethod(
        Invocation.method(
          #saveDeviceToken,
          [deviceToken],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
