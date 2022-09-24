import 'package:awn/authentication.dart';
import 'package:awn/homePage.dart';

import 'package:awn/login.dart';

import 'package:awn/register.dart';
import 'package:awn/volunteerPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'RolePage.dart';
import 'User-profile.dart';
import 'firebase_options.dart';
import 'myGlobal.dart' as globals;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // '/': (ctx) => MyApp(),
        '/homePage': (ctx) => homePage(),
        '/volunteerPage': (ctx) => volunteerPage(),
        "/register": (ctx) => register(),
        "/login": (ctx) => login(),
        '/ProfilePage': (ctx) => ProfilePage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      /* routes: {
        '/homePage': (context) => homePage(),
      },*/
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfcfffe),
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
          contentPadding: EdgeInsets.fromLTRB(20, 12, 20, 12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.red, width: 2.0)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.red, width: 2.0)),
          floatingLabelStyle: TextStyle(fontSize: 22, color: Colors.blue),
          helperStyle: TextStyle(fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // background (button) color
              foregroundColor: Color(0xFFfcfffe),
              shadowColor: Colors.transparent,
              padding: EdgeInsets.all(5),
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
      home: login(),
    );
  }
}

// class MainPage extends StatefulWidget {
//   const MainPage({Key? key}) : super(key: key);
//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData && snapshot != null) {
//           UserHelper.saveUser(snapshot.data);

//           // Navigator.push(
//           //     context, MaterialPageRoute(builder: (context) => homePage()));

//           return homePage();
//         }

//         //Utils.showSnackBar("wrong email//password");
//         return AuthenticationPage();
//       },
//     );
//   }

//   static String userType = "";
//   static final userCollection = FirebaseFirestore.instance.collection('users');

//   static getUsersList() async {
//     final firebaseUser = FirebaseAuth.instance.currentUser;
//     try {
//       DocumentSnapshot ds = await userCollection.doc(firebaseUser!.uid).get();
//       userType = ds.get('Type');
//       return userType;
//     } catch (e) {
//       print(e.toString());
//       return "null";
//     }
//   }

//   static getType() async {
//     dynamic name = await getUsersList();

//     userType = name;
//   }

//   String getType2() {
//     String type;
//     dynamic name = getType();
//     type = name;
//     return type;
//   }
// }
