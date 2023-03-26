// Mocks generated by Mockito 5.3.2 from annotations
// in throwtrash/test/usecase/account_link_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/models/account_link_info.dart' as _i4;
import 'package:throwtrash/repository/account_link_api_interface.dart' as _i2;
import 'package:throwtrash/repository/account_link_repository_interface.dart'
    as _i6;
import 'package:throwtrash/repository/config_interface.dart' as _i8;
import 'package:throwtrash/repository/user_repository_interface.dart' as _i7;
import 'package:throwtrash/viewModels/account_link_model.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
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
  _i3.Future<String> readUserId() => (super.noSuchMethod(
        Invocation.method(
          #readUserId,
          [],
        ),
        returnValue: _i3.Future<String>.value(''),
      ) as _i3.Future<String>);
  @override
  _i3.Future<bool> writeUserId(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #writeUserId,
          [userId],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> writeDeviceToken(String? deviceToken) => (super.noSuchMethod(
        Invocation.method(
          #writeDeviceToken,
          [deviceToken],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<String> readDeviceToken() => (super.noSuchMethod(
        Invocation.method(
          #readDeviceToken,
          [],
        ),
        returnValue: _i3.Future<String>.value(''),
      ) as _i3.Future<String>);
}

/// A class which mocks [ConfigInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockConfigInterface extends _i1.Mock implements _i8.ConfigInterface {
  MockConfigInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get apiEndpoint => (super.noSuchMethod(
        Invocation.getter(#apiEndpoint),
        returnValue: '',
      ) as String);
  @override
  String get mobileApiEndpoint => (super.noSuchMethod(
        Invocation.getter(#mobileApiEndpoint),
        returnValue: '',
      ) as String);
  @override
  String get apiErrorUrl => (super.noSuchMethod(
        Invocation.getter(#apiErrorUrl),
        returnValue: '',
      ) as String);
  @override
  _i3.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
