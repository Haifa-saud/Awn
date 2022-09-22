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
  print("test0");

  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    print("test1");

    // FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
    // var android = new AndroidInitializationSettings('@mipmap/ic_launcher');

    // var settings = new InitializationSettings(android: android);
    // // flip.initialize(settings, onSelectNotification: (String? payload) async {
    // //   await NavigationService.navigatorKey.currentState!
    // //       .push(MaterialPageRoute(builder: (context) => homePage()));
    // // });

    // var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    //     '1', 'weather station',
    //     importance: Importance.max, priority: Priority.high);

    // var platformChannelSpecifics =
    //     NotificationDetails(android: androidPlatformChannelSpecifics);
    // print("test2");

    // // await flip.show(0, 'message', 'App', platformChannelSpecifics,
    // //     payload: 'Default_Sound');

    // int notificationID = Random().nextInt(100);

    final requests = await FirebaseFirestore.instance
        .collection("requests")
        .where('notificationStatus', isEqualTo: 'pending')
        // .snapshots()
        .get()
        .then((event) async {
      final requests = [];
      print("test3");

      for (var doc in event.docs) {
        requests.add(doc.data()["description"]);
        // await flip.show(notificationID, 'Awn Request',
        //     doc.data()["description"], platformChannelSpecifics,
        //     payload: 'Default_Sound');
        doc.reference.update({
          'notificationStatus': 'sent',
        });
      }
      print("pending requests: ${requests.join(", ")}");
    });

    return Future.value(true);
  });
}
