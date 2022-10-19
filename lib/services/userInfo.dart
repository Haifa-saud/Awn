// import 'package:buttons_tabbar/buttons_tabbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:toggle_switch/toggle_switch.dart';

// class MyInfo extends StatefulWidget {
//   // final String userId;
//   final Function() onUpdate;
//   final user;

//   const MyInfo({
//     required this.user,
//     super.key,
//     required this.onUpdate,
//   });
//   @override
//   MyInfoState createState() => MyInfoState();
// }

// var outDate;

// bool isEditing = false;

// class MyInfoState extends State<MyInfo> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController genderController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController bioController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//   TextEditingController disabilityController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();

//   var DisabilityType;

//   String gender_edit = '', Dis_edit = '';
//   bool blind = false;
//   bool mute = false;
//   bool deaf = false;
//   bool physical = false;
//   bool other = false;
//   String typeId = "";
//   bool getPassword = false;
//   bool isAuthValid = true;

//   var _formKey;
//   var userData;
//   var gender_index = 1;
//   var isSpecial, dis;
//   String emailErrorMessage = '';

//   void clearBool() {
//     blind = false;
//     mute = false;
//     deaf = false;
//     physical = false;
//     other = false;
//     typeId = "";
//     Dis_edit = '';
//     dis = "";
//     getPassword = false;
//     passwordController.text = '';
//   }

//   void user_disablitiy(String dis) {
//     if (dis.contains('Vocally')) {
//       mute = true;
//     } else {
//       mute = false;
//     }
//     if (dis.contains('Visually')) {
//       blind = true;
//     } else {
//       blind = false;
//     }
//     if (dis.contains('Hearing')) {
//       deaf = true;
//     } else {
//       deaf = false;
//     }
//     if (dis.contains('Physically')) {
//       physical = true;
//     } else {
//       physical = false;
//     }
//     if (dis.contains('Other')) {
//       other = true;
//     } else {
//       other = false;
//     }
//   }

//   @override
//   initState() {
//     userData = widget.user;
//     nameController.text = userData['name'];
//     emailController.text = userData['Email'];
//     genderController.text = userData['gender'];
//     phoneController.text = userData['phone number'];
//     bioController.text = userData['bio'];
//     dateController.text = userData['DOB'];
//     disabilityController.text = userData['Disability'];

//     DisabilityType = FirebaseFirestore.instance
//         .collection('users')
//         .doc(userData['id'])
//         .collection('UserDisabilityType');

//     isSpecial = false;
//     isEditing = false;
//     emailErrorMessage = 'no error';

//     _formKey = GlobalKey<FormState>();
//     super.initState();
//   }

//   void genderIndex(int n) {
//     if (n == 1) {
//       gender_edit = 'Female';
//       gender_index = 1;
//     } else {
//       gender_edit = 'Male';
//       gender_index = 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     DisabilityType = FirebaseFirestore.instance
//         .collection('users')
//         .doc(userData['id'])
//         .collection('UserDisabilityType');

//     user_disablitiy(disabilityController.text);

//     print(dis);
//     var isF = genderController.text == "Female" ? 1 : 0;
//     genderIndex(isF);
//     DateTime iniDOB = DateTime.parse(userData['DOB']);

