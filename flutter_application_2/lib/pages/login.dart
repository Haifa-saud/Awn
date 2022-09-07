import 'package:flutter/material.dart';
import 'package:flutter_application_2/registration_login_colors.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Key _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.04,
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Enter your Email"),
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return "please enter a valid e-mail address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Enter password"),
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return "please enter your password";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Row()
                ],
              ),
            )));
  }
}
