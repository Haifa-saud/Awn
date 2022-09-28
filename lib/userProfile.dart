import 'package:awn/login.dart';
import 'package:awn/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class userProfile extends StatefulWidget {
  const userProfile({
    Key? key,
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
        title: const SizedBox(
          child: Text('My Account',
              textAlign: TextAlign.center,
              style: TextStyle(
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
        child: SizedBox(
            // height: 50, //height of button
            // width: 50,
            child: Column(children: [
          Spacer(),
          // My Info button
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
                padding: const EdgeInsets.fromLTRB(45, 30, 45, 30),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //button icon
                SizedBox(
                  width: 50,
                  child: Icon(
                    // <-- Icon
                    Icons.person,
                    size: 24.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                // ignore: prefer_const_constructors
                //button text
                const SizedBox(
                  width: 200,
                  child: Text(
                    'My info',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ), // <-- Text
                //button arrow
                const SizedBox(
                  width: 0,
                  child: Icon(
                    // <-- Icon
                    Icons.keyboard_arrow_right,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),

          //My posts button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                //button icon
                SizedBox(
                  width: 50,
                  child: Icon(
                    // <-- Icon
                    Icons.logout,
                    size: 24.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                // ignore: prefer_const_constructors
                //button text
                const SizedBox(
                  width: 200,
                  child: Text(
                    'My Posts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ), // <-- Text
                //button arrow
                const SizedBox(
                  width: 0,
                  child: Icon(
                    // <-- Icon
                    Icons.keyboard_arrow_right,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          //My Requests
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.fromLTRB(35, 30, 35, 30),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                //button icon
                SizedBox(
                  width: 50,
                  child: Icon(
                    // <-- Icon
                    Icons.handshake,
                    size: 24.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                // ignore: prefer_const_constructors
                //button text
                SizedBox(
                  width: 200,
                  child: const Text(
                    'My Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ), // <-- Text
                //button arrow
                const SizedBox(
                  width: 5,
                  child: Icon(
                    // <-- Icon
                    Icons.keyboard_arrow_right,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          //Log Out
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1)),
            // child: Text('Logout', style: TextStyle(color: Colors.black)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    "Are You Sure?",
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    "Are You Sure You want to log out of your account ?",
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    //log in cancle button
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: const Text("Cancle"),
                      ),
                    ),
                    //log in ok button
                    TextButton(
                      onPressed: () {
                        Workmanager().cancelAll();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => login()));
                        FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        //color: Color.fromARGB(255, 164, 20, 20),
                        padding: const EdgeInsets.all(14),
                        child: const Text("Log out",
                            style: TextStyle(
                                color: Color.fromARGB(255, 164, 10, 10))),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //button icon
                SizedBox(
                  width: 50,
                  child: Icon(
                    // <-- Icon
                    Icons.logout,
                    size: 24.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                // ignore: prefer_const_constructors
                //button text
                SizedBox(
                  width: 200,
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                //arrow // <-- Text
                const SizedBox(
                  width: 0,
                  child: Icon(
                    // <-- Icon
                    Icons.keyboard_arrow_right,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          //Delet Account
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1)),
            // child: Text('Logout', style: TextStyle(color: Colors.black)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    "Are You Sure?",
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    "Are You Sure You want to Delete your account ? \n \n This Action can not be reversed",
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    //delete cancle button
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: const Text("Cancle"),
                      ),
                    ),
                    //delete  button
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        //color: Color.fromARGB(255, 164, 20, 20),
                        padding: const EdgeInsets.all(14),
                        child: const Text("Delete",
                            style: TextStyle(
                                color: Color.fromARGB(255, 164, 10, 10))),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //button icon
                SizedBox(
                  width: 50,
                  child: Icon(
                    // <-- Icon
                    Icons.delete_outline,
                    size: 24.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                //button text
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Delete Account                  ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ), // <-- Text
                // arrow
                const SizedBox(
                  width: 5,
                  child: Icon(
                    // <-- Icon
                    Icons.keyboard_arrow_right,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ])),
      ),
    );
  }
}
