import 'package:awn/login.dart';
import 'package:awn/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class userProfile extends StatefulWidget {
  // final String userId;
  const userProfile({
    Key? key,
    /*required this.userId*/
  }) : super(key: key);
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<userProfile> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  Future<Map<String, dynamic>> readUserData() => FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        (DocumentSnapshot doc) {
          print(doc.data() as Map<String, dynamic>);
          return doc.data() as Map<String, dynamic>;
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: Text('Reem is a queeeeen',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(70),
          ),
        ),
      ),
      body: Center(
          child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text(' ${userId}')),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                  side: BorderSide(color: Colors.grey.shade400, width: 1)),
              child: Text('Add Image', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              child: Text('My Posts'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('My Awn Request'),
              onPressed: () {
                // Navigator.push( context, MaterialPageRoute(builder: (context) => const ProfilePage()), );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                  side: BorderSide(color: Colors.grey.shade400, width: 1)),
              // child: Text('Logout', style: TextStyle(color: Colors.black)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Alert Dialog Box"),
                    content: const Text(
                        "Are You Sure You want to delete your Account ?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("Cancle"),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const login()));
                          FirebaseAuth.instance.signOut();
                          //Navigator.of(ctx).pop();
                        },
                        child: Container(
                          color: Color.fromARGB(255, 164, 20, 20),
                          padding: const EdgeInsets.all(14),
                          child: const Text("Log out",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Log out"),
            ),
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
            // ),
          ],
        ),
      )),
    );
  }
}
