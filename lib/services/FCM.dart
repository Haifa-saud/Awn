// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class pushNotification extends StatefulWidget {
//   @override
//   pushNotificationState createState() => pushNotificationState();
// }

// class pushNotificationState extends State<pushNotification> {
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

//   @override
//   void initState(){
//     super.initState();
//     firebaseMessaging.configure(

//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String token = '';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    super.initState();
  }

  void getToken() async {
    token = (await firebaseMessaging.getToken())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Token : $token")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(token);
        },
        child: Icon(Icons.print),
      ),
    );
  }
}
