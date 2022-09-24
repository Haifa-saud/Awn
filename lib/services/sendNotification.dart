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
void onDidReceiveNotificationResponse(NotificationResponse nr) async {
  // display a dialog with the notification details, tap ok to go to another page
  //  Navigator.pushNamed(context, '/volunteerPage');
  Navigator.push(GlobalContextService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const viewRequests()));
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    print('test');

    // var ds = (await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .get()).data() as Map<String, dynamic>;
    // Map<String, dynamic> userData = ds.data() as Map<String, dynamic>;
    // print(userData);
    // print(userData['Type']);

    FlutterLocalNotificationsPlugin notification =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await notification.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveNotificationResponse);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'awn requests',
            channelDescription: 'awn requests added',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);

    var platformChannelSpecifics =
        const NotificationDetails(android: androidNotificationDetails);

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
        doc.reference.update({
          'notificationStatus': 'sent',
        });
      }
      print("pending requests: ${requests.join(", ")}");
    });

    return Future.value(true);
  });
}
