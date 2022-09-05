import 'package:awn/addPost.dart';
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
        scaffoldBackgroundColor: Color(0xFFecfbfa),
        appBarTheme: const AppBarTheme(
          // iconTheme: IconThemeData(color: Colors.black),
          color: Color(0xFF39d6ce),
        ),
        textTheme:
            const TextTheme(headline2: TextStyle(color: Color(0xFF2a3563))),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 3, color: Color(0xFF39d6ce)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 3, color: Color(0xFF2a3563)),
          ),
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
        title: Text('عون'),
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
            MaterialPageRoute(builder: (context) => const addPost()),
          );
        },
        // onPressed: addUser,
        tooltip: 'أضف منشور',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// database test
//CollectionReference users = FirebaseFirestore.instance.collection('users');

// Future<void> addUser() async {
//   // Call the user's CollectionReference to add a new user
//   await users.add({
//     'full_name': 'fullName', // John Doe
//     'company': 'company', // Stokes and Sons
//     'age': 'age' // 42
//   }).then((value) => print("User Added"));
//   // .catchError((error) => print("Failed to add user: $error"));
// }
