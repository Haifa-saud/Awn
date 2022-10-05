// //! This class handles the Page to display the user's info on the "Edit Profile" Screen
// import 'package:awn/services/appWidgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'addPost.dart';

// class InfoPage extends StatefulWidget {
//   const InfoPage({Key? key}) : super(key: key);
//   @override
//   _InfoPageState createState() => _InfoPageState();
// }

// class _InfoPageState extends State<InfoPage> {
//   var userId = FirebaseAuth.instance.currentUser!.uid;

//   Future<Map<String, dynamic>> readUserData() => FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .get()
//           .then(
//         (DocumentSnapshot doc) {
//           print(doc.data() as Map<String, dynamic>);
//           return doc.data() as Map<String, dynamic>;
//         },
//       );

//   @override
//   Widget build(BuildContext context) {
//     var userData;
//     int _selectedIndex = 3;

//     return FutureBuilder<Map<String, dynamic>>(
//         future: readUserData(),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.hasData) {
//             userData = snapshot.data as Map<String, dynamic>;
//             var userName = userData['name'];
//             bool isVolunteer = false;
//             bool isSpecial = false;
//             String dis = '';
//             if (userData['Type'] == "Volunteer") {
//               isVolunteer = true;
//             } else {
//               isSpecial = true;
//               dis = userData['Disability'];
//               dis = dis.substring(0, (dis.length - 1));
//             }

//             print(userName);
//             print("hello" + userData['name']);
//             return Scaffold(
//                 appBar: AppBar(
//                   title: const Text('Profile'),
//                   leading: IconButton(
//                     icon:
//                         const Icon(Icons.navigate_before, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//                 body: SingleChildScrollView(
//                     child: Container(
//                         padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
//                         height: 800,
//                         width: 450,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: const Color.fromARGB(255, 255, 255, 255),
//                           ),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           //textDirection: TextDirection,l,
//                           children: [
//                             const SizedBox(
//                               height: 50,
//                             ),
//                             const Text(
//                               "Name: ",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500, // light
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               userData['name'],
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w300,
//                                   wordSpacing: 3,
//                                   letterSpacing: 1),
//                             ),
//                             const SizedBox(
//                               height: 30,
//                             ),
//                             const Text(
//                               "Date of Birth: ",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500, // light
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               userData['DOB'],
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w300,
//                                   wordSpacing: 3,
//                                   letterSpacing: 1),
//                             ),
//                             const SizedBox(
//                               height: 30,
//                             ),
//                             const Text(
//                               "Gender: ",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500,
//                                 wordSpacing: 3,
//                                 letterSpacing: 1, // light
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               userData['gender'],
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w300,
//                                   wordSpacing: 3,
//                                   letterSpacing: 1),
//                             ),
//                             const SizedBox(
//                               height: 30,
//                             ),
//                             const Text(
//                               "Email: ",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500, // light
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               userData['Email'],
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w300,
//                                   wordSpacing: 3,
//                                   letterSpacing: 1),
//                             ),
//                             const SizedBox(
//                               height: 30,
//                             ),
//                             const Text(
//                               "Phone number: ",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500, // light
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Text(
//                               userData['phone number'],
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w300,
//                                   wordSpacing: 3,
//                                   letterSpacing: 1),
//                             ),
//                             const SizedBox(
//                               height: 30,
//                             ),
//                             Visibility(
//                                 visible: isVolunteer,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "Bio: ",
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w500, // light
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     //bio
//                                     Text(
//                                       userData['bio'],
//                                       style: const TextStyle(
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.w300,
//                                           wordSpacing: 3,
//                                           letterSpacing: 1),
//                                     ),
//                                   ],
//                                 )),
//                             Visibility(
//                                 visible: isSpecial,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "Disability: ",
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w500, // light
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     //bio
//                                     Text(
//                                       dis,
//                                       textAlign: TextAlign.left,
//                                       style: const TextStyle(
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.w300,
//                                           wordSpacing: 3,
//                                           letterSpacing: 1),
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                   ],
//                                 )),
//                           ],
//                         ))),
//                 floatingActionButton:  FloatingActionButton(
//                   child: const Icon(Icons.add),
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 addPost(userType: userData['Type'])));
//                   },
//                 ),
//                 // floatingActionButtonLocation:
//                 //     FloatingActionButtonLocation.centerDocked,
//                 bottomNavigationBar: BottomNavBar(
//                   onPress: (int value) => setState(() {
//                     _selectedIndex = value;
//                   }),
//                   userType: userData['Type'],
//                   currentI: 3,
//                 ));
//           } else {
//             return const Text('');
//           }
//         });
//   }
// }
