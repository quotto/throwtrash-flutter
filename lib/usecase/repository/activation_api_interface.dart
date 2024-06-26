import '../../models/activate_response.dart';

abstract class ActivationApiInterface {
  Future<String> requestActivationCode(String userId);
  Future<ActivateResponse?> requestAuthorizationActivationCode(String code, String userId);
}