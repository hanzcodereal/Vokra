import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FirebaseMessagingWeb extends FirebaseMessagingPlatform {
  FirebaseMessagingWeb({FirebaseApp? app}) : super(appInstance: app);

  static final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  static const NotificationSettings _deniedSettings = NotificationSettings(
    alert: AppleNotificationSetting.notSupported,
    announcement: AppleNotificationSetting.notSupported,
    authorizationStatus: AuthorizationStatus.denied,
    badge: AppleNotificationSetting.notSupported,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.notSupported,
    notificationCenter: AppleNotificationSetting.notSupported,
    showPreviews: AppleShowPreviewSetting.notSupported,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    sound: AppleNotificationSetting.notSupported,
  );

  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('messaging');
    FirebaseMessagingPlatform.instance = FirebaseMessagingWeb();
  }

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseMessagingWeb(app: app);
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    return this;
  }

  @override
  bool get isAutoInitEnabled => false;

  @override
  Future<void> deleteToken() async {}

  @override
  Future<String?> getAPNSToken() async => null;

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return _deniedSettings;
  }

  @override
  Future<String?> getToken({String? vapidKey}) async => null;

  @override
  Future<bool> isSupported() async => false;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {}

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    return _deniedSettings;
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {}

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {}

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}
