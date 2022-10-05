import 'dart:math';
import 'package:awn/main.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

const task = 'firstTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    final NotificationService notificationService = NotificationService();
    notificationService.initializePlatformNotifications();

    void onNoticationListener(String? payload) async {
      if (payload != null && payload.isNotEmpty) {
        print('payload $payload');

        Navigator.push(
            GlobalContextService.navigatorKey.currentState!.context,
            MaterialPageRoute(
                builder: ((context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload))));
      }
    }

    bool success = false;
    for (int i = 0; i < 15; i++) {
      final requests = await FirebaseFirestore.instance
          .collection("requests")
          .where('notificationStatus', isEqualTo: 'pending')
          .get()
          .then((event) async {
        final requests = [];

        for (var doc in event.docs) {
          int notificationID = Random().nextInt(100);
          requests.add(doc.data()["description"]);
          print('${doc.data()["description"]}');
          notificationService.showLocalNotification(
              id: notificationID,
              title: 'Someone Needs Awn!',
              body: 'New Awn request: ${doc.data()["description"]}',
              payload: doc.data()["docId"]);
          await doc.reference.update({
            'notificationStatus': 'sent',
          });
        }
        if (kDebugMode) {
          print("pending requests: ${requests.join(", ")}");
        }
        var test =
            await Future.delayed(const Duration(milliseconds: 60000), () async {
          if (kDebugMode) {
            print("test2");
          }
        });
      });
      success = true;
    }

    return Future.value(success);
  });
}

class NotificationService {
  NotificationService();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onSelectNotification: selectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('1', 'awn requests',
            channelDescription: 'awn requests added',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
      print(payload);
    }
  }
}
