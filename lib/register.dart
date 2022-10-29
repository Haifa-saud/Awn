import 'package:Awn/services/Utils.dart';
import 'package:Awn/login.dart';
import 'package:Awn/services/firebase_storage_services.dart';
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
import 'package:toggle_switch/toggle_switch.dart';
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
TextEditingController DOBController = TextEditingController();

String group = "Female";
String group1 = "Special Need User";
bool blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;

bool inProgress = false;

String typeId = "";
String password = "";
String confirm_password = "";

class _registerState extends State<register> {
  CollectionReference DisabilityType =
      FirebaseFirestore.instance.collection('UserDisabilityType');
  var selectedDisabilityType;

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  bool _passwordVisible = false;
  @override
  void clearForm() {
    group = "Female";
    group1 = "Special Need User";
    emailController.text = "";
    passwordController.text = "";
    cofirmPasswordController.text = "";
    nameController.text = "";
    numberController.text = "";
    bioController.text = "";
    DOBController.text = '';

    DisabilityType.doc('HearingImpaired').update({'Checked': false});
    DisabilityType.doc('PhysicallyImpaired').update({'Checked': false});
    DisabilityType.doc('VisuallyImpaired').update({'Checked': false});
    DisabilityType.doc('VocallyImpaired').update({'Checked': false});
    DisabilityType.doc('Other').update({'Checked': false});

    blind = false;
    mute = false;
    deaf = false;
    physical = false;
    other = false;
    typeId = "";
    inProgress = false;

    invalidEmail = false;
    emailErrorMessage = '';
  }

