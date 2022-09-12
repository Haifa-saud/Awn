import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file.dart';
import 'firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;

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
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      routes: {
        '/homePage': (context) => MyHomePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.transparent,
          // iconTheme: IconThemeData(color: Colors.black),
          foregroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          // headline1: TextStyle(fontSize: 100.0), //cant find where it is used
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
        ).apply(
          // bodyColor: AppTheme.darkerText,
          displayColor: Colors.blue,
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
              // textStyle: TextStyle(fontSize: 15),
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _onItemTapped(int index) async {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addRequest()),
        );
      } else if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addPost()),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Awn'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Add Post'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addFile()),
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Add Post'),
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.yellow,
              onPressed: () {
                //Do whatever you want
              },
            ),
          ));
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text("Add Post"),
            activeIcon: Text("Add Post"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Awn Request"),
            activeIcon: Text("Add Request"),
            label: '',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;
}
