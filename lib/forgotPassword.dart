// ignore_for_file: camel_case_types

import 'package:awn/login.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'Utils.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({Key? key}) : super(key: key);

  @override
  _forgotPasswordState createState() => _forgotPasswordState();
}

final formKey = GlobalKey<FormState>();

class _forgotPasswordState extends State<forgotPassword> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  final Storage storage = Storage();
  Future resetPassword() async {
    try {
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Utils.showSnackBar("Email sent");
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }
  }

  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
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
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Center(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height * 0.1,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                    ),
                    onTap: () {
                      //action code when clicked
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => MainPage(),
                            builder: (context) => login(),
                          ));
                    },
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                FutureBuilder(
                    future: storage.downloadURL('logo.png'),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Center(
                          //width: 100,
                          // height: 100,
                          child: Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return CircularProgressIndicator(
                          color: Colors.grey.shade200,
                        );
                      }
                      return Container();
                    }),
                SizedBox(
                  height: height * 0.05,
                ),
                const Text(
                  "Recieve an email to reset your password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 95, 94, 94),
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
                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: const BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.grey.shade400)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.0)),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) {
                    if (email != null && !EmailValidator.validate(email)) {
                      return "Enter a valid email";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 0.01,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: const LinearGradient(
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
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        minimumSize:
                            MaterialStateProperty.all(const Size(50, 50)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onPressed: () {
                        resetPassword();
                      }

                      //After successful login we will redirect to profile page. Let's create profile page now

                      // Navigator.pushReplacement(
                      // context,
                      // MaterialPageRoute(
                      //  builder: (context) => ProfilePage()));
                      ),
                ),
              ],
              // Navigator.pushReplacement(
              // context,
              // MaterialPageRoute(
              //  builder: (context) => ProfilePage()));
            ),
          ),
        ),
      ),
    );
  }
}
