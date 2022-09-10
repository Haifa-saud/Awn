import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

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
      title: 'Home Page',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF39d6ce),
        ),
        textTheme:
            const TextTheme(headline2: TextStyle(color: Color(0xFF2a3563))),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
              // borderSide: BorderSide(width: 3, color: Color(0xFF39d6ce)),
              ),
          focusedBorder: OutlineInputBorder(
              // borderSide: BorderSide(width: 3, color: Color(0xFF2a3563)),
              ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              textStyle: TextStyle(fontSize: 15),
              backgroundColor: Color(0xFF39d6ce), // background (button) color
              foregroundColor: Color(0xFFfcfffe),
              padding: EdgeInsets.all(5),
              fixedSize: const Size(10.0, 40.0),
              side: BorderSide(
                  width: 2,
                  color: Color(0xFF39d6ce)), // foreground (text) color
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awn'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You are in the home page',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => const addPost()),
              // MaterialPageRoute(builder: (context) => const addRequest()),
              MaterialPageRoute(builder: (context) => const viewRequests()));
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
