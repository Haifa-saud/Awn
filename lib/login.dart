import 'package:Awn/services/Utils.dart';
import 'package:Awn/register.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/services/usersModel.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workmanager/workmanager.dart';
import 'forgotPassword.dart';
import 'services/myGlobal.dart' as globals;

class login extends StatefulWidget {
  const login({
    Key? key,
  }) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

bool isVolunteer = false;
String VolunteerId = '';
var myList = [];

class _loginState extends State<login> {
  // final user = FirebaseAuth.instance.currentUser!.uid;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool invalidData = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    invalidData = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    invalidData = false;

    super.dispose();
  }

  final dbRef = FirebaseDatabase.instance.ref().child("users");
  final FirebaseAuth auth = FirebaseAuth.instance;

  final Storage storage = Storage();
  Stream<List<usersModel>> readVolunteer() => FirebaseFirestore.instance
      .collection('users')
      .where("Type", isEqualTo: "Volunteer")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => usersModel.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [
        //   Colors.cyanAccent.shade100,
        //   Colors.white,
        //   Colors.white,
        //   Colors.blue.shade200
        // ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.2,
                    ),
                    FutureBuilder(
                        future: storage.downloadURL('logo.jpg'),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Center(
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.grey.shade200,
                            ));
                          }
                          return Container();
                        }),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    StreamBuilder<List<usersModel>>(
                      stream: readVolunteer(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text(
                              'Something went wrong! ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final AllshopOwners = snapshot.data!.toList();
                          for (int i = 0; i < AllshopOwners.length; i++) {
                            myList.add(AllshopOwners[i].id);
                          }
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return const Text('');
                      },
                    ),
                    Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Email",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email != null && (email.trim()).isEmpty) {
                          return "Please enter an email.";
                        }
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email != null && (email.trim()).isEmpty) {
                          return "Please enter a password.";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
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
                            // Update the state i.e. toggle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: const BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: const BorderSide(
                                color: Colors.red, width: 2.0)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: const BorderSide(
                                color: Colors.red, width: 2.0)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const forgotPassword()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.underline,
                              fontSize: 15),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: invalidData,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              'Invalid Email/Password, please try again.',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal)),
                        )),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Center(
                        child: Container(
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
                            Color(0xFF2196F3),
                            Colors.cyanAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                            'Login',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                UserCredential newUser = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                                VolunteerId = '';
                                VolunteerId = newUser.user!.uid;
                                for (var i = 0; i < myList.length; i++) {
                                  if (myList[i] == VolunteerId) {
                                    isVolunteer = true;
                                    break;
                                  }
                                }

                                if (isVolunteer) {
                                  isVolunteer = false;
                                  VolunteerId = '';
                                  emailController.clear();
                                  passwordController.clear();
                                  await Workmanager()
                                      .initialize(callbackDispatcher,
                                          isInDebugMode: false)
                                      .then((value) => print('workmanager'));
                                  print('workmanager2');
                                  var time = DateTime.now().second.toString();
                                  await Workmanager().registerPeriodicTask(
                                      time, 'firstTask',
                                      frequency: const Duration(minutes: 15));
                                  Navigator.pushNamed(
                                      context, '/volunteerPage');
                                } else if (VolunteerId ==
                                    'GvQo5Qz5ZnTfQYq5GOhZi22HGCB2') {
                                  Navigator.pushNamed(context, '/adminPage');
                                } else {
                                  VolunteerId = '';
                                  emailController.clear();
                                  passwordController.clear();
                                  Navigator.pushNamed(context, '/homePage');
                                }
                              } catch (e) {
                                print(e.toString());
                                if (emailController.text.isNotEmpty &&
                                    passwordController.text.isNotEmpty) {
                                  setState(() {
                                    invalidData = true;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content:
                                        const Text('Invalid email/password'),
                                    backgroundColor: Colors.red.shade400,
                                    margin:
                                        const EdgeInsets.fromLTRB(6, 0, 3, 0),
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      disabledTextColor: Colors.white,
                                      textColor: Colors.white,
                                      onPressed: () {},
                                    ),
                                  ));
                                }
                              }
                            }
                          }),
                    )),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Center(
                        child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Don\'t have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            )),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, "/register");
                            },
                          text: 'Register',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        ),
                      ]),
                    )),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Future signIn() async {
    try {
      final newUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email/password'),
            backgroundColor: Colors.red.shade400,
            margin: const EdgeInsets.fromLTRB(6, 0, 3, 0),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
