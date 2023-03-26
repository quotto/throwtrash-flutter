// Mocks generated by Mockito 5.3.2 from annotations
// in throwtrash/test/usecase/share_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/models/activate_response.dart' as _i5;
import 'package:throwtrash/models/calendar_model.dart' as _i9;
import 'package:throwtrash/models/trash_data.dart' as _i8;
import 'package:throwtrash/models/user.dart' as _i2;
import 'package:throwtrash/repository/activation_api_interface.dart' as _i3;
import 'package:throwtrash/repository/trash_repository_interface.dart' as _i7;
import 'package:throwtrash/usecase/user_service_interface.dart' as _i6;

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

class _FakeUser_0 extends _i1.SmartFake implements _i2.User {
  _FakeUser_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ActivationApiInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockActivationApiInterface extends _i1.Mock
    implements _i3.ActivationApiInterface {
  MockActivationApiInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<String> requestActivationCode(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestActivationCode,
          [userId],
        ),
        returnValue: _i4.Future<String>.value(''),
      ) as _i4.Future<String>);
  @override
  _i4.Future<_i5.ActivateResponse?> requestAuthorizationActivationCode(
    String? code,
    String? userId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestAuthorizationActivationCode,
          [
            code,
            userId,
          ],
        ),
        returnValue: _i4.Future<_i5.ActivateResponse?>.value(),
      ) as _i4.Future<_i5.ActivateResponse?>);
}

/// A class which mocks [UserServiceInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserServiceInterface extends _i1.Mock
    implements _i6.UserServiceInterface {
  MockUserServiceInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.User get user => (super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: _FakeUser_0(
          this,
          Invocation.getter(#user),
        ),
      ) as _i2.User);
  @override
  _i4.Future<bool> registerUser(String? id) => (super.noSuchMethod(
        Invocation.method(
          #registerUser,
          [id],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<void> refreshUser() => (super.noSuchMethod(
        Invocation.method(
          #refreshUser,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [TrashRepositoryInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockTrashRepositoryInterface extends _i1.Mock
    implements _i7.TrashRepositoryInterface {
  MockTrashRepositoryInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<bool> updateTrashData(_i8.TrashData? trashData) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTrashData,
          [trashData],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<bool> insertTrashData(_i8.TrashData? trashData) =>
      (super.noSuchMethod(
        Invocation.method(
          #insertTrashData,
          [trashData],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<List<_i8.TrashData>> readAllTrashData() => (super.noSuchMethod(
        Invocation.method(
          #readAllTrashData,
          [],
        ),
        returnValue: _i4.Future<List<_i8.TrashData>>.value(<_i8.TrashData>[]),
      ) as _i4.Future<List<_i8.TrashData>>);
  @override
  _i4.Future<bool> deleteTrashData(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteTrashData,
          [id],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<bool> updateLastUpdateTime(int? updateTimestamp) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateLastUpdateTime,
          [updateTimestamp],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<int> getLastUpdateTime() => (super.noSuchMethod(
        Invocation.method(
          #getLastUpdateTime,
          [],
        ),
        returnValue: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);
  @override
  _i4.Future<bool> truncateAllTrashData() => (super.noSuchMethod(
        Invocation.method(
          #truncateAllTrashData,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<_i9.SyncStatus> getSyncStatus() => (super.noSuchMethod(
        Invocation.method(
          #getSyncStatus,
          [],
        ),
        returnValue: _i4.Future<_i9.SyncStatus>.value(_i9.SyncStatus.NOT_YET),
      ) as _i4.Future<_i9.SyncStatus>);
  @override
  _i4.Future<bool> setSyncStatus(_i9.SyncStatus? syncStatus) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSyncStatus,
          [syncStatus],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
