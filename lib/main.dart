import 'package:awn/homePage.dart';
import 'package:awn/login.dart';
import 'package:awn/register.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  var notificationAppLaunchDetails =
      await notification.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails!.didNotificationLaunchApp) {
    runApp(MyApp(true, true));
  } else {
    runApp(MyApp(true, false));
  }
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      Workmanager().cancelAll();
      runApp(MyApp(false));
    } else {
      if (notificationAppLaunchDetails.didNotificationLaunchApp) {
        runApp(MyApp(true, true));
      } else {
        runApp(MyApp(true, false));
      }
    }
  });
}

class MyApp extends StatefulWidget {
  bool auth;
  bool notification;
  MyApp([this.auth = false, this.notification = false]);
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/homePage': (ctx) => const homePage(userType: 'Special Need User'),
        '/volunteerPage': (ctx) => const homePage(userType: 'Volunteer'),
        "/register": (ctx) => const register(),
        "/login": (ctx) => const login(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      navigatorKey: GlobalContextService.navigatorKey,
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
      home: widget.auth
          ? (widget.notification
              ? const viewRequests()
              : const homePage(
                  userType: 'Volunteer',
                ))
          : login(),
    );
  }
}

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
