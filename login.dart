import 'package:awn/Utils.dart';
import 'package:awn/register.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/userModel.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgotPassword.dart';
import 'myGlobal.dart' as globals;

class login extends StatefulWidget {
  // final VoidCallback onClickedSignUp;
  const login({
    Key? key,
    //required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
final user = FirebaseAuth.instance.currentUser!;
String userId = user.uid;
bool isOwner = false;
String OwnerId = '';
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
  Stream<List<usersModel>> readShopOwner() => FirebaseFirestore.instance
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
            //autovalidateMode: AutovalidateMode.onUserInteraction,
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

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
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

                    /*Obx(() => ListView.separated(
                      itemBuilder: ((context, index) {
                        return ClipRRect(
                          child: SizedBox(
                              height: 200,
                              width: 200,
                              child: FadeInImage(
                                image: NetworkImage(
                                    _logoController.finalimg[index]),
                                placeholder: AssetImage(
                                    "assets/images/app_splash_logo.png"),
                              )),
                        );
                      }),
                      separatorBuilder: ((context, index) {
                        return SizedBox(
                          height: 20,
                        );
                      }),
                      itemCount: _logoController.finalimg.length,
                    )),*/

                    StreamBuilder<List<usersModel>>(
                      stream: readShopOwner(),
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
                        return Text('');
                      },
                    ),
                    Center(
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
                      decoration: InputDecoration(
                        labelText: "Enter Email",
                        hintText: "Email",
                        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email != null && !EmailValidator.validate(email))
                          return "Enter a valid email";
                        else
                          return null;
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
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value != null && value.length < 6)
                          return "Enter a valid password";
                        else
                          return null;
                      },
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                              fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(50, 10, 50, 10),
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            minimumSize:
                                MaterialStateProperty.all(Size(50, 50)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Padding(
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
                                OwnerId = '';
                                OwnerId = newUser.user!.uid;
                                for (var i = 0; i < myList.length; i++) {
                                  if (myList[i] == OwnerId) {
                                    isOwner = true;
                                    break;
                                  }
                                }

                                if (isOwner) {
                                  isOwner = false;
                                  OwnerId = '';
                                  emailController.clear();
                                  passwordController.clear();
                                  Navigator.pushNamed(
                                      context, '/volunteerPage');
                                } else {
                                  OwnerId = '';
                                  emailController.clear();
                                  passwordController.clear();
                                  Navigator.pushNamed(context, '/homePage');
                                }
                              } catch (e) {
                                print(e.toString());
                              }
                            }
                            Utils.showSnackBar("wrong email//password");
                          }

                          //After successful login we will redirect to profile page. Let's create profile page now

                          // Navigator.pushReplacement(
                          // context,
                          // MaterialPageRoute(
                          //  builder: (context) => ProfilePage()));
                          ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      //child: Text('Don\'t have an account? Create'),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
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
                          text: 'Create',

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
                    Container(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => register()));
                        },
                        child: Text(
                          'Title Text',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor), //title
                          textAlign: TextAlign.end, //aligment
                        ),
                      ),
                    )
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no such user exists'),
          backgroundColor: Colors.red.shade400,
          margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.white,
            onPressed: () {
              //Do whatever you want
            },
          ),
        ),
      );
    }
  }
}
