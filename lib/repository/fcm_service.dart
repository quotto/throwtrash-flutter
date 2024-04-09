import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/repository/config_repository_interface.dart';

import '../usecase/repository/fcm_interface.dart';

class FcmService implements FcmInterface {
  final FirebaseMessaging _firebaseMessaging;
  final ConfigRepositoryInterface _configRepository;
  static late final GlobalKey<NavigatorState> _navigatorKey;
  static final Logger _logger = Logger();
  static FcmService? _instance;

  FcmService._(this._firebaseMessaging, this._configRepository);

  static initialize(FirebaseMessaging firebaseMessaging, ConfigRepositoryInterface configRepository, GlobalKey<NavigatorState> navigatorKey) {
    if(_instance != null) throw StateError('FcmServiceは既に初期化されています');
    _instance = FcmService._(firebaseMessaging, configRepository);

    _navigatorKey = navigatorKey;

    firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    ).then((settings) {
      _logger.i('User granted permission: ${settings.authorizationStatus}');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');

        if (message.notification != null) {
          _logger.i(
              'Message also contained a notification: ${message.notification
                  .toString()}');
        }
        _showForegroundNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('A new onMessageOpenedApp event was published!');
        Navigator.popUntil(
            navigatorKey.currentContext!, (route) => route.isFirst);
      });
    }).catchError((onError) {
      _logger.e('FirebaseMessagingの設定でエラーが発生しました。');
      _logger.e(onError.toString());
    });
  }

  factory FcmService() {
    if(_instance == null) {
      throw StateError('FcmServiceが初期化されていません');
    }
    return _instance!;
  }


  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    Navigator.popUntil(
      _navigatorKey.currentContext!,
          (route) => route.isFirst,
    );
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    _logger.d('showForegroundNotification: ${message.notification}');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: initializationSettingsDarwin
    );

    const DarwinNotificationDetails notificationDetailsDarwin = DarwinNotificationDetails();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    const NotificationDetails notificationDetails =
    NotificationDetails(iOS: notificationDetailsDarwin);
    await flutterLocalNotificationsPlugin.show(
        0, message.notification?.title, message.notification?.body, notificationDetails,
        payload: 'item x');
  }

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