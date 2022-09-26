// import 'package:awn/addPost.dart';
// import 'package:awn/addRequest.dart';
// import 'package:awn/viewRequests.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get_state_manager/get_state_manager.dart';
// import 'User-profile.dart';
// import 'login.dart';

// class firstPage extends StatefulWidget {
//   const firstPage({Key? key}) : super(key: key);
//   @override
//   UserFirstPage createState() => UserFirstPage();
// }

// class UserFirstPage extends State<firstPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: SizedBox(
//           child: Text('homePage',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               )),
//         ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(70),
//           ),
//         ),
//       ),

//       body: Container(
//         child: Column(
//           children: [
//             ElevatedButton(
//               child: Text('My Info'),
//               onPressed: () {
//                 // Navigator.push( context, MaterialPageRoute(builder: (context) => const ProfilePage()), );
//               },
//             ),
//             ElevatedButton(
//               child: Text('My Posts'),
//               onPressed: () {
//                 //Navigator.push( context, MaterialPageRoute(builder: (context) => const ProfilePage()), );
//               },
//             ),
//             ElevatedButton(
//               child: Text('My Awn Request'),
//               onPressed: () {
//                 // Navigator.push( context, MaterialPageRoute(builder: (context) => const ProfilePage()), );
//               },
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                     title: const Text("Alert Dialog Box"),
//                     content: const Text(
//                         "Are You Sure You want to delete your Account ?"),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(14),
//                           child: const Text("Cancle"),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           FirebaseAuth.instance.signOut();
//                           //Navigator.of(ctx).pop();
//                         },
//                         child: Container(
//                           color: Color.fromARGB(255, 164, 20, 20),
//                           padding: const EdgeInsets.all(14),
//                           child: const Text("Log out"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               child: const Text("Log out"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                     title: const Text("Are You Sure ?"),
//                     content: const Text(
//                         "Are You Sure You want to delete your Account? , This procces can't be undone"),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(14),
//                           child: const Text("Cancle"),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           //Navigator.of(ctx).pop();
//                         },
//                         child: Container(
//                           color: Color.fromARGB(255, 164, 20, 20),
//                           padding: const EdgeInsets.all(14),
//                           child: const Text("Delete"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               child: const Text("Delete My Account"),
//             ),
//           ],
//         ),
//       ),
//       // TODO: implement build
//     );
//   }
// }
