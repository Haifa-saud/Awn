import 'dart:ffi';

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
    DOB_edit = '',
    Dis_edit = '';
//For diability
bool blind = false;
bool mute = false;
bool deaf = false;
bool physical = false;
bool other = false;
//***************** */

String typeId = "";
var gender_index = 1, outDate;
bool Editing = false;
bool Viewing = true;

class profileState extends State<profile> {
  //For disablitiy
  void clearBool() {
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
    Dis_edit = '';
  }
  //*************** */

  void genderIndex(int n, String D) {
    if (n == 1) {
      gender_edit = 'Female';
      gender_index = 1;
    } else {
      gender_edit = 'Male';
      gender_index = 0;
    }
    outDate = D;
  }

  void seting_outDate(String newDate) {
    outDate = newDate;
  }

//For Disablitiy
  void user_disablitiy(String dis) {
    if (dis.contains('Vocally')) {
      DisabilityType.doc('VocallyImpaired').update({'Checked': true});
      mute = true;
    }
    if (dis.contains('Visually')) {
      DisabilityType.doc('VisuallyImpaired').update({'Checked': true});
      blind = true;
    }
    if (dis.contains('Hearing')) {
      DisabilityType.doc('HearingImpaired').update({'Checked': true});
      deaf = true;
    }
    if (dis.contains('Physically')) {
      DisabilityType.doc('PhysicallyImpaired').update({'Checked': true});
      physical = true;
    }
    if (dis.contains('Other')) {
      DisabilityType.doc('Other').update({'Checked': true});
      other = true;
    }
  }
  //****************** */

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
  //For Disablitiy
  CollectionReference DisabilityType =
      FirebaseFirestore.instance.collection('UserDisabilityType');
  //****************** */
  //
//For Disablitiy 2 run time error when updating
  Stream<QuerySnapshot> UserDis = FirebaseFirestore.instance
      .collection('UserDisabilityType')
      //.orderBy("order")
      .snapshots();
  TextEditingController dateController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    // super.initState();
    // dateController.text = userData['DOB'];
  }

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
              bool isVolunteer = false;
              bool isSpecial = false;
              String dis = '';
              if (userData['Type'] == "Volunteer") {
                isVolunteer = true;
              } else {
                //For Disablitiy
                isSpecial = true;
                dis = userData['Disability'];
                dis = dis.substring(0, (dis.length - 1));
                user_disablitiy(dis);
                //************ */
              }
              var isF = userData['gender'] == "Female" ? 1 : 0;
              name_edit = userData['name'];
              email_edit = userData['Email'];
              phone_edit = userData['phone number'];
              bio_edit = userData['bio'];
              DOB_edit = userData['DOB'];
              genderIndex(isF, DOB_edit);
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
                      height: 25,
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
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
                              height: 30,
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
                              height: 30,
                            ),

                            //DOB field
                            TextFormField(
                              enabled: Editing,
                              // controller: TextEditingController()
                              //   ..text = outDate,
                              readOnly: true,
                              onChanged: (text) => {
                                outDate = text,
                                iniDOB = DateTime.parse(text)
                              },
                              onTap: () async {
                                DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: iniDOB,
                                  firstDate: DateTime(1922),
                                  lastDate: DateTime.now(),
                                );
                                if (newDate != null) {
                                  setState(() {
                                    seting_outDate(DateFormat('yyyy-MM-dd')
                                        .format(newDate));
                                    outDate = DateFormat('yyyy-MM-dd')
                                        .format(newDate);
                                    print(newDate);
                                    iniDOB = newDate;
                                    DOB_edit = outDate;
                                    print(DOB_edit);
                                  });
                                } else {
                                  print("Date is not selected");
                                }
                              },
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF06283D)),
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
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
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 0),
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
                            Visibility(
                              visible: isVolunteer,
                              child: const SizedBox(
                                height: 30,
                              ),
                            ),
                            //bio field
                            Visibility(
                              visible: isVolunteer,
                              child: TextFormField(
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
                            ),
                          ],
                        )),
                    //For Disablitiy
                    Visibility(
                      visible: isSpecial && Viewing,
                      child: buildTextField('Disability', dis),
                    ),
                    Visibility(
                        visible: isSpecial && Editing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
                                child: Text(
                                  'Type OF Disability',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 22),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: DisabilityType.snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text("Loading");
                                    } else {
                                      return Column(
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Container(
                                              child: CheckboxListTile(
                                            value: (document.data()
                                                as Map)['Checked'],
                                            onChanged: (bool? newValue) {
                                              typeId = (document.data()
                                                      as Map)['Type']
                                                  .replaceAll(' ', '');
                                              DisabilityType.doc(typeId).update(
                                                  {'Checked': newValue});
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Visually Impaired') {
                                                blind = !blind;
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Vocally Impaired') {
                                                mute = !mute;
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Hearing Impaired') {
                                                deaf = !deaf;
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Physically Impaired') {
                                                physical = !physical;
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Other') {
                                                other = !other;
                                              }
                                            },
                                            title: Text(
                                                (document.data()
                                                    as Map)['Type'],
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                          ));
                                        }).toList(),
                                      );
                                    }
                                  }),
                            ),
                            //******&*&*&*&*&*&*&*&**&*&*&*&*&*&*&*&*&*&*&* */
                            //disability checkBox 2 !!
                            // StreamBuilder<dynamic>(
                            //     stream: UserDis,
                            //     builder: (context, snapshot) {
                            //       if (!snapshot.hasData) {
                            //         return Text("         Nope !");
                            //       } else {
                            //         final dis_Data = snapshot.data;
                            //         return ListView.builder(
                            //             shrinkWrap: true,
                            //             physics: const BouncingScrollPhysics(),
                            //             reverse: true,
                            //             itemCount: dis_Data!.size,
                            //             itemBuilder: (context, index) {
                            //               return Padding(
                            //                   padding:
                            //                       const EdgeInsets.symmetric(
                            //                           horizontal: 10.0,
                            //                           vertical: 16),
                            //                   child: CheckboxListTile(
                            //                     value: dis_Data.docs[index]
                            //                         ['Checked'],
                            //                     onChanged: (bool? newValue) {
                            //                       dis_Data.docs[index].update(
                            //                           {'Checked': newValue});
                            //                       if (dis_Data.docs[index]
                            //                               ['Type'] ==
                            //                           'Visually Impaired') {
                            //                         blind = !blind;
                            //                       }
                            //                       if (dis_Data.docs[index]
                            //                               ['Type'] ==
                            //                           'Vocally Impaired') {
                            //                         mute = !mute;
                            //                       }
                            //                       if (dis_Data.docs[index]
                            //                               ['Type'] ==
                            //                           'Hearing Impaired') {
                            //                         deaf = !deaf;
                            //                       }
                            //                       if (dis_Data.docs[index]
                            //                               ['Type'] ==
                            //                           'Physically Impaired') {
                            //                         physical = !physical;
                            //                       }
                            //                       if (dis_Data.docs[index]
                            //                               ['Type'] ==
                            //                           'Other') {
                            //                         other = !other;
                            //                       }
                            //                     },
                            //                     title: Text(
                            //                         dis_Data.docs[index]
                            //                             ['Type'],
                            //                         style: const TextStyle(
                            //                             fontSize: 18,
                            //                             fontWeight:
                            //                                 FontWeight.normal)),
                            //                     controlAffinity:
                            //                         ListTileControlAffinity
                            //                             .leading,
                            //                   ));
                            //             });
                            //       }
                            //     }),
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
                                                      .collection("users")
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
                                    //For Disablitiy
                                    if (blind == false &&
                                        mute == false &&
                                        deaf == false &&
                                        other == false &&
                                        physical == false &&
                                        isSpecial == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please choose a disablitity'),
                                          backgroundColor: Colors.deepOrange,
                                        ),
                                      );
                                    } else {
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
                                                              255,
                                                              194,
                                                              98,
                                                              98))),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
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
                                    }
                                    //*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*
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
                                                clearBool();
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
              return const Text('Loading !');
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
    //For Disablitiy
    if (blind == true) Dis_edit += " Visually Impaired,";
    if (mute == true) Dis_edit += " Vocally Impaired,";
    if (deaf == true) Dis_edit += " Hearing Impaired,";
    if (physical == true) Dis_edit += " Physically Impaired,";
    if (other == true) Dis_edit += " Other,";
    //*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
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
      'DOB': DOB_edit,
      //For Disablitiy
      'Disability': Dis_edit
    });
    print('profile edited');
    clearBool();
  }
}
