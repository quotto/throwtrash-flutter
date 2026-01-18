import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/activate_response.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/activation_api_interface.dart';
import 'package:throwtrash/usecase/repository/crash_report_interface.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

import 'share_service_test.mocks.dart';

@GenerateMocks([ActivationApiInterface,UserServiceInterface,TrashRepositoryInterface,CrashReportInterface])
void main() {
  group('ShareService', () {
    late MockActivationApiInterface activationApi;
    late MockUserServiceInterface userService;
    late MockTrashRepositoryInterface trashRepository;
    late ShareService shareService;
    late MockCrashReportInterface crashReport;

    setUp(() {
      // Firebaseをモック化する

      activationApi = MockActivationApiInterface();
      userService = MockUserServiceInterface();
      trashRepository = MockTrashRepositoryInterface();
      crashReport = MockCrashReportInterface();
      shareService = ShareService(activationApi, userService, trashRepository, crashReport);
    });

    test('getActivationCode returns activation code', () async {
      final testUserId = 'test_user_id';
      final testActivationCode = 'test_activation_code';

      when(userService.user).thenReturn(User(testUserId));
      when(activationApi.requestActivationCode(testUserId)).thenAnswer((_) async => testActivationCode);

      final activationCode = await shareService.getActivationCode();

      expect(activationCode, testActivationCode);
    });

    test('importSchedule imports schedule and returns true when successful', () async {
      final testActivationCode = 'test_activation_code';
      final testUserId = 'test_user_id';
      final testTimestamp = 1633024800;
      final testDescription = '[{"id":"1234567","type":"burn", "schedules":[{"type":"weekday","value":"1"}]}]';
      final activateResponse = ActivateResponse(testDescription, testTimestamp);

      when(activationApi.requestAuthorizationActivationCode(testActivationCode, testUserId))
          .thenAnswer((_) async => activateResponse);
      when(userService.user).thenReturn(User(testUserId));
      when(trashRepository.truncateAllTrashData()).thenAnswer((_) async => true);
      when(trashRepository.insertTrashData(any)).thenAnswer((_) async => true);
      when(trashRepository.updateLastUpdateTime(testTimestamp)).thenAnswer((_) async => true);

      final result = await shareService.importSchedule(testActivationCode);

      expect(result, true);
    });

    test('importSchedule returns false when activation fails', () async {
      final testActivationCode = 'test_activation_code';
      final testUserId = 'test_user_id';

      when(activationApi.requestAuthorizationActivationCode(testActivationCode, testUserId))
          .thenAnswer((_) async => null);
      when(userService.user).thenReturn(User(testUserId));

      final result = await shareService.importSchedule(testActivationCode);

      expect(result, false);
    });
  });
}
