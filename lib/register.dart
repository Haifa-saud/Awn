// ignore_for_file: non_constant_identifier_names
import 'package:awn/services/Utils.dart';
import 'package:awn/login.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'services/theme.dart';
import 'services/myGlobal.dart' as globals;

class register extends StatefulWidget {
  const register({
    Key? key,
  }) : super(key: key);

  @override
  _registerState createState() => _registerState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController cofirmPasswordController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController numberController = TextEditingController();
TextEditingController bioController = TextEditingController();

String group = "gender";
String group1 = "role";
bool blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;
PlatformFile pickedFile = new PlatformFile(name: '', size: 0);
String label = "click to upload disability certificate";
bool upload = false;
String filePath = "Pick file";
File? fileDB;
//Wedd's change
String password = "";
String confirm_password = "";

class _registerState extends State<register> {
  Stream<QuerySnapshot> DisabilityType =
      FirebaseFirestore.instance.collection('UserDisabilityType').snapshots();
  var selectedDisabilityType;

  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  @override
  void dispose() {
    emailController.text = "";
    passwordController.text = "";
    cofirmPasswordController.text = "";
    nameController.text = "";
    numberController.text = "";

    super.dispose();
  }

  DateTime selectedDate = DateTime.now();
  bool showDate = false;

  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // firstDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  String getDate() {
    if (selectedDate == null) {
      return 'select date';
    } else {
      globals.bDay = DateFormat('MMM d, yyyy').format(selectedDate);
      return DateFormat('MMM d, yyyy').format(selectedDate);
    }
  }

  final Storage storage = Storage();

