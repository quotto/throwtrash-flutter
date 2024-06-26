// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/usecase/trash_data_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/models/calendar_model.dart' as _i9;
import 'package:throwtrash/models/trash_api_register_response.dart' as _i11;
import 'package:throwtrash/models/trash_data.dart' as _i8;
import 'package:throwtrash/models/trash_sync_result.dart' as _i3;
import 'package:throwtrash/models/trash_update_result.dart' as _i2;
import 'package:throwtrash/models/user.dart' as _i4;
import 'package:throwtrash/usecase/repository/crash_report_interface.dart'
    as _i5;
import 'package:throwtrash/usecase/repository/trash_api_interface.dart' as _i10;
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart'
    as _i6;
import 'package:throwtrash/usecase/user_service_interface.dart' as _i12;

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

class _FakeTrashUpdateResult_0 extends _i1.SmartFake
    implements _i2.TrashUpdateResult {
  _FakeTrashUpdateResult_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTrashSyncResult_1 extends _i1.SmartFake
    implements _i3.TrashSyncResult {
  _FakeTrashSyncResult_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUser_2 extends _i1.SmartFake implements _i4.User {
  _FakeUser_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [CrashReportInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockCrashReportInterface extends _i1.Mock
    implements _i5.CrashReportInterface {
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

/// A class which mocks [TrashRepositoryInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockTrashRepositoryInterface extends _i1.Mock
    implements _i6.TrashRepositoryInterface {
  @override
  _i7.Future<bool> updateTrashData(_i8.TrashData? trashData) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTrashData,
          [trashData],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<bool> insertTrashData(_i8.TrashData? trashData) =>
      (super.noSuchMethod(
        Invocation.method(
          #insertTrashData,
          [trashData],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<List<_i8.TrashData>> readAllTrashData() => (super.noSuchMethod(
        Invocation.method(
          #readAllTrashData,
          [],
        ),
        returnValue: _i7.Future<List<_i8.TrashData>>.value(<_i8.TrashData>[]),
        returnValueForMissingStub:
            _i7.Future<List<_i8.TrashData>>.value(<_i8.TrashData>[]),
      ) as _i7.Future<List<_i8.TrashData>>);

  @override
  _i7.Future<bool> deleteTrashData(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteTrashData,
          [id],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<bool> updateLastUpdateTime(int? updateTimestamp) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateLastUpdateTime,
          [updateTimestamp],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<int> getLastUpdateTime() => (super.noSuchMethod(
        Invocation.method(
          #getLastUpdateTime,
          [],
        ),
        returnValue: _i7.Future<int>.value(0),
        returnValueForMissingStub: _i7.Future<int>.value(0),
      ) as _i7.Future<int>);

  @override
  _i7.Future<bool> truncateAllTrashData() => (super.noSuchMethod(
        Invocation.method(
          #truncateAllTrashData,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<_i9.SyncStatus> getSyncStatus() => (super.noSuchMethod(
        Invocation.method(
          #getSyncStatus,
          [],
        ),
        returnValue: _i7.Future<_i9.SyncStatus>.value(_i9.SyncStatus.NOT_YET),
        returnValueForMissingStub:
            _i7.Future<_i9.SyncStatus>.value(_i9.SyncStatus.NOT_YET),
      ) as _i7.Future<_i9.SyncStatus>);

  @override
  _i7.Future<bool> setSyncStatus(_i9.SyncStatus? syncStatus) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSyncStatus,
          [syncStatus],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);
}

/// A class which mocks [TrashApiInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockTrashApiInterface extends _i1.Mock implements _i10.TrashApiInterface {
  @override
  _i7.Future<_i11.RegisterResponse?> registerUserAndTrashData(
          List<_i8.TrashData>? allTrashData) =>
      (super.noSuchMethod(
        Invocation.method(
          #registerUserAndTrashData,
          [allTrashData],
        ),
        returnValue: _i7.Future<_i11.RegisterResponse?>.value(),
        returnValueForMissingStub: _i7.Future<_i11.RegisterResponse?>.value(),
      ) as _i7.Future<_i11.RegisterResponse?>);

  @override
  _i7.Future<_i2.TrashUpdateResult> updateTrashData(
    String? id,
    List<_i8.TrashData>? localSchedule,
    int? localTimestamp,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTrashData,
          [
            id,
            localSchedule,
            localTimestamp,
          ],
        ),
        returnValue:
            _i7.Future<_i2.TrashUpdateResult>.value(_FakeTrashUpdateResult_0(
          this,
          Invocation.method(
            #updateTrashData,
            [
              id,
              localSchedule,
              localTimestamp,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.TrashUpdateResult>.value(_FakeTrashUpdateResult_0(
          this,
          Invocation.method(
            #updateTrashData,
            [
              id,
              localSchedule,
              localTimestamp,
            ],
          ),
        )),
      ) as _i7.Future<_i2.TrashUpdateResult>);

  @override
  _i7.Future<_i3.TrashSyncResult> syncTrashData(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #syncTrashData,
          [userId],
        ),
        returnValue:
            _i7.Future<_i3.TrashSyncResult>.value(_FakeTrashSyncResult_1(
          this,
          Invocation.method(
            #syncTrashData,
            [userId],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i3.TrashSyncResult>.value(_FakeTrashSyncResult_1(
          this,
          Invocation.method(
            #syncTrashData,
            [userId],
          ),
        )),
      ) as _i7.Future<_i3.TrashSyncResult>);
}

/// A class which mocks [UserServiceInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserServiceInterface extends _i1.Mock
    implements _i12.UserServiceInterface {
  @override
  _i4.User get user => (super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: _FakeUser_2(
          this,
          Invocation.getter(#user),
        ),
        returnValueForMissingStub: _FakeUser_2(
          this,
          Invocation.getter(#user),
        ),
      ) as _i4.User);

  @override
  _i7.Future<bool> registerUser(String? id) => (super.noSuchMethod(
        Invocation.method(
          #registerUser,
          [id],
        ),
        returnValue: _i7.Future<bool>.value(false),
        returnValueForMissingStub: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<void> refreshUser() => (super.noSuchMethod(
        Invocation.method(
          #refreshUser,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}
