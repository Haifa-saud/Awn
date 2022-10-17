import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class profile extends StatefulWidget {
  // final String userId;
  const profile({super.key});
  @override
  profileState createState() => profileState();
}

String name_edit = '',
    email_edit = '',
    phone_edit = '',
    bio_edit = '',
    gender_edit = '',
    DOB_edit = '';

var gender_index = 1;
bool Editing = false;
bool Viewing = true;

class profileState extends State<profile> {
  void genderIndex(int n) {
    if (n == 1) {
      gender_edit = 'Female';
      gender_index = 1;
    } else {
      gender_edit = 'Male';
      gender_index = 0;
    }
  }

  Future<Map<String, dynamic>> readUserData() => FirebaseFirestore.instance
          .collection('users')
          .doc('H8PmjM0Q0Th5Vvdk1mpKnVLtqdK2')
          .get()
          .then(
        (DocumentSnapshot doc) {
          // print(doc.data() as Map<String, dynamic>);
          return doc.data() as Map<String, dynamic>;
        },
      );

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> users =
        FirebaseFirestore.instance.collection('Users').snapshots();
    var userData;
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: double.infinity,
          child: Text('My Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: readUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              var isF = userData['gender'] == "Female" ? 1 : 0;
              genderIndex(isF);
              name_edit = userData['name'];
              email_edit = userData['Email'];
              phone_edit = userData['phone number'];
              bio_edit = userData['bio'];
              DOB_edit = userData['DOB'];
              DateTime iniDOB = DateTime.parse(userData['DOB']);
              return SingleChildScrollView(
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
                              enabled: Editing,
                              controller: TextEditingController()
                                ..text = userData['name'],
                              onChanged: (text) => {name_edit = text},
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: 'Name',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value != null && value.length < 2) {
                                  return "Enter a valid name";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            //Email field
                            TextFormField(
                              enabled: Editing,
                              controller: TextEditingController()
                                ..text = userData['Email'],
                              onChanged: (text) => {email_edit = text},
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: 'Email',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (email) {
                                if (email != null &&
                                    !EmailValidator.validate(email)) {
                                  return "Enter a valid email";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            //DOB field
                            TextFormField(
                              enabled: Editing,
                              controller: TextEditingController()
                                ..text = DOB_edit,
                              readOnly: true,
                              onChanged: (text) => {DOB_edit = text},
                              onTap: () async {
                                DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: iniDOB,
                                  firstDate: DateTime(1922),
                                  lastDate: DateTime(2122),
                                );
                                if (newDate != null) {
                                  print(newDate);
                                  iniDOB = newDate;
                                  DOB_edit = newDate.toString().substring(0,
                                      10); //get the picked date in the format => 2022-07-04 00:00:00.000
                                  setState(() {
                                    //set foratted date to TextField value.
                                  });
                                } else {
                                  print("Date is not selected");
                                }
                              },
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: 'Date Of Birth',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                          ],
                        )),

                    //Gender fields
                    Visibility(
                      visible: Viewing,
                      child: buildTextField('Gender', userData['gender']),
                    ),
                    Visibility(
                        visible: Editing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
                                child: Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 0, 22),
                              child: ToggleSwitch(
                                minWidth: 170.0,
                                minHeight: 50.0,
                                fontSize: 17,
                                initialLabelIndex: gender_index,
                                cornerRadius: 10.0,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
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
                                    print('switched to: male');
                                  } else {
                                    gender_index = 1;
                                    gender_edit = 'Female';
                                    print('switched to: female');
                                  }
                                },
                              ),
                            )
                          ],
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
                        child: Column(
                          children: [
                            //phone number field
                            TextFormField(
                              enabled: Editing,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 10,
                              controller: TextEditingController()
                                ..text = userData['phone number'],
                              onChanged: (text) => {phone_edit = text},
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: 'Phone Number',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                            TextFormField(
                              enabled: Editing,
                              controller: TextEditingController()
                                ..text = userData['bio'],
                              onChanged: (text) => {bio_edit = text},
                              maxLength: 180,
                              minLines: 1,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: 'Bio',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            ),
                          ],
                        )),

                    //Editing buttons :
                    Visibility(
                        visible: Viewing,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Editing = true;
                                      Viewing = false;
                                    });
                                  },
                                  child: const Text('Edit Profile',
                                      style: TextStyle(fontSize: 22)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .transparent, // background (button) color
                                      foregroundColor:
                                          const Color.fromARGB(255, 79, 83, 83),
                                      side: const BorderSide(
                                          width: 1, // the thickness
                                          color: Colors
                                              .black // the color of the border
                                          ),
                                      padding: const EdgeInsets.fromLTRB(
                                          90, 18, 90, 18),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 15, 15, 17)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(
                                              5.0) //                 <--- border radius here
                                          ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      iconSize: 37,
                                      color: const Color.fromARGB(
                                          255, 194, 98, 98),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Are You Sure ?"),
                                            content: const Text(
                                              "Are You Sure You want to delete your Account? , This procces can't be undone",
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: const Text("cancel"),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("Comments")
                                                      .doc(userData['id'])
                                                      .delete()
                                                      .then((_) {
                                                    print(
                                                        "success!, user deleted");
                                                  });
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: const Text("Delete",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              194,
                                                              98,
                                                              98))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ))
                              ],
                            ))),
                    //Save and cancel buttons
                    Visibility(
                        visible: Editing,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Are You Sure ?"),
                                          content: const Text(
                                            "Are You Sure You want to Save changes ?",
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: const Text("cancel",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 194, 98, 98))),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                print(name_edit);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Changes have been Saved !')),
                                                );
                                                UpdateDB();
                                                setState(() {
                                                  Editing = false;
                                                  Viewing = true;
                                                });
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(14),
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
                                  child: const Text('Save',
                                      style: TextStyle(fontSize: 20)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .transparent, // background (button) color
                                      foregroundColor:
                                          const Color.fromARGB(255, 79, 83, 83),
                                      side: const BorderSide(
                                          width: 1, // the thickness
                                          color: Colors
                                              .black // the color of the border
                                          ),
                                      padding: const EdgeInsets.fromLTRB(
                                          60, 18, 60, 18),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // Cancel changes
                                ElevatedButton(
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
                                                Editing = false;
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
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 15, 12, 12))),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .transparent, // background (button) color
                                      foregroundColor:
                                          const Color.fromARGB(255, 79, 83, 83),
                                      side: const BorderSide(
                                          width: 1, // the thickness
                                          color: Colors
                                              .black // the color of the border
                                          ),
                                      padding: const EdgeInsets.fromLTRB(
                                          60, 18, 60, 18),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                              ],
                            ))),
                  ],
                ),
              ));
            } else {
              return const Text('Good Bye !');
            }
          }),
    );
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
      child: TextField(
        enabled: Editing,
        minLines: 1,
        maxLines: 6,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06283D)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 22,
              color: Colors.blue,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            )),
      ),
    );
  }

  Future<void> UpdateDB() async {
    print('will be added to db');
    var Edit_info = FirebaseFirestore.instance
        .collection('users')
        .doc('H8PmjM0Q0Th5Vvdk1mpKnVLtqdK2');
    Edit_info.update({
      'name': name_edit,
      'gender': gender_edit,
      'phone number': phone_edit,
      'Email': email_edit,
      'bio': bio_edit,
      'DOB': DOB_edit
    });
    print('profile edited');
  }
}
