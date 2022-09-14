import 'package:awn/Utils.dart';
import 'package:awn/login.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'forgotPassword.dart';
import 'main.dart';
import 'package:email_validator/email_validator.dart';
import 'theme.dart';
import 'myGlobal.dart' as globals;

class register extends StatefulWidget {
  final Function() onClickedSignIn;
  const register({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  _registerState createState() => _registerState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController cofirmPasswordController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController numberController = TextEditingController();
String group = "gender";
String group1 = "role";
bool blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;
late PlatformFile pickedFile;
String label = "click to upload disability certificate";
bool upload = false;
String filePath = "click to choose file";

class _registerState extends State<register> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  void dispose() {
    emailController.text = "";
    passwordController.text = "";
    cofirmPasswordController.text = "";
    nameController.text = "";
    numberController.text = "";

    super.dispose();
  }

  //add file methods

  var editImg = '';
  Future<void> addImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        File image = File(img!.path);
        print('Image path $image');
        // imagePath = image.toString();
        // imageDB = image;
        editImg = 'Update Image';
      });
    }
  }

  Future uploadFile() async {
    final path = 'User/${pickedFile.name}';
    final file = File(pickedFile.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);

    String filePath = Path.basename(file.path);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    filePath = await (await uploadTask).ref.getDownloadURL();

    CollectionReference posts = FirebaseFirestore.instance.collection('users');

    DocumentReference docReference = await posts.add({'file': filePath});
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
    // ignore: unnecessary_null_comparison
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
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
              height: height * 0.02,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
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
                    decoration: theme.inputfield(
                        "enter your email", "example@example.example"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) {
                      if (email != null && !EmailValidator.validate(email))
                        return "Enter a valid email";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration:
                        theme.inputfield("enter your name", "Sara Adams"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null && value.length < 2)
                        return "Enter a valid name";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
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
                                print(T);
                                setState(() {
                                  group = T!;
                                });
                              },
                            ),
                            Text("Female"),
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
                            Text("Male"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Register As:"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: "Special Needs User",
                              groupValue: group1,
                              onChanged: (T) {
                                print(T);
                                setState(() {
                                  group1 = T!;
                                });
                              },
                            ),
                            Text("Special Needs User"),
                            Radio(
                              value: "Volunteer",
                              groupValue: group1,
                              onChanged: (T) {
                                print(T);
                                setState(() {
                                  group1 = T!;
                                });
                              },
                            ),
                            Text("Volunteer"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (group1.isNotEmpty && group1 == "Volunteer") {
                        return Card(
                            color: Color.fromARGB(255, 243, 241, 241),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                maxLines: 5, //or null
                                decoration: InputDecoration.collapsed(
                                    hintText:
                                        "Enter your bio here. \n(talk briefly about yourself! )"),
                              ),
                            ));
                      } else {
                        return Column(
                          children: [
                            Text(
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
                                      fontSize: 15,
                                      fontWeight: FontWeight
                                          .bold, /*color: Colors.white*/
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
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Select imparity/ imparities: ",
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Row(
                              children: <Widget>[
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
                                Text("Visually Impaired"),
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
                                Text("Vocally Impaired"),
                              ],
                            ),
                            Row(
                              children: <Widget>[
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
                                Text("hearing Impaired"),
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
                                Text("physically Impaired"),
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
                                Text("other"),
                              ],
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  // WEDD START FROM HERE
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
                        Text(
                          "Click to select your date of birth:",
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
                                  padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
                                  side: BorderSide(
                                      color: Colors.grey.shade400, width: 1)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                                child: Text(
                                  getDate(),
                                  style: TextStyle(
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
                                margin: EdgeInsets.only(left: 5),
                                child: Text(getDate()))
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  //END HERE
                  TextFormField(
                    controller: numberController,
                    decoration: theme.inputfield(
                        "enter your phone number", "0555555555"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null && value.length < 10)
                        return "Enter a valid number";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
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
                        return " min 6 alpanumerical characters";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextFormField(
                    controller: cofirmPasswordController,
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
                        return " min 6 alpanumerical characters";
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(50, 0, 50, 10),
                    decoration: BoxDecoration(
                      boxShadow: [
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
                          minimumSize: MaterialStateProperty.all(Size(50, 50)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (cofirmPasswordController.text.isEmpty ||
                              cofirmPasswordController.text !=
                                  passwordController.text) {
                            Utils.showSnackBar(
                                "confirm password does not match");
                            return;
                          } else
                            signUp();
                        }

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
                          ..onTap = widget.onClickedSignIn,
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
      final path = 'User/${pickedFile.name}';
      final file = File(pickedFile.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);

      filePath = Path.basename(file.path);
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
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
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

    if (blind == true && blind != null) disability += " blind,";
    if (mute == true && mute != null) disability += " mute,";
    if (deaf == true && deaf != null) disability += " deaf,";
    if (physical == true && physical != null) disability += " physical,";
    if (other == true && other != null) disability += " other,";

    final path = 'User/${pickedFile.name}';
    final file = File(pickedFile.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);

    String filePath = Path.basename(file.path);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    filePath = await (await uploadTask).ref.getDownloadURL();

    //DocumentReference docReference = await posts.add({'file': filePath});

    Map<String, dynamic> userData = {
      "Email": email,
      "Type": group1,
      "Disability": disability,
      "gender": group,
      "name": name,
      "phone number": number,
      "DOB": age,
      "file": filePath,
    };
    final userRef = db.collection("users").doc(user!.uid);
    if (!((await userRef.get()).exists)) {
      await userRef.set(userData);
    }
  }
}
