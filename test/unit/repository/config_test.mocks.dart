// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/repository/config_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i3;
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart'
    as _i2;

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

/// A class which mocks [EnvironmentProviderInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockEnvironmentProviderInterface extends _i1.Mock
    implements _i2.EnvironmentProviderInterface {
  @override
  String get flavor => (super.noSuchMethod(
        Invocation.getter(#flavor),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#flavor),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#flavor),
        ),
      ) as String);

  @override
  String get appIdSuffix => (super.noSuchMethod(
        Invocation.getter(#appIdSuffix),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#appIdSuffix),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#appIdSuffix),
        ),
      ) as String);

  @override
  String get appNameSuffix => (super.noSuchMethod(
        Invocation.getter(#appNameSuffix),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#appNameSuffix),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#appNameSuffix),
        ),
      ) as String);

  @override
  String get versionName => (super.noSuchMethod(
        Invocation.getter(#versionName),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#versionName),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#versionName),
        ),
      ) as String);

  @override
  String get alarmApiKey => (super.noSuchMethod(
        Invocation.getter(#alarmApiKey),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#alarmApiKey),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#alarmApiKey),
        ),
      ) as String);
}
