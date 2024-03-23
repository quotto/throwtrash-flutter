// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/usecase/account_link_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;
import 'package:throwtrash/models/account_link_info.dart' as _i4;
import 'package:throwtrash/models/user.dart' as _i8;
import 'package:throwtrash/usecase/account_link_api_interface.dart' as _i2;
import 'package:throwtrash/usecase/account_link_repository_interface.dart'
    as _i6;
import 'package:throwtrash/usecase/config_interface.dart' as _i9;
import 'package:throwtrash/usecase/crash_report_interface.dart' as _i11;
import 'package:throwtrash/usecase/user_repository_interface.dart' as _i7;
import 'package:throwtrash/viewModels/account_link_model.dart' as _i5;

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

/// A class which mocks [AccountLinkApiInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountLinkApiInterface extends _i1.Mock
    implements _i2.AccountLinkApiInterface {
  MockAccountLinkApiInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i4.AccountLinkInfo?> startAccountLink(
    String? userId,
    _i5.AccountLinkType? accountLinkType,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #startAccountLink,
          [
            userId,
            accountLinkType,
          ],
        ),
        returnValue: _i3.Future<_i4.AccountLinkInfo?>.value(),
      ) as _i3.Future<_i4.AccountLinkInfo?>);
}

/// A class which mocks [AccountLinkRepositoryInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockAccountLinkRepositoryInterface extends _i1.Mock
    implements _i6.AccountLinkRepositoryInterface {
  MockAccountLinkRepositoryInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<bool> writeAccountLinkInfo(_i4.AccountLinkInfo? info) =>
      (super.noSuchMethod(
        Invocation.method(
          #writeAccountLinkInfo,
          [info],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<_i4.AccountLinkInfo?> readAccountLinkInfo() => (super.noSuchMethod(
        Invocation.method(
          #readAccountLinkInfo,
          [],
        ),
        returnValue: _i3.Future<_i4.AccountLinkInfo?>.value(),
      ) as _i3.Future<_i4.AccountLinkInfo?>);
}

/// A class which mocks [UserRepositoryInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserRepositoryInterface extends _i1.Mock
    implements _i7.UserRepositoryInterface {
  MockUserRepositoryInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i8.User?> readUser() => (super.noSuchMethod(
        Invocation.method(
          #readUser,
          [],
        ),
        returnValue: _i3.Future<_i8.User?>.value(),
      ) as _i3.Future<_i8.User?>);

  @override
  _i3.Future<bool> writeUser(_i8.User? user) => (super.noSuchMethod(
        Invocation.method(
          #writeUser,
          [user],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}

/// A class which mocks [ConfigInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockConfigInterface extends _i1.Mock implements _i9.ConfigInterface {
  MockConfigInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get apiEndpoint => (super.noSuchMethod(
        Invocation.getter(#apiEndpoint),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.getter(#apiEndpoint),
        ),
      ) as String);

  @override
  String get mobileApiEndpoint => (super.noSuchMethod(
        Invocation.getter(#mobileApiEndpoint),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.getter(#mobileApiEndpoint),
        ),
      ) as String);

  @override
  String get apiErrorUrl => (super.noSuchMethod(
        Invocation.getter(#apiErrorUrl),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.getter(#apiErrorUrl),
        ),
      ) as String);

  @override
  String get version => (super.noSuchMethod(
        Invocation.getter(#version),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.getter(#version),
        ),
      ) as String);

  @override
  String get alarmApiUrl => (super.noSuchMethod(
        Invocation.getter(#alarmApiUrl),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.getter(#alarmApiUrl),
        ),
      ) as String);
}

/// A class which mocks [CrashReportInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockCrashReportInterface extends _i1.Mock
    implements _i11.CrashReportInterface {
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
