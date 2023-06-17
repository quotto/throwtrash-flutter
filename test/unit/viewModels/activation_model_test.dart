import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/viewModels/activation_model.dart';

import 'activation_model_test.mocks.dart';


@GenerateMocks([ShareServiceInterface])
void main() {
  group('ActivationModel', () {
    late MockShareServiceInterface mockShareService;
    late ActivationModel activationModel;

    setUp(() {
      mockShareService = MockShareServiceInterface();
      activationModel = ActivationModel(mockShareService);
    });

    test('getActivationCode sets status and publishedCode when successful', () async {
      when(mockShareService.getActivationCode())
          .thenAnswer((_) async => '1234567890');

      await activationModel.getActivationCode();

      expect(activationModel.publishedCode, '1234567890');
      expect(activationModel.status, ActivationStatus.SUCCESS);
    });

    test('getActivationCode sets status to FAILED when failed', () async {
      when(mockShareService.getActivationCode()).thenAnswer((_)=>Future.error(Exception()));

      await activationModel.getActivationCode();

      expect(activationModel.status, ActivationStatus.FAILED);
    });

    test('setCodeValue updates code characters and calls importSchedule when code length is 10', () async {
      when(mockShareService.importSchedule(any)).thenAnswer((_) async => true);
      String testCode = '1234567890';
      for (int i = 0; i < testCode.length; i++) {
        activationModel.setCodeValue(testCode[i], i);
      }

      expect(activationModel.activateCodeChars.join(), testCode);
      verify(mockShareService.importSchedule(testCode)).called(1);
    });

    test('activateCode calls importSchedule when code length is 10', () async {
      when(mockShareService.importSchedule(any)).thenAnswer((_) async => true);
      String testCode = '1234567890';

      await activationModel.activateCode(testCode);

      verify(mockShareService.importSchedule(testCode)).called(1);
    });
  });
}
