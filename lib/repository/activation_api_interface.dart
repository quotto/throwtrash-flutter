import '../models/trash_response.dart';

abstract class ActivationApiInterface {
  Future<String> requestActivationCode(String userId);
  Future<TrashResponse?> requestAuthorizationActivationCode(String code);
}