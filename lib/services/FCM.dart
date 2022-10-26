import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../requestWidget.dart';
import 'localNotification.dart';
import 'newRequestNotification.dart';

class RequestAcceptanceNotification {
  final NotificationService notificationService = NotificationService();

  Future initApp() async {
    notificationService.initializePlatformNotifications();
    setupInteractedMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage");
      print("onMessage ${message.notification!.title}");
      var Title = message.notification!.title == null
          ? 'no data'
          : message.notification!.title;
      var Body = message.notification!.body == null
          ? 'no data'
          : message.notification!.body;
      notificationService.showLocalNotification(
          id: 0,
          title: Title!,
          body: Body!,
          payload: 'requestAcceptance-${message.data['id']}');
    });
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('message.data ${message.data}');
    print('message.data ${message.data['id']}');

    Navigator.pushReplacement(
      GlobalContextService.navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => requestPage(
            userType: 'Special Need User',
            reqID: message.data['id'],
            userID: message.data['userID']),
        transitionDuration: const Duration(seconds: 1),
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
