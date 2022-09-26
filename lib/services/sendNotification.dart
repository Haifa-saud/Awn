import 'dart:math';
import 'package:awn/homePage.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awn/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';

const task = 'firstTask';
// @pragma('vm:entry-point')
// void onDidReceiveNotificationResponse(NotificationResponse nr) async {
//   Navigator.push(GlobalContextService.navigatorKey.currentContext!,
//       MaterialPageRoute(builder: (context) => const viewRequests()));
// }

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    // print('test');

    print("test01");

    FlutterLocalNotificationsPlugin notification =
        FlutterLocalNotificationsPlugin();
    print("test02");

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await notification.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse:
      //     onDidReceiveNotificationResponse
    );
    print("test03");

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'awn requests',
            channelDescription: 'awn requests added',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);

    var platformChannelSpecifics =
        const NotificationDetails(android: androidNotificationDetails);
    print("test04");
    bool success = false;
    for (int i = 0; i < 15; i++) {
      print("test1");

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
          notification.show(
              notificationID,
              'Someone Needs Awn!',
              'New Awn request: ${doc.data()["description"]}',
              platformChannelSpecifics,
              payload: 'Default_Sound');
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
