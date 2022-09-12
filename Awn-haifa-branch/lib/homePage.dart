import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 60, 50, 10),
      child: ElevatedButton(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Text(
            'Sign Out',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        onPressed: () {
          //After successful login we will redirect to profile page. Let's create profile page now

          FirebaseAuth.instance.signOut();

          // Navigator.pushReplacement(
          // context,
          // MaterialPageRoute(
          //  builder: (context) => ProfilePage()));
        },
      ),
    );
  }
}
