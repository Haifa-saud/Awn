import 'package:awn/addPost.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/placeWidget.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyInfo extends StatefulWidget {
  // final String userId;
  final user;
  const MyInfo({required this.user, super.key});
  @override
  MyInfoState createState() => MyInfoState();
}

//Wedd changes
String name_edit = '',
    email_edit = '',
    phone_edit = '',
    bio_edit = '',
    gender_edit = '',
    DOB_edit = '',
    Dis_edit = '';
bool blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;
String typeId = "";

var outDate;

bool isEditing = false;
bool Viewing = true;
void clearBool() {
  // DisabilityType.doc('HearingImpaired').update({'Checked': false});
  // DisabilityType.doc('PhysicallyImpaired').update({'Checked': false});
  // DisabilityType.doc('VisuallyImpaired').update({'Checked': false});
  // DisabilityType.doc('VocallyImpaired').update({'Checked': false});
  // DisabilityType.doc('Other').update({'Checked': false});
  blind = false;
  mute = false;
  deaf = false;
  physical = false;
  other = false;
  typeId = "";
  Dis_edit = '';
}

class MyInfoState extends State<MyInfo> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  var _formKey;
  var userData;
  var gender_index = 1;

  @override
  initState() {
    userData = widget.user;
    nameController.text = userData['name'];
    emailController.text = userData['Email'];
    genderController.text = userData['gender'];
    phoneController.text = userData['phone number'];
    bioController.text = userData['bio'];
    dateController.text = userData['DOB'];

    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  void genderIndex(int n) {
    if (n == 1) {
      gender_edit = 'Female';
      gender_index = 1;
    } else {
      gender_edit = 'Male';
      gender_index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var isF = genderController.text == "Female" ? 1 : 0;

    genderIndex(isF);

    DateTime iniDOB = DateTime.parse(userData['DOB']); //ذي اللي تطلع ايرور ؟

    return Scaffold(
        body: SingleChildScrollView(
            child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Form(
          const SizedBox(
            height: 15,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
              child: Column(
                children: [
                  //name field
                  TextFormField(
                    enabled: isEditing,
                    readOnly: !isEditing,
                    controller: nameController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF06283D)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null &&
                          value.length < 2 &&
                          value.trim() == '') {
                        return "Enter a valid name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  //Email field
                  TextFormField(
                    readOnly: !isEditing,
                    enabled: isEditing,
                    controller: emailController,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF06283D)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) {
                      if (email != null &&
                          !EmailValidator.validate(email) &&
                          email.trim() == '') {
                        return "Enter a valid email";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //DOB field
                  TextFormField(
                    enabled: isEditing,
                    controller: dateController,
                    onTap: () async {
                      DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(dateController.text),
                        firstDate: DateTime(1922),
                        lastDate: DateTime.now(),
                      );
                      if (newDate != null) {
                        setState(() {
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(newDate);
                          print(newDate);
                          iniDOB = newDate;
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF06283D)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Date Of Birth',
                      hintText: outDate,
                      hintStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  //Gender fields
                  !isEditing
                      ? TextFormField(
                          readOnly: false,
                          enabled: false,
                          controller: genderController,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF06283D)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: 'Gender',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            ToggleSwitch(
                              minWidth: 175.0,
                              minHeight: 50.0,
                              fontSize: 17,
                              initialLabelIndex: gender_index,
                              cornerRadius: 10.0,
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey.shade300,
                              inactiveFgColor: Colors.white,
                              totalSwitches: 2,
                              labels: ['Male', 'Female'],
                              activeBgColors: [
                                [const Color.fromARGB(255, 111, 174, 225)],
                                [const Color.fromARGB(255, 232, 116, 155)]
                              ],
                              onToggle: (index) {
                                if (index == 0) {
                                  gender_index = 0;
                                  gender_edit = 'Male';
                                  genderController.text = 'Male';
                                  print('switched to: male');
                                } else {
                                  gender_index = 1;
                                  gender_edit = 'Female';
                                  genderController.text = 'Female';
                                  print('switched to: female');
                                }
                              },
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  //phone number field
                  TextFormField(
                    enabled: isEditing,
                    readOnly: !isEditing,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 10,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF06283D)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Phone Number',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) {
                        return "Please enter a phone number";
                      } else if (value.length != 10) {
                        return "Please enter a valid phone number";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  //bio field
                  Visibility(
                      visible: userData['Type'] == 'Volunteer',
                      child: TextFormField(
                        enabled: isEditing,
                        controller: bioController,
                        maxLength: 180,
                        minLines: 1,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF06283D)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          contentPadding: EdgeInsets.only(bottom: 3),
                          labelText: 'Bio',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      )),

                  //Edit, delete buttons :
                  !isEditing
                      ? Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              width: 150,
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
                                    Color(0xFF39d6ce),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              width: 150,
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
                                    Color(0xFF39d6ce),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Delete Account?"),
                                      content: const Text(
                                        "Are You Sure You want to delete your Account? , This action can't be undone",
                                        textAlign: TextAlign.left,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("cancel"),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // FirebaseFirestore.instance
                                            //     .collection("Comments")
                                            //     .doc(userData['id'])
                                            //     .delete()
                                            //     .then((_) {
                                            //   print("success!, user deleted");
                                            // });
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 194, 98, 98))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        )
                      :
                      //Save and cancel buttons
                      Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 150,
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
                                    Color(0xFF39d6ce),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Save?"),
                                        content: const Text(
                                          "Are You Sure You want to save changes?",
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              child: const Text("cancel",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 194, 98, 98))),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              print(name_edit);
                                              print(email_edit);
                                              print(phone_edit);
                                              print(outDate);
                                              print(bio_edit);
                                              //);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Changes has been Saved!')),
                                              );
                                              UpdateDB();
                                              setState(() {
                                                isEditing = false;
                                                Viewing = true;
                                              });
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              child: const Text(
                                                "Save",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // Cancel changes
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 150,
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
                                    Color(0xFF39d6ce),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Are You Sure ?"),
                                      content: const Text(
                                        "Are You Sure You want to Cancel changes ?",
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isEditing = false;
                                              Viewing = true;
                                            });
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("Yes",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 194, 98, 98))),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text(
                                              "No",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                ],
              )),
        ],
      ),
    )));
  }

  Future<void> UpdateDB() async {
    if (blind == true) Dis_edit += " Visually Impaired,";
    if (mute == true) Dis_edit += " Vocally Impaired,";
    if (deaf == true) Dis_edit += " Hearing Impaired,";
    if (physical == true) Dis_edit += " Physically Impaired,";
    if (other == true) Dis_edit += " Other,";
    print(nameController.text);
    var Edit_info =
        FirebaseFirestore.instance.collection('users').doc(widget.user['id']);
    Edit_info.update({
      'name': nameController.text,
      'gender': genderController.text,
      'phone number': phoneController.text,
      'Email': emailController.text,
      'bio': bioController.text,
      'DOB': dateController.text,
      //'Disability': Dis_edit
    });
    print(emailController.text);
    // resetEmail(emailController.text);

    print('profile edited');
    clearBool();
  }

  Future resetEmail(String newEmail) async {
    var message;
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    print(firebaseUser);
    print('no update');
    firebaseUser.updateEmail(newEmail).then((value) {
      message = 'Success';
      print('message' + message);
    }).catchError((onError) => message = 'error');
    // print('message' + message);
    return message;
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
      child: TextFormField(
        enabled: false,
        // maxLength: 180,
        // minLines: 1,
        // maxLines: 6,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06283D)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}