  Widget build(BuildContext context) {
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
        child: ListView(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            FutureBuilder(
                future: storage.downloadURL('logo.png'),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
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
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(
                      color: Colors.grey.shade200,
                    ));
                  }
                  return Container();
                }),
            SizedBox(
              height: height * 0.02,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 95, 94, 94)),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration:
                        theme.inputfield("Email", "example@example.example"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) {
                      if (email != null && !EmailValidator.validate(email)) {
                        return "Enter a valid email";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: theme.inputfield("Name", "Sara Ahmad"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null && value.length < 2) {
                        return "Enter a valid name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Gender:",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: "Female",
                              groupValue: group,
                              onChanged: (T) {
                                setState(() {
                                  group = T!;
                                });
                              },
                            ),
                            const Text("Female",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                            Radio(
                              value: "Male",
                              groupValue: group,
                              onChanged: (T) {
                                print(T);
                                setState(() {
                                  group = T!;
                                });
                              },
                            ),
                            const Text("Male",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        Row(
                          children: const [
                            Text("Register As:"),
                          ],
                        ),
                        Row(children: [
                          Radio(
                            value: "Special Need User",
                            groupValue: group1,
                            onChanged: (T) {
                              print(T);
                              setState(() {
                                group1 = T!;
                              });
                            },
                          ),
                          const Text("Special Needs User",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal)),
                        ]),
                        Row(
                          children: [
                            Radio(
                              value: "Volunteer",
                              groupValue: group1,
                              onChanged: (T) {
                                setState(() {
                                  group1 = T!;
                                });
                              },
                            ),
                            const Text("Volunteer",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (group1 == "Volunteer") {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            maxLength: 300,
                            textAlign: TextAlign.left,
                            controller: bioController,
                            decoration: InputDecoration(
                              hintText:
                                  "Enter your bio here.\n(talk briefly about yourself! )",
                              labelText: 'Bio',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                        );
                      } else if (group1 == 'Special Need User') {
                        return Column(
                          children: [
                            /* Text(
                              "Click to upload your disability certificate:",
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade500,
                                    backgroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.fromLTRB(14, 10, 14, 10),
                                    side: BorderSide(
                                        color: Colors.grey.shade400, width: 1)),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Text(
                                    filePath,
                                    style: TextStyle(
                                      fontSize: 15, /*color: Colors.white*/
                                    ),
                                  ),
                                ),
                                onPressed: selectFile,

                                /*() {
                                 //After successful login we will redirect to profile page. Let's create profile page now
                                },*/
                                // Navigator.pushReplacement(
                                // context,
                                // MaterialPageRoute(
                                //  builder: (context) => ProfilePage()));
                              ),
                            ),*/
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Row(
                              children: const <Widget>[
                                Text(
                                  "Select imparity/ imparities: ",
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                //             Container(
                // padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                // child: StreamBuilder<QuerySnapshot>(
                //     stream: DisabilityType.snapshots(),
                //     builder: (context, snapshot) {
                //       if (!snapshot.hasData) {
                //         return Text("Loading");
                //       } else {
                //         return DropdownButtonFormField(
                //           isDense: true,
                //           onChanged: (value) {
                //             setState(() {
                //               selectedDisabilityType = value;
                //             });
                //           },
                //           validator: (value) => value == null
                //               ? 'Please select a category.'
                //               : null,
                //           hint: const Text('Category (required)*'),
                //           items: snapshot.data!.docs
                //               .map((DocumentSnapshot document) {
                //             return DropdownMenuItem<String>(
                //               value: ((document.data() as Map)['category']),
                //               child: Text((document.data() as Map)['category']),
                //             );
                //           }).toList(),
                //           value: DisabilityType,
                //           isExpanded: false,
                //         );
                //       }
                //     })),

                            //Wedd's change
                            // each row must have a check box and a text
                            // StreatBuilder<QuerySnapshot>(

                            // ),
                            Row(children: [
                              SizedBox(
                                height: 24.0,
                                width: 35.0,
                                child: Checkbox(
                                    value: blind,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        blind = value!;
                                      });
                                    }),
                              ),
                              const Text("Visually Impaired",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                            ]),

                            Row(children: [
                              SizedBox(
                                height: 24.0,
                                width: 35.0,
                                child: Checkbox(
                                    value: mute,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        mute = value!;
                                      });
                                    }),
                              ),
                              const Text("Vocally Impaired",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                            ]),

                            Row(children: [
                              SizedBox(
                                height: 24.0,
                                width: 35.0,
                                child: Checkbox(
                                    value: deaf,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        deaf = value!;
                                      });
                                    }),
                              ),
                              const Text("Hearing Impaired",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal)),
                            ]),

                            Row(
                              children: [
                                SizedBox(
                                  height: 24.0,
                                  width: 35.0,
                                  child: Checkbox(
                                      value: physical,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          physical = value!;
                                        });
                                      }),
                                ),
                                const Text("Physically Impaired",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  height: 24.0,
                                  width: 35.0,
                                  child: Checkbox(
                                      value: other,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          other = value!;
                                        });
                                      }),
                                ),
                                const Text("other",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return const Text('');
                      }
                    }),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  // WEDD START FROM HERE
                  //DOB
                  Container(
                    // padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    //
                    //padding: const EdgeInsets.symmetric(horizontal: 15),
                    //  margin: EdgeInsets.only(bottom: 10, top: 20),
                    // width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Date of Birth:",
                          textAlign: TextAlign.left, //style:TextStyle(re)
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _selectDate(context);
                                showDate = false;
                                globals.bDay = getDate();
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade500,
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                  side: BorderSide(
                                      color: Colors.grey.shade400, width: 1)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Text(
                                  getDate(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold, /*color: Colors.white*/
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        showDate
                            ? Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text(getDate()))
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  //END HERE
                  //Phone number
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 10,
                    decoration: theme.inputfield(
                        "enter your phone number", "0555555555"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    //wedd's chnges
                    validator: (value) {
                      // if (value != null && value.length < 10)
                      //   return "Enter a valid number";
                      // else
                      //   return null;

                      //Wedd's changes
                      if (value == null) {
                        return "Please enter a phone number";
                      } else if (value.length != 10) {
                        return "Please enter a valid phone number";
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  //Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      //Wedd's change
                      hintText:
                          "must have upper case, digit, more than 8 digits",
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
                    validator: (value) {
                      // Wedd's Code for password
                      password = value.toString() ;
                      // RegExp Upper = RegExp(r"(?=.*[A-Z])");
                      // RegExp digit = RegExp(r"(?=.*[0-9])");
                      // if (value == null || value.isEmpty){
                      //   return "please enter a password";
                      // } else if (value.length < 7) {
                      //   return "password should at least be 8 digits"; //ود موجودة ؟
                      // }  else if (!Upper.hasMatch(value)) {
                      // return "password should contain an Upper case";
                      // }  else if (!digit.hasMatch(value)) {
                      //   return "password should contain a number";
                      // } else {
                      //   return null;
                      // }


                      if (value == null || value.isEmpty || value.length < 8) {
                        return 'Please enter a password min 8';
                      }
                      // else if (value.length < 8) {
                      //   return 'Password must be at least 8 digits ';
                      // } else if (!Upper.hasMatch(value)) {
                      //   return 'Password should contain an upper case';
                      // } else if (!digit.hasMatch(value)) {
                      //   return 'Password should contain a number';
                      // }
                      else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFormField(
                    controller: cofirmPasswordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
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
                    validator: (value) {
                      //Wedd's change
                      confirm_password = value.toString();
                      //Wedd's change
                      if (value == null || value.isEmpty) {
                        return "please confirm password";
                      } else if(confirm_password != password){
                        return "Password not match";
                      }else{
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
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
                              MaterialStateProperty.all(const Size(50, 50)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          //    ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Welcom To Awn')),
                          //     );
                          //   signUp();
                          // }else{
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Please fill the empty blanks')),
                          //     );
                          // }
                          
                          if (cofirmPasswordController.text.isEmpty ||
                              cofirmPasswordController.text !=
                                  passwordController.text) {
                            Utils.showSnackBar(
                                "confirm password does not match");
                            return;
                          } else {
                            signUp();
                          }
                        }

                        
                        ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    //child: Text('Don\'t have an account? Create'),
                    child: Text.rich(TextSpan(children: [
                      const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 95, 94, 94)),
                      ),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, "/login");
                          },
                        text: 'Log In',

                        // Navigator.push(
                        //  context,
                        //  MaterialPageRoute(
                        //    builder: (context) =>
                        //     RegistrationPage()));

                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                            decoration: TextDecoration.underline),
                      ),
                    ])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    upload = true;
    if (result == null) {
      upload = false;
      return;
    }
    setState(() {
      pickedFile = result.files.first;
      fileDB = File(pickedFile.path!);

      // final path = 'User/${pickedFile.name}'; //خليه جالسه اجرب
      // final file = File(pickedFile.path!);
      // final ref = FirebaseStorage.instance.ref().child(path);
      // UploadTask uploadTask = ref.putFile(file);
    });
  }

  Future signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      UserHelper.saveUser(user);
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('e.message'),
          backgroundColor: Colors.red.shade400,
          margin: const EdgeInsets.fromLTRB(6, 0, 3, 0),
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
      // Utils.showSnackBar(e.message);
    }
  }
}

