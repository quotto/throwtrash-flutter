// Mocks generated by Mockito 5.4.3 from annotations
// in throwtrash/test/unit/viewModels/alarm_model_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:throwtrash/models/alarm.dart' as _i2;
import 'package:throwtrash/usecase/alarm_service_interface.dart' as _i3;

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

class _FakeAlarm_0 extends _i1.SmartFake implements _i2.Alarm {
  _FakeAlarm_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AlarmServiceInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockAlarmServiceInterface extends _i1.Mock
    implements _i3.AlarmServiceInterface {
  @override
  _i4.Future<void> refreshAlarmToken(
    String? oldToken,
    String? newToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #refreshAlarmToken,
          [
            oldToken,
            newToken,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<bool> enableAlarm({
    required int? hour,
    required int? minute,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #enableAlarm,
          [],
          {
            #hour: hour,
            #minute: minute,
          },
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> cancelAlarm() => (super.noSuchMethod(
        Invocation.method(
          #cancelAlarm,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> changeAlarmTime({
    required int? hour,
    required int? minute,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #changeAlarmTime,
          [],
          {
            #hour: hour,
            #minute: minute,
          },
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<_i2.Alarm> getAlarm() => (super.noSuchMethod(
        Invocation.method(
          #getAlarm,
          [],
        ),
        returnValue: _i4.Future<_i2.Alarm>.value(_FakeAlarm_0(
          this,
          Invocation.method(
            #getAlarm,
            [],
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.Alarm>.value(_FakeAlarm_0(
          this,
          Invocation.method(
            #getAlarm,
            [],
          ),
        )),
      ) as _i4.Future<_i2.Alarm>);
}
