import 'dart:math';
import 'package:awn/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';

const task = 'firstTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    FlutterLocalNotificationsPlugin notification =
        FlutterLocalNotificationsPlugin();

    int channelId = 0;
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'awn requests',
            channelDescription: 'awn requests added',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);
    var platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    final requests = await FirebaseFirestore.instance
        .collection("requests")
        .where('notificationStatus', isEqualTo: 'pending')
        .get()
        .then((event) async {
      final requests = [];
      print("test3");

      for (var doc in event.docs) {
        int notificationID = Random().nextInt(100);
        requests.add(doc.data()["description"]);
        print('${doc.data()["description"]}');
        notification.show(notificationID, 'Awn Request',
            doc.data()["description"], platformChannelSpecifics,
            payload: 'Default_Sound');
        doc.reference.update({
          'notificationStatus': 'sent',
        });
      }
      print("pending requests: ${requests.join(", ")}");
    });

    return Future.value(true);
  });
}
