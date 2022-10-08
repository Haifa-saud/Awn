import 'package:awn/services/Utils.dart';
import 'package:awn/register.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/services/usersModel.dart';
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
final user = FirebaseAuth.instance.currentUser!;
String userId = user.uid;
bool isVolunteer = false;
String VolunteerId = '';
var myList = [];

class _loginState extends State<login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
    //final Storage storage = Storage();
    // Get.put(logoController());
    // logoController _logoController = Get.find();

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.cyanAccent.shade100,
          Colors.white54,
          Colors.white54,
          Colors.blue.shade200
        ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.only(left: 40, right: 40),
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
                        future: storage.downloadURL('logo.png'),
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
                            print(AllshopOwners[i].id);
                          }
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return const Text('');
                      },
                    ),
                    const Center(
                      child: Text(
                        "Log In",
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
                      decoration: const InputDecoration(
                        labelText: "Enter Email",
                        hintText: "Email",
                        // contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        // focusedBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(100.0),
                        //     borderSide: const BorderSide(color: Colors.grey)),
                        // enabledBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(100.0),
                        //     borderSide:
                        //         BorderSide(color: Colors.grey.shade400)),
                        // errorBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(100.0),
                        //     borderSide:
                        //         const BorderSide(color: Colors.red, width: 2.0)),
                        // focusedErrorBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(100.0),
                        //     borderSide:
                        //         const BorderSide(color: Colors.red, width: 2.0)),
                      ),
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
                      height: height * 0.01,
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
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Center(
                        child: Container(
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
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
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
                                  Navigator.pushNamed(
                                      context, '/volunteerPage');
                                  await Workmanager().initialize(
                                      callbackDispatcher,
                                      isInDebugMode: false);

                                  var time = DateTime.now().second.toString();
                                  await Workmanager().registerPeriodicTask(
                                      time, 'firstTask',
                                      frequency: const Duration(minutes: 15));
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
                                } else if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Please fill required fields'),
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
                                    ),
                                  );
                                }
                              }
                            }
                            // Utils.showSnackBar("wrong email//password");
                          }),
                    )),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      //child: Text('Don\'t have an account? Create'),
                      child: Text.rich(TextSpan(children: [
                        const TextSpan(
                          text: "Don\'t have an account? ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 95, 94, 94)),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, "/register");
                            },
                          text: 'Register',

                          // Navigator.push(
                          //  context,
                          //  MaterialPageRoute(
                          //    builder: (context) =>
                          //     RegistrationPage()));

                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor),
                        ),
                      ])),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Future<String> getUsersList() async {
    try {
      final userCollection = FirebaseFirestore.instance.collection('users');
      DocumentSnapshot ds = await userCollection.doc(userId).get();
      globals.userType = ds.get("Type");
      return globals.userType;
    } catch (e) {
      print(e.toString());
      return "null";
    }
  }

  Future signIn() async {
    try {
      final newUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      getUsersList();
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
