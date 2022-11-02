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
                future: storage.downloadURL('logo.jpg'),
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
        title: Text(
          'Register',
          textAlign: TextAlign.center,
          // style: TextStyle(color: Colors.blue.shade800),
        ),
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
                                                  const Size(350, 50)),
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
                                          if (await checkEmail()) {
                                            if (_formKey1.currentState!
                                                .validate()) {
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
                                    color: Colors.white,
                                    border: Border.all(color: Colors.blue),
                                    // gradient: const LinearGradient(
                                    //   begin: Alignment.topLeft,
                                    //   end: Alignment.bottomRight,
                                    //   stops: [0.0, 1.0],
                                    //   colors: [
                                    //     Colors.blue,
                                    //     Colors.cyanAccent,
                                    //   ],
                                    // ),
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
                                            Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                50)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.transparent),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.blue.shade800),
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
                                            Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                50)),
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
                      title: Text('Login Information',
                          style: TextStyle(color: Colors.blue.shade700)),
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
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.43,
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
                                    [Colors.blue.shade400],
                                    [Colors.blue.shade400]
                                  ],
                                  onToggle: (index) {
                                    if (index == 0) {
                                      type_index = 0;
                                      type_edit = 'Special Need User';
                                      setState(() {
                                        group1 = 'Special Need User';
                                      });
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
                                    } else if (value.length < 8) {
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
                      title: Text('Profile Information',
                          style: TextStyle(
                              color: _activeCurrentStep != 0
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade700)),
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