class UserHelper {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static saveUser(User? user) async {
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    /*blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;*/
    String email = emailController.text;
    String name = nameController.text;
    String number = numberController.text;
    String age = globals.bDay;
    String disability = "";
    String bio = bioController.text;
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    if (blind == true && blind != null) disability += " Blind,";
    if (mute == true && mute != null) disability += " Mute,";
    if (deaf == true && deaf != null) disability += " Deaf,";
    if (physical == true && physical != null) disability += " Physical,";
    if (other == true && other != null) disability += " Other,";
    final userRef = db.collection("users").doc(user.uid);
    //final volRef = db.collection("volunteers").doc(user!.uid);

    Map<String, dynamic> userData;
    // if (group1 == "Volunteer") {
    if (!((await userRef.get()).exists)) {
      await userRef.set({
        "Email": email,
        "Type": group1,
        "bio": bio,
        "gender": group,
        "name": name,
        "phone number": number,
        "DOB": age,
        "Disability": disability,
        "id": userId,
      });
    }
    // } else if (group1 == "Special Need User") {
    // if (result.files.first != null){
    // var len = pickedFile? ?? '0';
    //   if (fileDB == null) {
    //     File file = fileDB!;
    //     //String filePath = Path.basename(file.path);

    //     final path = 'User/${pickedFile.name}';
    //     // String pickedPath = pickedFile.path == '' ? '' : pickedFile.path;
    //     // final file = File(pickedFile!.path!);
    //     // if (result.files.first != null){
    //     final ref = FirebaseStorage.instance.ref().child(filePath);
    //     UploadTask uploadTask = ref.putFile(file);
    //     final user = FirebaseAuth.instance.currentUser!;
    //     String userId = user.uid;
    //     // String filePath = Path.basename(file.path);
    //     TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    //     filePath = await (await uploadTask).ref.getDownloadURL();
    //     if (!((await userRef.get()).exists)) {
    //       await userRef.set({
    //         "Email": email,
    //         "id": userId,
    //         "Type": group1,
    //         "Disability": disability,
    //         "gender": group,
    //         "name": name,
    //         "phone number": number,
    //         "DOB": age,
    //         //"file": filePath,
    //       });
    //     }
    //     // final userRef = db.collection("users").doc(user!.uid);
    //     // if (!((await userRef.get()).exists)) {
    //     //   await userRef.set(userData);
    //     // }
    //   }
    // }
  }
}
