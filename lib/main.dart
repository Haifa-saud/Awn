import 'package:Awn/adminPage.dart';
import 'package:Awn/homePage.dart';
import 'package:Awn/login.dart';
import 'package:Awn/register.dart';
import 'package:Awn/requestWidget.dart';
import 'package:Awn/services/FCM.dart';
import 'package:Awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'chatPage.dart';
import 'services/firebase_options.dart';
import 'package:hive/hive.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('handling message in background');
}

late Box box;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  box = await Hive.openBox('currentPage');
  //! Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // final user = FirebaseAuth.instance.currentUser!.uid;

  //! FCM
  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    print("New token: $token");
    if (FirebaseAuth.instance.currentUser!.uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
    }
  });
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  //! Local Notifications
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  var notificationAppLaunchDetails =
      await notification.getNotificationAppLaunchDetails();

  // if (notificationAppLaunchDetails!.didNotificationLaunchApp) {
  //   var Payload = notificationAppLaunchDetails.payload;
  //   runApp(MyApp(
  //       auth: true, notification: true, payload: Payload!, isAdmin: false));
  // }

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    bool auth = false, notificationB = false, isAdmin = false;
    String payloadRun = '';
    if (user == null) {
      Workmanager().cancelAll();
      auth = false;
      notificationB = false;
      payloadRun = "";
      isAdmin = false;
    } else {
      if (notificationAppLaunchDetails!.didNotificationLaunchApp) {
        payloadRun = notificationAppLaunchDetails.payload!;
        auth = true;
        notificationB = true;
        isAdmin = false;
      } else if (user.uid == 'GvQo5Qz5ZnTfQYq5GOhZi22HGCB2') {
        auth = true;
        notificationB = false;
        payloadRun = "";
        isAdmin = true;
      } else {
        auth = true;
        notificationB = false;
        payloadRun = "";
        isAdmin = false;
      }
    }
    runApp(MyApp(
        auth: auth,
        notification: notificationB,
        payload: payloadRun,
        isAdmin: isAdmin));
  });
}

class MyApp extends StatefulWidget {
  final bool auth;
  final bool isAdmin;
  final bool notification;
  final String payload;

  MyApp(
      {required this.auth,
      required this.notification,
      required this.payload,
      required this.isAdmin});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // print(widget.auth);
  @override
  Widget build(BuildContext context) {
    print(widget.auth);
    return MaterialApp(
      routes: {
        '/homePage': (ctx) => const homePage(),
        '/volunteerPage': (ctx) => const homePage(),
        "/register": (ctx) => const register(),
        "/login": (ctx) => const login(),
        "/adminPage": (ctx) => const AdminPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      navigatorKey: GlobalContextService.navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfcfffe),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
              wordSpacing: 3,
              letterSpacing: 1,
              color: Colors.blue.shade900, //const Color(0xFF06283D),
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
              color: Colors
                  .blue), //const Color(0xFF06283D)), //header at the app bar
          bodyText2: TextStyle(
              wordSpacing: 3,
              color: Color.fromARGB(255, 0, 40, 100), //const Color(0xFF06283D),
              letterSpacing: 1,
              fontSize: 20.0,
              fontWeight: FontWeight.bold), //the body text
          subtitle1: TextStyle(
              wordSpacing: 3,
              color: Color(0xFF06283D),
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
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFFfcfffe),
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.blue,
          actionTextColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 1,
          contentTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      home: widget.auth
          ? (widget.notification
              ? viewRequests(userType: 'Volunteer', reqID: widget.payload)
              : (widget.isAdmin ? const AdminPage() : const homePage()))
          : const login(),
    );
  }
}

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