//     return Scaffold(
//         body: SingleChildScrollView(
//             child: Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //Form(
//           const SizedBox(
//             height: 15,
//           ),
//           Padding(
//               padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
//               child: Column(
//                 children: [
//                   Column(children: [
//                     //name field
//                     TextFormField(
//                       enabled: isEditing,
//                       readOnly: !isEditing,
//                       controller: nameController,
//                       maxLength: 20,
//                       decoration: const InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFF06283D)),
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                         errorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         focusedErrorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         contentPadding: EdgeInsets.only(bottom: 3),
//                         labelText: 'Name',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       validator: (value) {
//                         if ((value != null && value.length < 2) ||
//                             value == null ||
//                             value.isEmpty ||
//                             (value.trim()).isEmpty) {
//                           return "Enter a valid name";
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                     const SizedBox(
//                       height: 12,
//                     ),
//                     //Email field
//                     TextFormField(
//                       readOnly: !isEditing,
//                       enabled: isEditing,
//                       controller: emailController,
//                       onChanged: (value) {
//                         if (userData['Email'] != value) {
//                           setState(() {
//                             getPassword = true;
//                           });
//                         } else if (userData['Email'] == value) {
//                           setState(() {
//                             getPassword = false;
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFF06283D)),
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                         errorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         focusedErrorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         contentPadding: EdgeInsets.only(bottom: 3),
//                         labelText: 'Email',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       validator: (email) {
//                         if (email != null &&
//                             !EmailValidator.validate(email) &&
//                             email.trim() == '') {
//                           return "Enter a valid email";
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                     const SizedBox(
//                       height: 30,
//                     ),

//                     //Password
//                     Visibility(
//                         visible: getPassword && isEditing,
//                         child: TextFormField(
//                           controller: passwordController,
//                           decoration: const InputDecoration(
//                             enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0xFF06283D)),
//                             ),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Colors.blue),
//                             ),
//                             errorBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Colors.red, width: 2.0)),
//                             focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Colors.red, width: 2.0)),
//                             contentPadding: EdgeInsets.only(bottom: 3),
//                             labelText: 'Password',
//                             floatingLabelBehavior: FloatingLabelBehavior.always,
//                           ),
//                           autovalidateMode: AutovalidateMode.onUserInteraction,
//                           validator: (email) {
//                             if (email != null &&
//                                 !EmailValidator.validate(email) &&
//                                 email.trim() == '') {
//                               return "Enter a valid email";
//                             } else {
//                               return null;
//                             }
//                           },
//                         )),
//                     Visibility(
//                       visible: getPassword && isEditing,
//                       child: const SizedBox(height: 15),
//                     ),
//                     Visibility(
//                         visible: getPassword && isEditing,
//                         child: const Text(
//                             'Please enter your password to update your email.',
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.normal))),
//                     Visibility(
//                       visible: getPassword && isEditing,
//                       child: const SizedBox(height: 30),
//                     ),
//                     Visibility(
//                       visible: getPassword && isEditing && !isAuthValid,
//                       child: Text(emailErrorMessage),
//                     ),

//                     //DOB field
//                     TextFormField(
//                       enabled: isEditing,
//                       controller: dateController,
//                       onTap: () async {
//                         DateTime? newDate = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.parse(dateController.text),
//                           firstDate: DateTime(1922),
//                           lastDate: DateTime.now(),
//                         );
//                         if (newDate != null) {
//                           setState(() {
//                             dateController.text =
//                                 DateFormat('yyyy-MM-dd').format(newDate);
//                             print(newDate);
//                             iniDOB = newDate;
//                           });
//                         } else {
//                           print("Date is not selected");
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFF06283D)),
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                         errorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         focusedErrorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         contentPadding: EdgeInsets.only(bottom: 3),
//                         labelText: 'Date of Birth',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30,
//                     ),

