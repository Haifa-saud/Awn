import 'package:awn/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'myGlobal.dart' as globals;

class Role extends StatefulWidget {
  const Role(String userType, {Key? key}) : super(key: key);

  @override
  _RoleState createState() => _RoleState();
}

class _RoleState extends State<Role> {
  getType() async {
    dynamic name = await getUsersList();

    globals.userType = name;
  }

  @override
  Widget build(BuildContext context) =>
      globals.userType == 'Volunteer' ? homePage() : homePage();

  static String userType = "";
  static final userCollection = FirebaseFirestore.instance.collection('users');

  static getUsersList() async {
    final firebaseUser = FirebaseAuth.instance.currentUser();
    try {
      DocumentSnapshot ds = await userCollection.doc(firebaseUser!.uid).get();
      userType = ds.get('Type');
      return userType;
    } catch (e) {
      print(e.toString());
      return "null";
    }
  }

  // static getType() async {
  //   dynamic name = await getUsersList();

  //   globals.userType = name;
  // }

  String getType2() {
    getType();
    String type;
    globals.userType = getType();
    return globals.userType;
  }

  void Role() {
    getType();

    if (getType2() == 'Volunteer') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => homePage()));
    } else if (getType2() == 'Special Need User') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => homePage()));
    }
  }
}
