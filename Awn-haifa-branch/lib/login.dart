import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'forgotPassword.dart';
import 'main.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class _loginState extends State<login> {
  Key _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            //hexStringToColor("#00dacf"),
            //hexStringToColor("#fcfffd"),
            Colors.cyanAccent.shade100,

            // hexStringToColor("#fcfffd"),
            //hexStringToColor("#fcfffd"),
            //hexStringToColor("#fcfffd"),
            Colors.white54,
            Colors.white54,
            //hexStringToColor("#fcfffd"),
            //hexStringToColor("#283466")
            Colors.blue.shade200
          ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * 0.2,
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 95, 94, 94)),
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Email",
                    hintText: "Email",
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.grey.shade400)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "please enter a valid Email address";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    hintText: "Password",
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.grey.shade400)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "please enter your Password";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => forgotPassword()),
                      );
                    },
                    child: Text(
                      "forgot password?",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(70, 10, 50, 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.blue,
                        Colors.cyanAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(50, 50)),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      //After successful login we will redirect to profile page. Let's create profile page now
                      // Navigator.pushReplacement(
                      // context,
                      // MaterialPageRoute(
                      //  builder: (context) => ProfilePage()));
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(50, 10, 50, 10),
                  //child: Text('Don\'t have an account? Create'),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: "Don\'t have an account? "),
                    TextSpan(
                      text: 'Create',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigator.push(
                          //  context,
                          //  MaterialPageRoute(
                          //    builder: (context) =>
                          //     RegistrationPage()));
                        },
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor),
                    ),
                  ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
