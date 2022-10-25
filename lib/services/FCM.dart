import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'newRequestNotification.dart';

// class FCM {
//   late FirebaseMessaging messaging;

//   /// Create a [AndroidNotificationChannel] for heads up notifications
//   late AndroidNotificationChannel channel;

//   /// Initialize the [FlutterLocalNotificationsPlugin] package.
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   Future initApp() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     messaging = FirebaseMessaging.instance;

//     channel = const AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       importance: Importance.high,
//     );

//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     /// Create an Android Notification Channel.
//     ///
//     /// We use this channel in the `AndroidManifest.xml` file to override the
//     /// default FCM channel to enable heads up notifications.
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   Future subscripeToTopics(String topic) async {
//     await messaging.subscribeToTopic(topic);
//   }

//   ///Expire : https://firebase.google.com/docs/cloud-messaging/manage-tokens
//   // Future<String?> getFCMToken() async {
//   //   final fcmToken = await messaging.getToken();
//   //   return fcmToken;
//   // }

//   // void tokenListener() {
//   //   messaging.onTokenRefresh.listen((fcmToken) {
//   //     print("FCM Token dinlemede");
//   //     // TODO: If necessary send token to application server.
//   //   }).onError((err) {
//   //     print(err);
//   //   });
//   // }

//   ///Foreground messages
//   ///
//   ///To handle messages while your application is in the foreground, listen to the onMessage stream.
//   void foreGroundMessageListener() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null && !kIsWeb) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               channelDescription: channel.description,
//               importance: Importance.max,
//               priority: Priority.high,
//               ticker: 'ticker',
//               icon: "@mipmap/ic_launcher",
//             ),
//           ),
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//     });
//   }
// }

class RequestAcceptanceNotification {
  final NotificationService notificationService = NotificationService();

  Future initApp() async {
    notificationService.initializePlatformNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage");
      var Title = message.notification!.title == null
          ? 'no data'
          : message.notification!.title;
      var Body = message.notification!.body == null
          ? 'no data'
          : message.notification!.body;
      notificationService.showLocalNotification(
          id: 0, title: Title!, body: Body!, payload: 'payload');
    });
  }
}
