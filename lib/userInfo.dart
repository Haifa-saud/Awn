//! This class handles the Page to display the user's info on the "Edit Profile" Screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
//     //final user = Provider.of<MyUser>{context};
//     //final uid = user.uid ;
//     // DatabaseServices databaseServices = DatabaseServices(uid: uid);
    var userData;

    return FutureBuilder<Map<String, dynamic>>(
        future: readUserData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            userData = snapshot.data as Map<String, dynamic>;
            var userName = userData['name'];
            print(userName);
            print("hello" + userData['name']);
            return Scaffold(
//         //  return Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                  leading: IconButton(
                    icon:
                        const Icon(Icons.navigate_before, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: true,
                        child: Card(
                            child: Column(
                          children: [
                            //name
                            // Padding(
                            //     padding:
                            //         EdgeInsets.fromLTRB(10, 0, 20, 15),
                            //     child: Row(children: [
                            //       Text(
                            //         'Name: ' +
                            //             ' ${data.docs[index]['name']}',
                            //         textAlign: TextAlign.left,
                            //       ),
                            //     ])),
                            //date of birth
                            // Padding(
                            //   padding:
                            //       EdgeInsets.fromLTRB(20, 0, 18, 12),
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         'Date of birth: ' +
                            //             ' ${data.docs[index]['DOB']}',
                            //         textAlign: TextAlign.left,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            //gender
                            // Padding(
                            //     padding:
                            //         EdgeInsets.fromLTRB(10, 0, 20, 15),
                            //     child: Row(children: [
                            //       Text(
                            //         'Gender: ' +
                            //             ' ${data.docs[index]['gender']}',
                            //         textAlign: TextAlign.left,
                            //       ),
                            //     ])),
                            //Emial
                            // Padding(
                            //     padding:
                            //         EdgeInsets.fromLTRB(10, 0, 20, 15),
                            //     child: Row(children: [
                            //       Text(
                            //         'Email: ' +
                            //             ' ${data.docs[index]['Email']}',
                            //         textAlign: TextAlign.left,
                            //       ),
                            //     ])),
                            //phone
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 20, 15),
                                child: Row(children: [
                                  Text(
                                    'Phone number: ' + "${userData['name']}",
                                    textAlign: TextAlign.left,
                                  ),
                                ])),
                            //bio
                            // Padding(
                            //   padding:
                            //       EdgeInsets.fromLTRB(20, 0, 18, 12),
                            //   child: Row(
                            //     children: [
                            //       Flexible(
                            //         child: Text(
                            //             'BIO : ${data.docs[index]['bio']}',
                            //             style: TextStyle(
                            //                 fontSize: 17,
                            //                 fontWeight:
                            //                     FontWeight.w500)),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ));
          } else {
            return const Text('');
          }
        });
  }
}
