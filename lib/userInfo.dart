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
            bool isVolunteer = false;
            bool isSpecial = false;
            if (userData['Type'] == "Volunteer") {
              isVolunteer = true;
            } else {
              isSpecial = true;
            }
            String dis = userData['Disability'];
            dis = dis.substring(0, dis.length - 1);
            print(userName);
            print("hello" + userData['name']);
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                  leading: IconButton(
                    icon:
                        const Icon(Icons.navigate_before, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        height: 800,
                        width: 450,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //textDirection: TextDirection,l,
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Text(
                              "Name: ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500, // light
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userData['name'],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  wordSpacing: 3,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Date of Birth: ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500, // light
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userData['DOB'],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  wordSpacing: 3,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Gender: ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                wordSpacing: 3,
                                letterSpacing: 1, // light
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userData['gender'],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  wordSpacing: 3,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Email: ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500, // light
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userData['Email'],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  wordSpacing: 3,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Phone number: ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500, // light
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userData['phone number'],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  wordSpacing: 3,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Visibility(
                                visible: isVolunteer,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bio: ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500, // light
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    //bio
                                    Text(
                                      userData['bio'],
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w300,
                                          wordSpacing: 3,
                                          letterSpacing: 1),
                                    ),
                                  ],
                                )),
                            Visibility(
                                visible: isSpecial,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Disability: ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500, // light
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    //bio
                                    Text(
                                      dis,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w300,
                                          wordSpacing: 3,
                                          letterSpacing: 1),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                )),
                          ],
                        ))));
          } else {
            return const Text('');
          }
        });
  }
}
