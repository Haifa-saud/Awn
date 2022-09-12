import 'package:awn/addPost.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appTheme.dart';
import 'firebase_options.dart';
import 'package:awn/map.dart';

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
        '/homePage': (context) => const MyHomePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.transparent,
          // iconTheme: IconThemeData(color: Colors.black),
          foregroundColor: AppTheme.darkerText,
        ),
        textTheme: const TextTheme(
          // headline1: TextStyle(fontSize: 100.0), //cant find where it is used
          headline6: TextStyle(fontSize: 30.0), //header at the app bar
          bodyText2: TextStyle(fontSize: 20.0), //the body text
          subtitle1: TextStyle(fontSize: 19.0), //the text field label
          subtitle2: TextStyle(fontSize: 120.0), //the text field

          button: TextStyle(fontSize: 18), //the button text
        ).apply(
          bodyColor: AppTheme.darkerText,
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
          // margin: EdgeInsets.all(10),
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
            MaterialPageRoute(builder: (context) => addPost()),
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
    );
  }

  // FutureBuilder<String> addImage() {
  //   return new FutureBuilder<String>(
  //     future: loadBackground(),
  //     builder: (BuildContext context, AsyncSnapshot<String> image) {
  //       if (image.hasData) {
  //         return Image.network(image.data.toString()); // image is ready
  //         //return Text('data');
  //       } else {
  //         return new Container(); // placeholder
  //       }
  //     },
  //   );
  // }

  // Future<String> loadBackground() async {
  //   Reference ref = FirebaseStorage.instance
  //       .ref()
  //       .child("background.png"); //.child(_file_name[0]);

  //   //get image url from firebase storage
  //   var url = await ref.getDownloadURL();
  //   print('url: ' + url);
  //   return url;
  // }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Choose your',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                Text(
                  'Design Course',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: AppTheme.darkerText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            child: Image.asset('assets/design_course/userImage.png'),
          )
        ],
      ),
    );
  }
}
