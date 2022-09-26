// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:awn/login.dart';

// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:get/route_manager.dart';

// // // This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   Stream<QuerySnapshot> getuserInfo(BuildContext context) async* {
//     final user = FirebaseAuth.instance.currentUser!;
//     String userId = user.uid;

//     yield* FirebaseFirestore.instance
//         .collection('users')
//         .where('id', isEqualTo: userId)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final user = Provider.of<MyUser>{context};
//     //final uid = user.uid ;
//     // DatabaseServices databaseServices = DatabaseServices(uid: uid);

//     return Scaffold(
//         //  return Scaffold(
//         appBar: AppBar(
//           title: const Text('Profile'),
//           leading: IconButton(
//             icon: const Icon(Icons.navigate_before, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: Center(
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Visibility(
//                 visible: true,
//                 child: Expanded(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         child: StreamBuilder<QuerySnapshot>(
//                           stream: getuserInfo(context),
//                           builder: (
//                             BuildContext context,
//                             AsyncSnapshot<QuerySnapshot> snapshot,
//                           ) {
//                             if (snapshot.hasError) {
//                               return Text('Something went wrong');
//                             }
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return Text('Loading');
//                             }
//                             final data = snapshot.requireData;
//                             return ListView.builder(
//                               itemCount: data.size,
//                               itemBuilder: (context, index) {
//                                 return Card(
//                                     child: Column(
//                                   children: [
//                                     //name
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(10, 0, 20, 15),
//                                         child: Row(children: [
//                                           Text(
//                                             'Name: ' +
//                                                 ' ${data.docs[index]['name']}',
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ])),
//                                     //date of birth
//                                     Padding(
//                                       padding:
//                                           EdgeInsets.fromLTRB(20, 0, 18, 12),
//                                       child: Row(
//                                         children: [
//                                           Text(
//                                             'Date of birth: ' +
//                                                 ' ${data.docs[index]['DOB']}',
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     //gender
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(10, 0, 20, 15),
//                                         child: Row(children: [
//                                           Text(
//                                             'Gender: ' +
//                                                 ' ${data.docs[index]['gender']}',
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ])),
//                                     //Emial
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(10, 0, 20, 15),
//                                         child: Row(children: [
//                                           Text(
//                                             'Email: ' +
//                                                 ' ${data.docs[index]['Email']}',
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ])),
//                                     //phone
//                                     Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(10, 0, 20, 15),
//                                         child: Row(children: [
//                                           Text(
//                                             'Phone number: ' +
//                                                 ' ${data.docs[index]['phone number']}',
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ])),
//                                     //bio
//                                     Padding(
//                                       padding:
//                                           EdgeInsets.fromLTRB(20, 0, 18, 12),
//                                       child: Row(
//                                         children: [
//                                           Flexible(
//                                             child: Text(
//                                                 'BIO : ${data.docs[index]['bio']}',
//                                                 style: TextStyle(
//                                                     fontSize: 17,
//                                                     fontWeight:
//                                                         FontWeight.w500)),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ));
//                               },
//                             );
//                           },
//                         )))),
//           ]),
//         ));
//   }
// }
