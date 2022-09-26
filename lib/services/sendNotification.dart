import 'dart:math';
import 'package:awn/homePage.dart';
import 'package:awn/main.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awn/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

const task = 'firstTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    late final LocalNotification service = LocalNotification();

    void onNoticationListener(String? payload) async{
      if (payload != null && payload.isNotEmpty) {
        print('payload $payload');

        Navigator.push(GlobalContextService.navigatorKey.currentState!.context,
            MaterialPageRoute(builder: ((context) => viewRequests())));
      }
    }

    void listenToNotification() =>
        service.onNotificationClick.stream.listen(onNoticationListener);

    listenToNotification();
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
          service.showNotification(
              id: notificationID,
              title: 'Someone Needs Awn!',
              body: 'New Awn request: ${doc.data()["description"]}');
          // platformChannelSpecifics,
          // payload: doc.id);
          await doc.reference.update({
            'notificationStatus': 'sent',
          });
        }
        print("pending requests: ${requests.join(", ")}");
        var test =
            await Future.delayed(Duration(milliseconds: 60000), () async {
          // Do something
          print("test2");
        });
      });
      success = true;
    }

    return Future.value(success);
  });
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {
  print('id $id');
}

class LocalNotification {
  LocalNotification();

  final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> intialize() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notification.initialize(initializationSettings,
        // onSelectNotification: onSelectNotification,

        // onDidReceiveBackgroundNotificationResponse:
        //     onDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'awn requests',
            channelDescription: 'awn requests added',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);

    return const NotificationDetails(android: androidNotificationDetails);
  }

  // var platformChannelSpecifics =
  //     const NotificationDetails(android: androidNotificationDetails);

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await notification.show(id, title, body, details);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onSelectNotification(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    print('payload $payload');
    if (payload != null && payload.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }
}
