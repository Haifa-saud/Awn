import 'package:awn/adminPage.dart';
import 'package:awn/homePage.dart';
import 'package:awn/login.dart';
import 'package:awn/register.dart';
import 'package:awn/viewRequests.dart';
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
    var Payload = notificationAppLaunchDetails.payload;
    runApp(MyApp(true, true, Payload!));
  } else {
    runApp(MyApp(true, false));
  }
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      Workmanager().cancelAll();
      runApp(MyApp(false));
    } else {
      //! haifa
      if (notificationAppLaunchDetails.didNotificationLaunchApp) {
        var Payload = notificationAppLaunchDetails.payload;
        runApp(MyApp(true, true, Payload!, false));
      } else if (user.uid == 'GvQo5Qz5ZnTfQYq5GOhZi22HGCB2') {
        runApp(MyApp(true, false, '', true));
      } else {
        runApp(MyApp(true, false, '', false));
      }
    }
  });
}

class MyApp extends StatefulWidget {
  MyApp(
      [this.auth = false,
      this.notification = false,
      this.payload = '',
      this.isAdmin = false]);

  bool auth;
  bool notification;
  String payload;
  bool isAdmin;

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/homePage': (ctx) => const homePage(),
        '/volunteerPage': (ctx) => const homePage(),
        "/register": (ctx) => const register(),
        "/login": (ctx) => const login(),
        "/adminPage": (ctx) => const adminPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      navigatorKey: GlobalContextService.navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              wordSpacing: 3,
              letterSpacing: 1,
              color: const Color(0xFF06283D),
              fontSize: 22,
              fontWeight: FontWeight.w700),
          scrolledUnderElevation: 1,
          centerTitle: false,
          elevation: 0,
          color: Colors.white, // Colors.transparent,
          foregroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(
              wordSpacing: 3,
              letterSpacing: 1,
              fontSize: 22.0,
              color: const Color(0xFF06283D)), //header at the app bar
          bodyText2: TextStyle(
              wordSpacing: 3,
              color: const Color(0xFF06283D),
              letterSpacing: 1,
              fontSize: 20.0,
              fontWeight: FontWeight.bold), //the body text
          subtitle1: TextStyle(
              wordSpacing: 3,
              color: const Color(0xFF06283D),
              letterSpacing: 1,
              fontSize: 18.0), //the text field label
          // subtitle2: TextStyle(
          //     wordSpacing: 3,
          //     letterSpacing: 1,
          //     fontSize: 120.0), //the text field

          button: TextStyle(
            wordSpacing: 3,
            letterSpacing: 1,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ), //the button text
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
          backgroundColor: Colors.blue, //Color(0xFF39d6ce),
          actionTextColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 1,
          contentTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      home: widget.auth
          ? (widget.notification
              ? viewRequests(userType: 'Volunteer', reqID: widget.payload)
              : (widget.isAdmin ? const adminPage() : const homePage()))
          : const login(),
    );
  }
}

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
