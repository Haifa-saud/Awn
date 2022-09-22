import 'package:awn/Utils.dart';
import 'package:awn/authentication.dart';
import 'package:awn/homePage.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:awn/login.dart';

import 'package:awn/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;
import 'notification.dart';
import 'package:awn/notification/registerNotification.dart';

// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) {
//     switch (taskName) {
//       case 'firstTask':
//         sendData();
//         break;
//     }
//     return Future.value(true);
//   });
// }
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     FlutterLocalNotificationsPlugin flip =
//          FlutterLocalNotificationsPlugin();
//     var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     var settings = InitializationSettings(android: android);
//     flip.initialize(settings);
//     _showNotificationWithDefaultSound(flip);
//     return Future.value(true);
//   });
// }
// Future _showNotificationWithDefaultSound(flip) async {
//   // Show a notification after every 15 minute with the first
//   // appearance happening a minute after invoking the method
//   var androidPlatformChannelSpecifics =
//       const AndroidNotificationDetails('your channel id', 'your channel name',
//           importance: Importance.max,
//           priority: Priority.high);
//   var platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//   );
//   await flip.show(
//       0,
//       'Geeks fo rGeeks',
//       'Your are one step away to connect with GeeksforGeeks',
//       platformChannelSpecifics,
//       payload: 'Default_Sound');
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  WidgetsFlutterBinding.ensureInitialized();

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  var time = DateTime.now().second.toString();
  await Workmanager()
      .registerPeriodicTask(time, 'firstTask', frequency: Duration(minutes: 1));

  // FlutterLocalNotificationsPlugin notifications =
  //     FlutterLocalNotificationsPlugin();
  // AndroidInitializationSettings androidInit =
  //     AndroidInitializationSettings('ic_launcher.png');
  // // var iOSInit =  IOSInitializationSettings();
  // var initSettings = InitializationSettings(android: androidInit); //, iOSInit);
  // notifications.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Color(0xFF39d6ce), // Colors.transparent,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(
              fontSize: 22.0, color: Colors.black), //header at the app bar
          bodyText2: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold), //the body text
          subtitle1: TextStyle(fontSize: 19.0), //the text field label
          subtitle2: TextStyle(fontSize: 120.0), //the text field

          button: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.underline), //the button text
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0)),
          floatingLabelStyle: const TextStyle(fontSize: 22, color: Colors.blue),
          helperStyle: const TextStyle(fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // background (button) color
              foregroundColor: const Color(0xFFfcfffe),
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF39d6ce),
          actionTextColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 1,
          contentTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot != null) {
          UserHelper.saveUser(snapshot.data);
          final user = snapshot.data;
          return const homePage();
        } else {
          return const AuthenticationPage();
        }
      },
    );
  }
}
