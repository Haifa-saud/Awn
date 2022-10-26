// import 'package:Awn/main.dart';
// import 'package:Awn/viewRequests.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/subjects.dart';
// import '../requestWidget.dart';

// class NotificationService {
//   NotificationService();
//   final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

//   final _localNotifications = FlutterLocalNotificationsPlugin();
//   Future<void> initializePlatformNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await _localNotifications.initialize(
//       initializationSettings,
//       onSelectNotification: selectNotification,
//     );
//   }

//   Future<NotificationDetails> _notificationDetails() async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         const AndroidNotificationDetails('1', 'awn',
//             channelDescription: 'awn',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true);

//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     return platformChannelSpecifics;
//   }

//   Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     required String payload,
//   }) async {
//     final platformChannelSpecifics = await _notificationDetails();
//     await _localNotifications.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }

//   void selectNotification(String? payload) {
//     if (payload != null && payload.isNotEmpty) {
//       behaviorSubject.add(payload);
//     }
//   }
// }


