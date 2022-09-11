import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'appTheme.dart';

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
        // scaffoldBackgroundColor: Color(0xFFfcfffe)
        scaffoldBackgroundColor: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.transparent,
          // iconTheme: IconThemeData(color: Colors.black),
          foregroundColor: AppTheme.darkerText,
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: AppTheme.darkerText,
          displayColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide(color: Colors.grey.shade400)),
            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide(color: Color(0xFF39d6ce))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide(color: Colors.red, width: 2.0)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide(color: Colors.red, width: 2.0))),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              textStyle: TextStyle(fontSize: 15),
              backgroundColor: Colors.black, // background (button) color
              foregroundColor: Color(0xFFfcfffe),
              shadowColor: Colors.transparent,
              padding: EdgeInsets.all(5),
              // minimumSize: Size(0, 50),

              // side: BorderSide(
              //     width: 2,
              //     color: Color(0xFF39d6ce)), // foreground (text) color
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
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
          children: <Widget>[
            Text(
              '',
            ),
            Container(
                width: 200,
                // margin: EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => const addPost()),
                          MaterialPageRoute(
                              builder: (context) => const addRequest()));
                    },
                    child: Text('Add Request'))),
            Container(
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => const addPost()),
                          MaterialPageRoute(
                              builder: (context) => const viewRequests()));
                    },
                    child: Text('view Requests'))),
            Container(
                width: 200,
                margin: EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => const addPost()),
                          MaterialPageRoute(
                              builder: (context) => const addPost()));
                    },
                    child: Text('Add Post'))),
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
