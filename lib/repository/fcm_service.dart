import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/config_repository_interface.dart';

import '../usecase/fcm_interface.dart';

class FcmService implements FcmInterface {
  final FirebaseMessaging _firebaseMessaging;
  final ConfigRepositoryInterface _configRepository;
  final Logger _logger = Logger();

  FcmService(this._firebaseMessaging, this._configRepository);

  @override
  Future<String> refreshDeviceToken() async {
    final currentToken = await _firebaseMessaging.getToken();
    if(currentToken == null) {
      final errMessage = 'デバイストークンの取得に失敗しました';
      _logger.e(errMessage);
      throw Exception(errMessage);
    }

    final savedToken = await _configRepository.getDeviceToken();
    if (savedToken == null || savedToken != currentToken) {
      await _configRepository.saveDeviceToken(currentToken);
      _logger.i('デバイストークンを更新しました: $currentToken');
    }
    return currentToken;
  }
}