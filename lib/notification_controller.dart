import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'home.dart';

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  @override
  void onInit() async {
    super.onInit();

    // 푸시 알림 권한 요청
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print(settings.authorizationStatus);

    _getToken();

    // 로컬 알림 플러그인 초기화
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    );

    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen(_onMessage);

    // 백그라운드 메시지 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 알림 클릭 시 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _onNotificationOpened(message);
    });
  }

  void _getToken() async {
    String? token = await messaging.getToken();
    print('Firebase token: $token');
  }

  // 포그라운드에서 메시지를 처리하는 메서드
  void _onMessage(RemoteMessage message) async {
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title ?? "No title",  // Null 처리
        message.notification!.body ?? "No message", // Null 처리
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  // 백그라운드에서 메시지를 처리하는 핸들러
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    if (message.notification != null) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title ?? "No title",  // Null 처리
        message.notification!.body ?? "No message", // Null 처리
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  // 알림을 클릭했을 때 처리하는 메서드
  void _onNotificationOpened(RemoteMessage message) {
    print("Notification clicked: ${message.notification?.title}");
    Get.to(() => HomePage());
  }
}
