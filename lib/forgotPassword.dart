// ignore_for_file: camel_case_types

import 'package:Awn/login.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/Utils.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({Key? key}) : super(key: key);

  @override
  _forgotPasswordState createState() => _forgotPasswordState();
}

final formKey = GlobalKey<FormState>();

class _forgotPasswordState extends State<forgotPassword> {
  final emailController = TextEditingController();
  bool invalidEmail = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  final Storage storage = Storage();
  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        invalidEmail = false;
      });
      emailController.text = '';
      print('Email sent');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => login(),
          ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('The reset password email is sent successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      // Utils.showSnackBar(e.message);
      setState(() {
        invalidEmail = true;
      });
      print('incatch');

      print(e.message);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue.shade800),
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => login(),
              )),
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [
        //   Colors.cyanAccent.shade100,
        //   Colors.white54,
        //   Colors.white54,
        //   Colors.blue.shade200
        // ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(
                  height: height * 0.2,
                ),
                FutureBuilder(
                    future: storage.downloadURL('logo.jpg'),
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
                Text(
                  "Forgot Password?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Please enter your email to receive an email to reset your password.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    )),
                SizedBox(
                  height: height * 0.04,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
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
                    if (email != null && !EmailValidator.validate(email) ||
                        (email!.trim()).isEmpty) {
                      return "Invalid email, please try again.";
                    } else if (invalidEmail) {
                      return "Invalid email, please try again.";
                    }
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Container(
                  // margin: const EdgeInsets.fromLTRB(0, 60, 0, 10),
                  // margin: const EdgeInsets.fromLTRB(, 0, 10, 0),

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
                  child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        minimumSize:
                            MaterialStateProperty.all(const Size(450, 50)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                            fontSize: 18,
                            // fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          resetPassword();
                        }
                      }),
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