//                     //Gender fields
//                     !isEditing
//                         ? TextFormField(
//                             readOnly: false,
//                             enabled: false,
//                             controller: genderController,
//                             decoration: const InputDecoration(
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xFF06283D)),
//                               ),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.blue),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Colors.red, width: 2.0)),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Colors.red, width: 2.0)),
//                               contentPadding: EdgeInsets.only(bottom: 3),
//                               labelText: 'Gender',
//                               floatingLabelBehavior:
//                                   FloatingLabelBehavior.always,
//                             ),
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               const Padding(
//                                   padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                   child: Text(
//                                     'Gender',
//                                     style: TextStyle(
//                                       fontSize: 17,
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   )),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               ToggleSwitch(
//                                 minWidth: 175.0,
//                                 minHeight: 50.0,
//                                 fontSize: 17,
//                                 initialLabelIndex: gender_index,
//                                 cornerRadius: 10.0,
//                                 activeFgColor: Colors.white,
//                                 inactiveBgColor: Colors.grey.shade300,
//                                 inactiveFgColor: Colors.white,
//                                 totalSwitches: 2,
//                                 labels: ['Male', 'Female'],
//                                 activeBgColors: [
//                                   [const Color.fromARGB(255, 111, 174, 225)],
//                                   [const Color.fromARGB(255, 232, 116, 155)]
//                                 ],
//                                 onToggle: (index) {
//                                   if (index == 0) {
//                                     gender_index = 0;
//                                     gender_edit = 'Male';
//                                     genderController.text = 'Male';
//                                     print('switched to: male');
//                                   } else {
//                                     gender_index = 1;
//                                     gender_edit = 'Female';
//                                     genderController.text = 'Female';
//                                     print('switched to: female');
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                     const SizedBox(
//                       height: 30,
//                     ),

//                     //phone number field
//                     TextFormField(
//                       enabled: isEditing,
//                       readOnly: !isEditing,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: <TextInputFormatter>[
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       maxLength: 10,
//                       controller: phoneController,
//                       decoration: const InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Color(0xFF06283D)),
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue),
//                         ),
//                         errorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         focusedErrorBorder: UnderlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 2.0)),
//                         contentPadding: EdgeInsets.only(bottom: 3),
//                         labelText: 'Phone Number',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       validator: (value) {
//                         if (value == null) {
//                           return "Please enter a phone number";
//                         } else if (value.length != 10) {
//                           return "Please enter a valid phone number";
//                         }
//                       },
//                     ),
//                     const SizedBox(
//                       height: 12,
//                     ),

//                     //disability
//                     Visibility(
//                       visible: userData['Type'] != "Volunteer" && !isEditing,
//                       child: TextFormField(
//                         enabled: false,
//                         controller: disabilityController,
//                         maxLines: null,
//                         decoration: const InputDecoration(
//                             enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0xFF06283D)),
//                             ),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Colors.blue),
//                             ),
//                             contentPadding: EdgeInsets.only(bottom: 3),
//                             labelText: 'Type of Disability',
//                             floatingLabelBehavior: FloatingLabelBehavior.always,
//                             hintStyle: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             )),
//                       ),
//                     ),
//                     Visibility(
//                         visible: userData['Type'] != "Volunteer" && isEditing,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Padding(
//                                 padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                 child: Text(
//                                   'Type of Disability',
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                   textAlign: TextAlign.left,
//                                 )),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                               child: StreamBuilder<QuerySnapshot>(
//                                   stream: FirebaseFirestore.instance
//                                       .collection('users')
//                                       .doc(userData['id'])
//                                       .collection('UserDisabilityType')
//                                       .snapshots(),
//                                   builder: (context, snapshot) {
//                                     if (!snapshot.hasData) {
//                                       return const Center(
//                                           child: CircularProgressIndicator());
//                                     } else {
//                                       return Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: snapshot.data!.docs
//                                             .map((DocumentSnapshot document) {
//                                           return Container(
//                                               child: CheckboxListTile(
//                                             contentPadding: EdgeInsets.fromLTRB(
//                                                 0, 0, 50, 0),
//                                             value: (document.data()
//                                                 as Map)['Checked'],
//                                             onChanged: (bool? newValue) {
//                                               typeId = (document.data()
//                                                       as Map)['Type']
//                                                   .replaceAll(' ', '');
//                                               DisabilityType.doc(typeId).update(
//                                                   {'Checked': newValue});
//                                               if ((document.data()
//                                                       as Map)['Type'] ==
//                                                   'Visually Impaired') {
//                                                 blind = !blind;
//                                                 print('blind: $blind');
//                                               }
//                                               if ((document.data()
//                                                       as Map)['Type'] ==
//                                                   'Vocally Impaired') {
//                                                 mute = !mute;
//                                                 print('mute: $mute');
//                                               }
//                                               if ((document.data()
//                                                       as Map)['Type'] ==
//                                                   'Hearing Impaired') {
//                                                 deaf = !deaf;
//                                                 print('deaf: $deaf');
//                                               }
//                                               if ((document.data()
//                                                       as Map)['Type'] ==
//                                                   'Physically Impaired') {
//                                                 physical = !physical;
//                                                 print('physical: $physical');
//                                               }
//                                               if ((document.data()
//                                                       as Map)['Type'] ==
//                                                   'Other') {
//                                                 other = !other;
//                                                 print('other: $other');
//                                               }
//                                             },
//                                             title: Text(
//                                                 (document.data()
//                                                     as Map)['Type'],
//                                                 style: const TextStyle(
//                                                     fontSize: 18,
//                                                     fontWeight:
//                                                         FontWeight.normal)),
//                                             controlAffinity:
//                                                 ListTileControlAffinity.leading,
//                                           ));
//                                         }).toList(),
//                                       );
//                                     }
//                                   }),
//                             ),
//                           ],
//                         )),
//                     Visibility(
//                         visible: userData['Type'] != 'Volunteer',
//                         child: const SizedBox(
//                           height: 30,
//                         )),

//                     //bio field
//                     Visibility(
//                         visible: userData['Type'] == 'Volunteer',
//                         child: TextFormField(
//                           enabled: isEditing,
//                           controller: bioController,
//                           maxLength: 180,
//                           minLines: 1,
//                           maxLines: 6,
//                           decoration: const InputDecoration(
//                             enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0xFF06283D)),
//                             ),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Colors.blue),
//                             ),
//                             contentPadding: EdgeInsets.only(bottom: 3),
//                             labelText: 'Bio',
//                             floatingLabelBehavior: FloatingLabelBehavior.always,
//                           ),
//                         )),
//                     Visibility(
//                         visible: userData['Type'] == 'Volunteer',
//                         child: const SizedBox(
//                           height: 30,
//                         )),
//                   ]),
//                   //Edit, delete buttons :
//                   !isEditing
//                       ? /*Edit and Delete buttons*/ Row(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//                               width: 150,
//                               decoration: BoxDecoration(
//                                 boxShadow: const [
//                                   BoxShadow(
//                                       color: Colors.black26,
//                                       offset: Offset(0, 4),
//                                       blurRadius: 5.0)
//                                 ],
//                                 gradient: const LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   stops: [0.0, 1.0],
//                                   colors: [
//                                     Colors.blue,
//                                     Color(0xFF39d6ce),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     isEditing = true;
//                                   });
//                                   FocusScope.of(context).unfocus();
//                                 },
//                                 child: const Text('Edit'),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Container(
//                               margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//                               width: 150,
//                               decoration: BoxDecoration(
//                                 boxShadow: const [
//                                   BoxShadow(
//                                       color: Colors.black26,
//                                       offset: Offset(0, 4),
//                                       blurRadius: 5.0)
//                                 ],
//                                 gradient: const LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   stops: [0.0, 1.0],
//                                   colors: [
//                                     Colors.blue,
//                                     Color(0xFF39d6ce),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (ctx) => AlertDialog(
//                                       title: const Text("Delete Account?"),
//                                       content: const Text(
//                                         "Are You Sure You want to delete your Account? , This action can't be undone",
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(ctx).pop();
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(14),
//                                             child: const Text("Cancel"),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () async {
//                                             Navigator.of(ctx).pop();
//                                             FirebaseFirestore.instance
//                                                 .collection('requests')
//                                                 .get()
//                                                 .then((snapshot) {
//                                               List<DocumentSnapshot> allDocs =
//                                                   snapshot.docs;
//                                               List<DocumentSnapshot>
//                                                   filteredDocs = allDocs
//                                                       .where((document) =>
//                                                           (document.data()
//                                                                   as Map<String,
//                                                                       dynamic>)[
//                                                               'userID'] ==
//                                                           userData['id'])
//                                                       .toList();
//                                               for (DocumentSnapshot ds
//                                                   in filteredDocs) {
//                                                 ds.reference.delete().then((_) {
//                                                   print("request deleted");
//                                                 });
//                                               }
//                                             });
//                                             FirebaseFirestore.instance
//                                                 .collection('Comments')
//                                                 .get()
//                                                 .then((snapshot) {
//                                               List<DocumentSnapshot> allDocs =
//                                                   snapshot.docs;
//                                               List<DocumentSnapshot>
//                                                   filteredDocs = allDocs
//                                                       .where((document) =>
//                                                           (document.data()
//                                                                   as Map<String,
//                                                                       dynamic>)[
//                                                               'UserID'] ==
//                                                           userData['id'])
//                                                       .toList();
//                                               for (DocumentSnapshot ds
//                                                   in filteredDocs) {
//                                                 ds.reference.delete().then((_) {
//                                                   print("comments deleted");
//                                                 });
//                                               }
//                                             });
//                                             // await Navigator.pushNamed(
//                                             //     context, '/login');

//                                             FirebaseFirestore.instance
//                                                 .collection("users")
//                                                 .doc(userData['id'])
//                                                 .delete()
//                                                 .then((_) {
//                                               print("success!, user deleted");
//                                             });
//                                             FirebaseAuth.instance.currentUser!
//                                                 .delete()
//                                                 .then((value) {
//                                               Navigator.pushNamed(
//                                                   context, '/login');
//                                             });
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(14),
//                                             child: const Text("Delete",
//                                                 style: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 194, 98, 98))),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                                 child: const Text('Delete Account'),
//                               ),
//                             ),
//                           ],
//                         )
//                       : /*Save and Cancel buttons*/ Row(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.all(10),
//                               width: 150,
//                               decoration: BoxDecoration(
//                                 boxShadow: const [
//                                   BoxShadow(
//                                       color: Colors.black26,
//                                       offset: Offset(0, 4),
//                                       blurRadius: 5.0)
//                                 ],
//                                 gradient: const LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   stops: [0.0, 1.0],
//                                   colors: [
//                                     Colors.blue,
//                                     Color(0xFF39d6ce),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   if (blind == false &&
//                                       mute == false &&
//                                       deaf == false &&
//                                       other == false &&
//                                       physical == false &&
//                                       userData['Type'] != "Volunteer") {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content:
//                                             Text('Please choose a disability'),
//                                         backgroundColor: Colors.deepOrange,
//                                       ),
//                                     );
//                                   } else {
//                                     if (_formKey.currentState!.validate()) {
//                                       // if (emailController.text !=
//                                       //     userData['Email']) {
//                                       //   var user = await FirebaseAuth
//                                       //       .instance.currentUser!;
//                                       //   // try {
//                                       //   //   var result = await user
//                                       //   //       .reauthenticateWithCredential(
//                                       //   //           EmailAuthProvider.credential(
//                                       //   //     email: userData['Email'],
//                                       //   //     password: passwordController.text,
//                                       //   //   ));
//                                       //   //   result.user!.updateEmail(
//                                       //   //       emailController.text);
//                                       //   //   showDialog(
//                                       //   //     context: context,
//                                       //   //     builder: (ctx) => AlertDialog(
//                                       //   //       title: const Text("Save?"),
//                                       //   //       content: const Text(
//                                       //   //         "Are You Sure You want to save changes?",
//                                       //   //         textAlign: TextAlign.left,
//                                       //   //       ),
//                                       //   //       actions: <Widget>[
//                                       //   //         TextButton(
//                                       //   //           onPressed: () {
//                                       //   //             Navigator.of(ctx).pop();
//                                       //   //             FocusScope.of(context)
//                                       //   //                 .unfocus();
//                                       //   //           },
//                                       //   //           child: Container(
//                                       //   //             padding:
//                                       //   //                 const EdgeInsets.all(
//                                       //   //                     14),
//                                       //   //             child: const Text("Cancel",
//                                       //   //                 style: TextStyle(
//                                       //   //                     color:
//                                       //   //                         Color.fromARGB(
//                                       //   //                             255,
//                                       //   //                             194,
//                                       //   //                             98,
//                                       //   //                             98))),
//                                       //   //           ),
//                                       //   //         ),
//                                       //   //         TextButton(
//                                       //   //           onPressed: () {
//                                       //   //             ScaffoldMessenger.of(
//                                       //   //                     context)
//                                       //   //                 .showSnackBar(
//                                       //   //               const SnackBar(
//                                       //   //                   content: Text(
//                                       //   //                       'Changes has been Saved!')),
//                                       //   //             );
//                                       //   //             UpdateDB();
//                                       //   //             setState(() {
//                                       //   //               isEditing = false;
//                                       //   //             });
//                                       //   //             FocusScope.of(context)
//                                       //   //                 .unfocus();

//                                       //   //             Navigator.of(ctx).pop();
//                                       //   //           },
//                                       //   //           child: Container(
//                                       //   //             padding:
//                                       //   //                 const EdgeInsets.all(
//                                       //   //                     14),
//                                       //   //             child: const Text(
//                                       //   //               "Save",
//                                       //   //             ),
//                                       //   //           ),
//                                       //   //         ),
//                                       //   //       ],
//                                       //   //     ),
//                                       //   //   );
//                                       //   // } catch (error) {
//                                       //   //   print(error);
//                                       //   //   emailErrorMessage = error.toString();
//                                       //   //   isAuthValid = false;
//                                       //   // }
//                                       //   await user
//                                       //       .reauthenticateWithCredential(
//                                       //           EmailAuthProvider.credential(
//                                       //     email: userData['Email'],
//                                       //     password: passwordController.text,
//                                       //   ))
//                                       //       .then((userCredential) {
//                                       //     userCredential.user!
//                                       //         .updateEmail(emailController.text)
//                                       //         .catchError((error) {
//                                       //       setState(() {
//                                       //         emailErrorMessage = 'error';

//                                       //         isAuthValid = false;
//                                       //       });
//                                       //     });
//                                       //   });
//                                       // }
//                                       if (true) {
//                                         showDialog(
//                                           context: context,
//                                           builder: (ctx) => AlertDialog(
//                                             title: const Text("Save?"),
//                                             content: const Text(
//                                               "Are You Sure You want to save changes?",
//                                               textAlign: TextAlign.left,
//                                             ),
//                                             actions: <Widget>[
//                                               TextButton(
//                                                 onPressed: () {
//                                                   Navigator.of(ctx).pop();
//                                                   FocusScope.of(context)
//                                                       .unfocus();
//                                                 },
//                                                 child: Container(
//                                                   padding:
//                                                       const EdgeInsets.all(14),
//                                                   child: const Text("Cancel",
//                                                       style: TextStyle(
//                                                           color: Color.fromARGB(
//                                                               255,
//                                                               194,
//                                                               98,
//                                                               98))),
//                                                 ),
//                                               ),
//                                               TextButton(
//                                                 onPressed: () {
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(
//                                                     const SnackBar(
//                                                         content: Text(
//                                                             'Changes has been Saved!')),
//                                                   );
//                                                   UpdateDB();
//                                                   setState(() {
//                                                     isEditing = false;
//                                                   });
//                                                   FocusScope.of(context)
//                                                       .unfocus();

//                                                   Navigator.of(ctx).pop();
//                                                 },
//                                                 child: Container(
//                                                   padding:
//                                                       const EdgeInsets.all(14),
//                                                   child: const Text(
//                                                     "Save",
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   }
//                                 },
//                                 child: const Text('Save'),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             // Cancel changes
//                             Container(
//                               margin: const EdgeInsets.all(10),
//                               width: 150,
//                               decoration: BoxDecoration(
//                                 boxShadow: const [
//                                   BoxShadow(
//                                       color: Colors.black26,
//                                       offset: Offset(0, 4),
//                                       blurRadius: 5.0)
//                                 ],
//                                 gradient: const LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   stops: [0.0, 1.0],
//                                   colors: [
//                                     Colors.blue,
//                                     Color(0xFF39d6ce),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (ctx) => AlertDialog(
//                                       title: const Text("Are You Sure ?"),
//                                       content: const Text(
//                                         "Are You Sure You want to Cancel changes ?",
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             setState(() {
//                                               isEditing = false;
//                                               userData = widget.user;
//                                               getPassword = false;
//                                               nameController.text =
//                                                   userData['name'];
//                                               emailController.text =
//                                                   userData['Email'];
//                                               genderController.text =
//                                                   userData['gender'];
//                                               phoneController.text =
//                                                   userData['phone number'];
//                                               bioController.text =
//                                                   userData['bio'];
//                                               dateController.text =
//                                                   userData['DOB'];
//                                               disabilityController.text =
//                                                   userData['Disability'];
//                                             });
//                                             Navigator.of(ctx).pop();
//                                             FocusScope.of(context).unfocus();
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(14),
//                                             child: const Text("Yes",
//                                                 style: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 194, 98, 98))),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(ctx).pop();
//                                             FocusScope.of(context).unfocus();
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(14),
//                                             child: const Text(
//                                               "No",
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ],
//               )),
//         ],
//       ),
//     )));
//   }

//   Future<void> UpdateDB() async {
//     Dis_edit = '';
//     print('blind: $blind');
//     print('mute: $mute');
//     print('deaf: $deaf');
//     print('physical: $physical');
//     print('other: $other');
//     if (blind == true) Dis_edit += "Visually Impaired, ";
//     if (mute == true) Dis_edit += "Vocally Impaired, ";
//     if (deaf == true) Dis_edit += "Hearing Impaired, ";
//     if (physical == true) Dis_edit += "Physically Impaired, ";
//     if (other == true) Dis_edit += "Other, ";
//     print('in update');
//     disabilityController.text = Dis_edit;

//     var Edit_info =
//         FirebaseFirestore.instance.collection('users').doc(widget.user['id']);
//     var errorMessage = '';

//     if (emailController.text != userData['Email']) {
//       var user = await FirebaseAuth.instance.currentUser!;

//       await user
//           .reauthenticateWithCredential(EmailAuthProvider.credential(
//         email: userData['Email'],
//         password: passwordController.text,
//       ))
//           .then((userCredential) {
//         userCredential.user!
//             .updateEmail(emailController.text)
//             .catchError((error) {
//           errorMessage = error.message;
//           print('error: $error');
//         });
//       });
//     }
//     print('errorMessage: $errorMessage');
//     if (errorMessage == '') {
//       passwordController.text = '';
//       Edit_info.update({
//         'name': nameController.text,
//         'gender': genderController.text,
//         'phone number': phoneController.text,
//         'Email': emailController.text,
//         'bio': bioController.text,
//         'DOB': dateController.text,
//         'Disability': disabilityController.text
//       });
//       widget.onUpdate();
//       print('profile edited');
//       clearBool();
//     } else {
//       isEditing = true;
//     }
//   }
// }