  DateTime selectedDate = DateTime.now();
  bool showDate = false;
  ScrollController _scrollController = ScrollController();

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
        DOBController.text =
            DateFormat('yyyy-MM-dd').format(selected).toString();
      });
    }
    return selectedDate;
  }

  String getDate() {
    if (selectedDate == null) {
      return 'select date';
    } else {
      globals.bDay = DateFormat('yyyy-MM-dd').format(selectedDate);
      return DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  final Storage storage = Storage();

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: FutureBuilder(
                future: storage.downloadURL('logo.png'),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Center(
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  }
                  return Container();
                })),
        title: const Text('Register', textAlign: TextAlign.center),
        automaticallyImplyLeading: false,
      ),
      body: Stack(children: [
        inProgress ? Center(child: CircularProgressIndicator()) : SizedBox(),
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [
        //   Colors.cyanAccent.shade100,
        //   Colors.white54,
        //   Colors.white54,
        //   Colors.blue.shade200
        // ], begin: Alignment.topRight, end: Alignment.bottomLeft)),

        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: inProgress ? 0.2 : 1,
          child: Padding(
              // height: 2000,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(children: [
                Expanded(child: registrationSteps()),

                // FutureBuilder(
                //     future: storage.downloadURL('logo.png'),
                //     builder:
                //         (BuildContext context, AsyncSnapshot<String> snapshot) {
                //       if (snapshot.connectionState == ConnectionState.done &&
                //           snapshot.hasData) {
                //         return Center(
                //           child: Image.network(
                //             snapshot.data!,
                //             fit: BoxFit.cover,
                //             width: 100,
                //             height: 100,
                //           ),
                //         );
                //       }
                //       if (snapshot.connectionState == ConnectionState.waiting ||
                //           !snapshot.hasData) {
                //         return Center(
                //             child: CircularProgressIndicator(
                //           color: Colors.grey.shade200,
                //         ));
                //       }
                //       return Container();
                //     }),

                // Form(
                //   key: _formKey,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // const Center(
                //       //   child: Text(
                //       //     "Register",
                //       //     style: TextStyle(
                //       //         fontSize: 30,
                //       //         fontWeight: FontWeight.bold,
                //       //         color: Color.fromARGB(255, 95, 94, 94)),
                //       //   ),
                //       // ),
                //       SizedBox(
                //         height: height * 0.02,
                //       ),
                //       //Email
                //       TextFormField(
                //         controller: emailController,
                //         decoration:
                //             theme.inputfield("Email", "example@example.example"),
                //         autovalidateMode: AutovalidateMode.onUserInteraction,
                //         validator: (email) {
                //           if (email != null &&
                //               !EmailValidator.validate(email) &&
                //               (email.trim()).isEmpty) {
                //             return "Enter a valid email";
                //           } else {
                //             return null;
                //           }
                //         },
                //       ),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),
                //       //Password
                //       TextFormField(
                //         controller: passwordController,
                //         obscureText: !_passwordVisible,
                //         decoration: InputDecoration(
                //           labelText: "Password",
                //           //Wedd's change
                //           hintText:
                //               "must have upper case, digit, more than 8 digits",
                //           suffixIcon: IconButton(
                //             icon: Icon(
                //               // Based on passwordVisible state choose the icon
                //               _passwordVisible
                //                   ? Icons.visibility
                //                   : Icons.visibility_off,
                //               color: Theme.of(context).primaryColorDark,
                //             ),
                //             onPressed: () {
                //               // Update the state i.e. toogle the state of passwordVisible variable
                //               setState(() {
                //                 _passwordVisible = !_passwordVisible;
                //               });
                //             },
                //           ),
                //   contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                //   focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(100.0),
                //       borderSide: const BorderSide(color: Colors.grey)),
                //   enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(100.0),
                //       borderSide: BorderSide(color: Colors.grey.shade400)),
                //   errorBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(100.0),
                //       borderSide:
                //           const BorderSide(color: Colors.red, width: 2.0)),
                //   focusedErrorBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(100.0),
                //       borderSide:
                //           const BorderSide(color: Colors.red, width: 2.0)),
                // ),
                //         autovalidateMode: AutovalidateMode.onUserInteraction,
                //         validator: (value) {
                //           // Wedd's Code for password
                //           password = value.toString();
                //           RegExp Upper = RegExp(r"(?=.*[A-Z])");
                //           RegExp digit = RegExp(r"(?=.*[0-9])");
                //           if (value == null || value.isEmpty) {
                //             return "please enter a password";
                //           } else if (value.length < 7) {
                //             return "password should at least be 8 digits"; //ود موجودة ؟
                //           } else if (!Upper.hasMatch(value)) {
                //             return "password should contain an Upper case";
                //           } else if (!digit.hasMatch(value)) {
                //             return "password should contain a number";
                //           } else {
                //             return null;
                //           }
                //         },
                //       ),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),
                //       TextFormField(
                //         controller: cofirmPasswordController,
                //         obscureText: !_passwordVisible,
                //         decoration: InputDecoration(
                //           labelText: "Confirm Password",
                //           hintText: "Password",
                //           suffixIcon: IconButton(
                //             icon: Icon(
                //               // Based on passwordVisible state choose the icon
                //               _passwordVisible
                //                   ? Icons.visibility
                //                   : Icons.visibility_off,
                //               color: Theme.of(context).primaryColorDark,
                //             ),
                //             onPressed: () {
                //               // Update the state i.e. toogle the state of passwordVisible variable
                //               setState(() {
                //                 _passwordVisible = !_passwordVisible;
                //               });
                //             },
                //           ),
                //           contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                //           focusedBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(100.0),
                //               borderSide: const BorderSide(color: Colors.grey)),
                //           enabledBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(100.0),
                //               borderSide: BorderSide(color: Colors.grey.shade400)),
                //           errorBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(100.0),
                //               borderSide:
                //                   const BorderSide(color: Colors.red, width: 2.0)),
                //           focusedErrorBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(100.0),
                //               borderSide:
                //                   const BorderSide(color: Colors.red, width: 2.0)),
                //         ),
                //         autovalidateMode: AutovalidateMode.onUserInteraction,
                //         validator: (value) {
                //           //Wedd's change
                //           confirm_password = value.toString();
                //           //Wedd's change
                //           if (value == null || value.isEmpty) {
                //             return "please confirm password";
                //           } else if (confirm_password != password) {
                //             return "Password not match";
                //           } else {
                //             return null;
                //           }
                //         },
                //       ),
                //       SizedBox(
                //         height: 10,
                //       ),
                //       Text("Should contain Capital, digit, long than 7",
                //           style: TextStyle(
                //               fontSize: 15, fontWeight: FontWeight.normal)),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),

                //       TextFormField(
                //         controller: nameController,
                //         decoration: theme.inputfield("Name", "Sara Ahmad"),
                //         autovalidateMode: AutovalidateMode.onUserInteraction,
                //         validator: (value) {
                //           if (value != null && value.length < 2) {
                //             return "Enter a valid name";
                //           } else {
                //             return null;
                //           }
                //         },
                //       ),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),
                //       Container(
                //         margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                //         child: Column(
                //           children: [
                //             Row(
                //               children: const [
                //                 Text(
                //                   "Gender:",
                //                 ),
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 Radio(
                //                   value: "Female",
                //                   groupValue: group,
                //                   onChanged: (T) {
                //                     setState(() {
                //                       group = T!;
                //                     });
                //                   },
                //                 ),
                //                 const Text("Female",
                //                     style: TextStyle(
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.normal)),
                //                 Radio(
                //                   value: "Male",
                //                   groupValue: group,
                //                   onChanged: (T) {
                //                     print(T);
                //                     setState(() {
                //                       group = T!;
                //                     });
                //                   },
                //                 ),
                //                 const Text("Male",
                //                     style: TextStyle(
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.normal)),
                //               ],
                //             ),
                //             Row(
                //               children: const [
                //                 Text("Register As:"),
                //               ],
                //             ),
                //             Row(children: [
                //               Radio(
                //                 value: "Special Need User",
                //                 groupValue: group1,
                //                 onChanged: (T) {
                //                   print(T);
                //                   setState(() {
                //                     group1 = T!;
                //                   });
                //                   print(group1);
                //                 },
                //               ),
                //               const Text("Special Need User",
                //                   style: TextStyle(
                //                       fontSize: 18, fontWeight: FontWeight.normal)),
                //             ]),
                //             Row(
                //               children: [
                //                 Radio(
                //                   value: "Volunteer",
                //                   groupValue: group1,
                //                   onChanged: (T) {
                //                     setState(() {
                //                       group1 = T!;
                //                     });
                //                     print(group1);
                //                   },
                //                 ),
                //                 const Text("Volunteer",
                //                     style: TextStyle(
                //                         fontSize: 18,
                //                         fontWeight: FontWeight.normal)),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //       Container(
                //         child: LayoutBuilder(builder: (context, constraints) {
                //           if (group1 == "Volunteer") {
                //             return Container(
                //               padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                //               child: TextFormField(
                //                 keyboardType: TextInputType.multiline,
                //                 maxLines: null,
                //                 maxLength: 180,
                //                 textAlign: TextAlign.left,
                //                 controller: bioController,
                //                 decoration: InputDecoration(
                //                   hintText:
                //                       "Enter your bio here.\n(talk briefly about yourself! )",
                //                   labelText: 'Bio',
                //                   enabledBorder: OutlineInputBorder(
                //                       borderRadius: BorderRadius.circular(30.0),
                //                       borderSide:
                //                           BorderSide(color: Colors.grey.shade400)),
                //                   focusedBorder: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(30.0),
                //                     borderSide: const BorderSide(
                //                         color: Colors.blue, width: 2),
                //                   ),
                //                 ),
                //               ),
                //             );
                //           } else if (group1 == 'Special Need User') {
                //             return Column(
                //               children: [
                //                 SizedBox(
                //                   height: height * 0.01,
                //                 ),
                //                 Row(
                //                   children: const <Widget>[
                //                     Text(
                //                       "Select imparity/imparities: ",
                //                     ),
                //                   ],
                //                 ),
                //                 SizedBox(
                //                   height: height * 0.01,
                //                 ),

                //                 //Wedd's change
                //                 // each row must have a check box and a text

                //                 StreamBuilder<QuerySnapshot>(
                //                     stream: DisabilityType.snapshots(),
                //                     builder: (context, snapshot) {
                //                       if (!snapshot.hasData) {
                //                         return Text("Loading");
                //                       } else {
                //                         return Column(
                //                           children: snapshot.data!.docs
                //                               .map((DocumentSnapshot document) {
                //                             bool isChecked = ((document.data()
                //                                 as Map)['Checked']);
                //                             return DropdownMenuItem<String>(
                //                                 child: CheckboxListTile(
                //                               value: (document.data()
                //                                   as Map)['Checked'],
                //                               onChanged: (bool? newValue) {
                //                                 setState(() {
                //                                   typeId = (document.data()
                //                                           as Map)['Type']
                //                                       .replaceAll(' ', '');
                //                                   DisabilityType.doc(typeId).update(
                //                                       {'Checked': newValue});
                //                                 });

                //                                 if ((document.data()
                //                                         as Map)['Type'] ==
                //                                     'Visually Impaired') {
                //                                   blind = !blind;
                //                                 }
                //                                 if ((document.data()
                //                                         as Map)['Type'] ==
                //                                     'Vocally Impaired') {
                //                                   mute = !mute;
                //                                 }
                //                                 if ((document.data()
                //                                         as Map)['Type'] ==
                //                                     'Hearing Impaired') {
                //                                   deaf = !deaf;
                //                                 }
                //                                 if ((document.data()
                //                                         as Map)['Type'] ==
                //                                     'Physically Impaired') {
                //                                   physical = !physical;
                //                                 }
                //                                 if ((document.data()
                //                                         as Map)['Type'] ==
                //                                     'Other') {
                //                                   other = !other;
                //                                 }
                //                               },
                //                               title: Text(
                //                                   (document.data() as Map)['Type'],
                //                                   style: TextStyle(
                //                                       fontSize: 18,
                //                                       fontWeight:
                //                                           FontWeight.normal)),
                //                               controlAffinity:
                //                                   ListTileControlAffinity.leading,
                //                             ));
                //                           }).toList(),
                //                         );
                //                       }
                //                     }),
                //               ],
                //             );
                //           } else {
                //             return const Text('');
                //           }
                //         }),
                //       ),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),
                //       //WEDD START FROM HERE
                //       //DOB
                //       Container(
                //         margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: [
                //             Align(
                //                 alignment: Alignment.centerLeft,
                //                 child: const Text(
                //                   "Date of Birth:",
                //                   textAlign: TextAlign.left, //style:TextStyle(re)
                //                 )),
                //             SizedBox(
                //               height: height * 0.01,
                //             ),
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 ElevatedButton(
                //                   onPressed: () {
                //                     _selectDate(context);
                //                     showDate = false;
                //                     globals.bDay = getDate();
                //                   },
                //                   style: ElevatedButton.styleFrom(
                //                       foregroundColor: Colors.grey.shade500,
                //                       backgroundColor: Colors.white,
                //                       padding:
                //                           const EdgeInsets.fromLTRB(14, 10, 14, 10),
                //                       side: BorderSide(
                //                           color: Colors.grey.shade400, width: 1)),
                //                   child: Padding(
                //                     padding:
                //                         const EdgeInsets.fromLTRB(40, 0, 40, 0),
                //                     child: Text(
                //                       getDate(),
                //                       style: const TextStyle(
                //                         fontSize: 15,
                //                         fontWeight:
                //                             FontWeight.bold, /*color: Colors.white*/
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //             showDate
                //                 ? Container(
                //                     margin: const EdgeInsets.only(left: 5),
                //                     child: Text(getDate()))
                //                 : const SizedBox(),
                //           ],
                //         ),
                //       ),
                //       //END HERE
                //       //Phone number
                //       TextFormField(
                //         controller: numberController,
                //         keyboardType: TextInputType.number,
                //         inputFormatters: <TextInputFormatter>[
                //           FilteringTextInputFormatter.digitsOnly
                //         ],
                //         maxLength: 10,
                //         decoration: theme.inputfield("Phone Number", "0555555555"),
                //         autovalidateMode: AutovalidateMode.onUserInteraction,
                //         //wedd's chnges
                //         validator: (value) {
                //           // if (value != null && value.length < 10)
                //           //   return "Enter a valid number";
                //           // else
                //           //   return null;

                //           //Wedd's changes
                //           if (value == null) {
                //             return "Please enter a phone number";
                //           } else if (value.length != 10) {
                //             return "Please enter a valid phone number";
                //           }
                //         },
                //       ),
                //       SizedBox(
                //         height: height * 0.01,
                //       ),

                //       SizedBox(
                //         height: height * 0.01,
                //       ),
                //       Center(
                //           child: Container(
                //         margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                //         decoration: BoxDecoration(
                //           boxShadow: const [
                //             BoxShadow(
                //                 color: Colors.black26,
                //                 offset: Offset(0, 4),
                //                 blurRadius: 5.0)
                //           ],
                //           gradient: const LinearGradient(
                //             begin: Alignment.topLeft,
                //             end: Alignment.bottomRight,
                //             stops: [0.0, 1.0],
                //             colors: [
                //               Colors.blue,
                //               Colors.cyanAccent,
                //             ],
                //           ),
                //           borderRadius: BorderRadius.circular(30),
                //         ),
                //         child: ElevatedButton(
                //             style: ButtonStyle(
                //               shape:
                //                   MaterialStateProperty.all<RoundedRectangleBorder>(
                //                 RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(30.0),
                //                 ),
                //               ),
                //               minimumSize:
                //                   MaterialStateProperty.all(const Size(50, 50)),
                //               backgroundColor:
                //                   MaterialStateProperty.all(Colors.transparent),
                //               shadowColor:
                //                   MaterialStateProperty.all(Colors.transparent),
                //             ),
                //             child: const Padding(
                //               padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                //               child: Text(
                //                 'Register',
                //                 style: TextStyle(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.white),
                //               ),
                //             ),
                //             onPressed: () {
                //               if (_formKey.currentState!.validate()) {
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   const SnackBar(content: Text('Welcom To Awn')),
                //                 );
                //                 signUp();

                //                 //   clearForm();
                //               } else {
                //                 // ScaffoldMessenger.of(context).showSnackBar(
                //                 //   const SnackBar(
                //                 //       content:
                //                 //           Text('Please fill the empty blanks')),
                //                 // );
                //               }

                //               // if (cofirmPasswordController.text.isEmpty ||
                //               //     cofirmPasswordController.text !=
                //               //         passwordController.text) {
                //               //   Utils.showSnackBar(
                //               //       "confirm password does not match");
                //               //   return;
                //               // } else {
                //               //   signUp();
                //               // }
                //             }),
                //       )),
                //       Container(
                //         margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                //         //child: Text('Don\'t have an account? Create'),
                //         child: Text.rich(TextSpan(children: [
                //           const TextSpan(
                //             text: "Already have an account? ",
                //             style: TextStyle(
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold,
                //                 color: Color.fromARGB(255, 95, 94, 94)),
                //           ),
                //           TextSpan(
                //             recognizer: TapGestureRecognizer()
                //               ..onTap = () {
                //                 clearForm();
                //                 Navigator.pushNamed(context, "/login");
                //               },
                //             text: 'Log In',
                //             style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 color: Theme.of(context).accentColor,
                //                 decoration: TextDecoration.underline),
                //           ),
                //         ])),
                //       ),
                //     ],
                //   ),
                // ),
                //   ],
                // ),
              ])),
        ),
      ]),
    );
  }

  String type_edit = 'Special Need User', gender_edit = 'Female';
  var type_index = 0, gender_index = 0;

  void typeIndex(int n) {
    if (n == 0) {
      type_edit = 'Special Need User';
      type_index = 0;
    } else {
      type_edit = 'Volunteer';
      type_index = 1;
    }
  }

  void genderIndex(int n) {
    if (n == 0) {
      gender_edit = 'Female';
      gender_index = 0;
    } else {
      gender_edit = 'Male';
      gender_index = 1;
    }
  }

  bool invalidEmail = false;
  String emailErrorMessage = '';

  int _activeCurrentStep = 0;
  Widget registrationSteps() {
    return Column(children: [
      Expanded(
          child: Theme(
              data: ThemeData(canvasColor: const Color(0xFFfcfffe)),
              child: Stepper(
                elevation: 2,
                type: StepperType.horizontal,
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _activeCurrentStep == 0
                          ? Column(children: [
                              Container(
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
                                  child: Center(
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(180, 50)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              50, 10, 50, 10),
                                          child: Text(
                                            'Next',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (_formKey1.currentState!
                                              .validate()) {
                                            if (await checkEmail()) {
                                              controls.onStepContinue!();
                                            } else {
                                              print(
                                                  'email address already in use');
                                            }
                                          }
                                        }),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        clearForm();
                                        Navigator.pushNamed(context, "/login");
                                      },
                                    text: 'Login',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                ])),
                              ),
                            ])
                          : Column(children: [
                              Row(children: [
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
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.transparent),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                      ),
                                      child: const Text(
                                        'Back',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      onPressed: controls.onStepCancel),
                                )),
                                const SizedBox(width: 20),
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
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty.all(
                                            const Size(150, 50)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.transparent),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        if (_formKey2.currentState!
                                            .validate()) {
                                          // controls.onStepContinue!();
                                          setState(() {
                                            inProgress = true;
                                          });
                                          await signUp();
                                        }
                                      }),
                                )),
                              ]),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        clearForm();
                                        Navigator.pushNamed(context, "/login");
                                      },
                                    text: 'Login',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                ])),
                              ),
                            ])
                    ],
                  );
                },
                currentStep: _activeCurrentStep,
                onStepCancel: () {
                  if (_activeCurrentStep > 0) {
                    setState(() {
                      _activeCurrentStep -= 1;
                    });
                  }
                },
                onStepContinue: () {
                  setState(() {
                    _activeCurrentStep = 1;
                  });
                },
                onStepTapped: (int index) {
                  _activeCurrentStep = _activeCurrentStep;
                },
                steps: <Step>[
                  Step(
                      state: _activeCurrentStep != 0
                          ? StepState.complete
                          : StepState.indexed,
                      isActive: true,
                      title: const Text('Login Information'),
                      // style: TextStyle(color: Colors.blue)),
                      content: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Form(
                            key: _formKey1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                ToggleSwitch(
                                  minWidth: 180.0,
                                  minHeight: 45.0,
                                  borderWidth: 1,
                                  borderColor: [Colors.blue, Colors.blue],
                                  customTextStyles: [
                                    const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    ),
                                    const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    )
                                  ],
                                  initialLabelIndex: type_index,
                                  cornerRadius: 100.0,
                                  activeFgColor: Colors.black,
                                  inactiveBgColor: Colors.white,
                                  inactiveFgColor: Colors.black,
                                  totalSwitches: 2,
                                  labels: ['Special Need User', 'Volunteer'],
                                  activeBgColors: [
                                    [Colors.blue],
                                    [Colors.blue]
                                  ],
                                  onToggle: (index) {
                                    if (index == 0) {
                                      type_index = 0;
                                      type_edit = 'Special Need User';
                                      setState(() {
                                        group1 = 'Special Need User';
                                      });
                                      print('switched to: male');
                                    } else {
                                      type_index = 1;
                                      type_edit = 'Volunteer';
                                      setState(() {
                                        group1 = 'Volunteer';
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                //Email
                                TextFormField(
                                  controller: emailController,
                                  decoration: theme.inputfield(
                                      "Email", "example@example.example"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (email) {
                                    if (email != null &&
                                        !EmailValidator.validate(email) &&
                                        (email.trim()).isEmpty) {
                                      return "Enter a valid email";
                                    } else if (invalidEmail) {
                                      return emailErrorMessage;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 25,
                                ),

                                //Password
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2.0)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2.0)),
                                    labelText: "Password",
                                    //Wedd's change

                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    // Wedd's Code for password
                                    password = value.toString();
                                    RegExp Upper = RegExp(r"(?=.*[A-Z])");
                                    RegExp digit = RegExp(r"(?=.*[0-9])");
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a password";
                                    } else if (value.length < 7) {
                                      return "password should at least be 8 characters"; //ود موجودة ؟
                                    } else if (!Upper.hasMatch(value)) {
                                      return "Password should contain an Upper case";
                                    } else if (!digit.hasMatch(value)) {
                                      return "Password should contain a number";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 25,
                                ),

                                //Confirm Password
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
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2.0)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2.0)),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    //Wedd's change
                                    confirm_password = value.toString();
                                    //Wedd's change
                                    if (value == null || value.isEmpty) {
                                      return "Please confirm password";
                                    } else if (confirm_password != password) {
                                      return "Password not match";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                    "The Password should contain at least the following:\n- Uppercase letter.\n- Lowercase letter\n- Number. \n- 8 characters.",
                                    style: TextStyle(
                                      height: 1.5,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ))),
                  Step(
                      state: _activeCurrentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      isActive: _activeCurrentStep != 0 ? true : false,
                      title: const Text('Profile Information'),
                      content: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Form(
                          key: _formKey2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Name
                              TextFormField(
                                controller: nameController,
                                maxLength: 20,
                                decoration:
                                    theme.inputfield("Name", "Sara Ahmad"),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value != null &&
                                      value.length < 2 &&
                                      (value.trim()).isEmpty) {
                                    return "Enter a valid name";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              //Gender
                              ToggleSwitch(
                                minWidth: 180.0,
                                minHeight: 45.0,
                                borderWidth: 1,
                                borderColor: [
                                  Colors.pink.shade200,
                                  Colors.blue.shade200
                                ],
                                customTextStyles: [
                                  const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                  const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  )
                                ],
                                initialLabelIndex: gender_index,
                                cornerRadius: 100.0,
                                activeFgColor: Colors.black,
                                inactiveBgColor: Colors.white,
                                inactiveFgColor: Colors.black,
                                totalSwitches: 2,
                                labels: ['Female', 'Male'],
                                activeBgColors: [
                                  [Colors.pink.shade200],
                                  [Colors.blue.shade200]
                                ],
                                onToggle: (index) {
                                  if (index == 0) {
                                    gender_index = 0;
                                    gender_edit = 'Female';
                                    setState(() {
                                      group = 'Female';
                                    });
                                    print('switched to: male');
                                  } else {
                                    gender_index = 1;
                                    gender_edit = 'Male';
                                    setState(() {
                                      group = 'Male';
                                    });
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 28,
                              ),

                              //DOB
                              TextFormField(
                                readOnly: true,
                                controller: DOBController,
                                onTap: () {
                                  _selectDate(context);
                                  showDate = false;
                                  globals.bDay = getDate();
                                  // DOBController.text = globals.bDay;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Date of Birth',
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      borderSide:
                                          const BorderSide(color: Colors.grey)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2.0)),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      (value.trim()).isEmpty) {
                                    return 'Please select a date of birth';
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 28,
                              ),

                              //Phone number
                              TextFormField(
                                controller: numberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLength: 10,
                                decoration: theme.inputfield(
                                    "Phone Number", "0555555555"),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                //wedd's chnges
                                validator: (value) {
                                  if (value == null) {
                                    return "Please enter a phone number";
                                  } else if (value.length != 10) {
                                    return "Please enter a valid phone number";
                                  }
                                },
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Container(
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  if (group1 == "Volunteer") {
                                    return TextFormField(
                                      maxLines: 5,
                                      maxLength: 180,
                                      textAlign: TextAlign.left,
                                      controller: bioController,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Enter your bio here.\nTalk briefly about yourself!",
                                        labelText: 'Bio',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          borderSide: const BorderSide(
                                              color: Colors.blue, width: 2),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value != null &&
                                            value.length < 2 &&
                                            (value.trim()).isEmpty) {
                                          return "Please enter your bio";
                                        } else {
                                          return null;
                                        }
                                      },
                                    );
                                  } else if (group1 == 'Special Need User') {
                                    return Column(
                                      children: [
                                        Row(
                                          children: const <Widget>[
                                            Text(
                                              "Select imparity/impurities: ",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                            stream: DisabilityType.snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Text("Loading");
                                              } else {
                                                return Column(
                                                  children: snapshot.data!.docs
                                                      .map((DocumentSnapshot
                                                          document) {
                                                    bool isChecked =
                                                        ((document.data()
                                                            as Map)['Checked']);
                                                    return DropdownMenuItem<
                                                            String>(
                                                        child: CheckboxListTile(
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              10, 0, 0, 0),
                                                      value: (document.data()
                                                          as Map)['Checked'],
                                                      onChanged:
                                                          (bool? newValue) {
                                                        setState(() {
                                                          typeId = (document
                                                                          .data()
                                                                      as Map)[
                                                                  'Type']
                                                              .replaceAll(
                                                                  ' ', '');
                                                          DisabilityType.doc(
                                                                  typeId)
                                                              .update({
                                                            'Checked': newValue
                                                          });
                                                        });

                                                        if ((document.data()
                                                                    as Map)[
                                                                'Type'] ==
                                                            'Visually Impaired') {
                                                          blind = !blind;
                                                        }
                                                        if ((document.data()
                                                                    as Map)[
                                                                'Type'] ==
                                                            'Vocally Impaired') {
                                                          mute = !mute;
                                                        }
                                                        if ((document.data()
                                                                    as Map)[
                                                                'Type'] ==
                                                            'Hearing Impaired') {
                                                          deaf = !deaf;
                                                        }
                                                        if ((document.data()
                                                                    as Map)[
                                                                'Type'] ==
                                                            'Physically Impaired') {
                                                          physical = !physical;
                                                        }
                                                        if ((document.data()
                                                                    as Map)[
                                                                'Type'] ==
                                                            'Other') {
                                                          other = !other;
                                                        }
                                                      },
                                                      title: Text(
                                                          (document.data()
                                                              as Map)['Type'],
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                    ));
                                                  }).toList(),
                                                );
                                              }
                                            }),
                                      ],
                                    );
                                  } else {
                                    return const Text('');
                                  }
                                }),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      )),
                  //   Step(
                  //       state: StepState.indexed,
                  //       isActive: _activeCurrentStep == 2 ? true : false,
                  //       title: const Text('Register'),
                  //       content: Center(child: CircularProgressIndicator())),
                ],
              )))
    ]);
  }

