import 'package:awn/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
//import 'forgotPassword.dart';
import 'main.dart';

class login extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const login({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class _loginState extends State<login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;
  void initState() {
    _passwordVisible = false;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
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
                  controller: emailController,
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    value != null && value.length < 8
                        ? 'Enter a valid password'
                        : null;
                  },
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    value != null && value.length < 8
                        ? 'Enter a valid password'
                        : null;
                  },
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => forgotPassword()),
                    //   );
                   // },
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
                    onPressed: signIn,
                    /*() {
                      //After successful login we will redirect to profile page. Let's create profile page now
                      
                    },*/
                    // Navigator.pushReplacement(
                    // context,
                    // MaterialPageRoute(
                    //  builder: (context) => ProfilePage()));
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(50, 10, 50, 10),
                  //child: Text('Don\'t have an account? Create'),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: "Don\'t have an account? "),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Create',

                      // Navigator.push(
                      //  context,
                      //  MaterialPageRoute(
                      //    builder: (context) =>
                      //     RegistrationPage()));

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

  final dbRef = FirebaseDatabase.instance.ref().child("users");
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future signIn() async {
    final newUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    /*if (newUser != null) {
      //print("success");
      var user = auth.currentUser;
      final userID = user!.uid;
      await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userID)
          .once()
          .then((DatabaseEvent event) {
        final DataSnapshot dataSnapshot = event.snapshot;
        String value = dataSnapshot.value;
        if (value != null) {
          setState(() {
            if (dataSnapshot.value['Type'] == 'Volunteer') {
            } else if (dataSnapshot.value['Spicial need user']) {}
          });
        }
      });
    } else {
      print("fail");
    }*/
  }
}