// Returns true if email address is in use.
  Future<bool> checkEmail() async {
    try {
      print("try");

      final list = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailController.text.trim());

      if (list.isNotEmpty) {
        setState(() {
          invalidEmail = true;
          emailErrorMessage =
              'The email address is already in use, please try to login.';
        });
        print("empty");
        return false;
      } else {
        setState(() {
          invalidEmail = false;
        });
        print("else");

        // Return false because email adress is not in use
        return true;
      }
    } catch (error) {
      setState(() {
        invalidEmail = true;
        emailErrorMessage = 'The email address is badly formatted.';
      });
      // Handle error
      print('Handle error');

      print(error);
      // ...
      return false;
    }
  }

  Future signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveUser();

      clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome To Awn')),
      );
      Navigator.pushNamed(context, "/homePage");
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('error'),
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

  FirebaseFirestore db = FirebaseFirestore.instance;
  saveUser() async {
    String email = emailController.text;
    String name = nameController.text;
    String number = numberController.text;
    String age = globals.bDay;
    String disability = "";
    String bio = bioController.text;
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;

    if (blind == true && blind != null) disability += " Visually Impaired,";
    if (mute == true && mute != null) disability += " Vocally Impaired,"; //done
    if (deaf == true && deaf != null) disability += " Hearing Impaired,"; //done
    if (physical == true && physical != null)
      disability += " Physically Impaired,"; //done
    if (other == true && other != null) disability += " Other,"; //done
    print(other);
    final userRef = db.collection("users").doc(user.uid);

    Map<String, dynamic> userData;
    if (!((await userRef.get()).exists)) {
      await userRef.set({
        "Email": email,
        "Type": group1,
        "bio": bio,
        "gender": group,
        "name": name,
        "phone number": number,
        "DOB": DOBController.text,
        "Disability": disability,
        "id": userId,
      });

      await db
          .collection("users")
          .doc(user.uid)
          .collection('UserDisabilityType')
          .doc('Visually Impaired')
          .set({
        'Checked': blind,
        'Type': 'Visually Impaired',
        'order': 'c',
      });

      await db
          .collection("users")
          .doc(user.uid)
          .collection('UserDisabilityType')
          .doc('Other')
          .set({
        'Checked': other,
        'Type': 'Other',
        'order': 'c',
      });
      await db
          .collection("users")
          .doc(user.uid)
          .collection('UserDisabilityType')
          .doc('Vocally Impaired')
          .set({
        'Checked': mute,
        'Type': 'Vocally Impaired',
        'order': 'b',
      });
      await db
          .collection("users")
          .doc(user.uid)
          .collection('UserDisabilityType')
          .doc('Hearing Impaired')
          .set({
        'Checked': deaf,
        'Type': 'Hearing Impaired',
        'order': 'c',
      });
      await db
          .collection("users")
          .doc(user.uid)
          .collection('UserDisabilityType')
          .doc('Physically Impaired')
          .set({
        'Checked': physical,
        'Type': 'Physically Impaired',
        'order': 'd',
      }).then((value) {
        setState(() {
          inProgress = true;
        });
      });
    }
  }
}
