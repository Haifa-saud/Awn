import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/place.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/placeWidget.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/services/usersModel.dart';
import 'package:awn/userProfile.dart';
import 'package:awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class adminPage extends StatefulWidget {
  const adminPage();

  @override
  _AdminPage createState() => _AdminPage();
}

class _AdminPage extends State<adminPage> with TickerProviderStateMixin {
  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  var userData;

  int _selectedIndex = 0;

  @override
  void initState() {
    userData = readUserData(FirebaseAuth.instance.currentUser!.uid);

    super.initState();
  }

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
          return doc.data() as Map<String, dynamic>;
        },
      );

  //final user = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    var postData;
    final posts = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'Pending')
        .where('userId' == FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
      postData = doc.docs;
    });
    //! Logout
    Future<void> _signOut() async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Workmanager().cancelAll();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => const login()));
        Future.delayed(const Duration(seconds: 1),
            () async => await FirebaseAuth.instance.signOut());
      });
    }

    print(userData);
    TabController _tabController = TabController(length: 6, vsync: this);

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: readUserData(FirebaseAuth.instance.currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              return Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          iconSize: 25,
                          color: const Color(
                              0xFF39d6ce), //Color.fromARGB(255, 149, 204, 250),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                  "Logout",
                                  textAlign: TextAlign.left,
                                ),
                                content: const Text(
                                  "Are You Sure You want to log out of your account ?",
                                  textAlign: TextAlign.left,
                                ),
                                actions: <Widget>[
                                  //log in cancle button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                  //log in ok button
                                  TextButton(
                                    onPressed: () async {
                                      await _signOut();
                                    },
                                    child: Container(
                                      //color: Color.fromARGB(255, 164, 20, 20),
                                      padding: const EdgeInsets.all(14),
                                      child: const Text("Log out",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 164, 10, 10))),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
                  ],
                  centerTitle: false,
                  backgroundColor: Colors.white, //(0xFFfcfffe),
                  foregroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  scrolledUnderElevation: 1,
                  toolbarHeight: 60,
                  title: Row(children: [
                    Container(
                      height: 45,
                      width: 45,
                      margin: const EdgeInsets.fromLTRB(8, 12, 10, 0),
                      child: const CircleAvatar(
                        backgroundColor: Color.fromARGB(
                            255, 149, 204, 250), //Color(0xffE6E6E6),
                        radius: 30,
                        child: Icon(Icons.person,
                            size: 35, color: Colors.white //Color(0xffCCCCCC),
                            ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData['name'],
                                  style: const TextStyle(fontSize: 20)),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    userData['Type'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Color.fromARGB(136, 6, 40, 61),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  )),
                            ])),
                  ]),
                ),
                body: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: category.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Column(children: [
                            Place(category: '', status: 'Pending', userId: ''),
                            InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(32.0),
                                      bottomRight: Radius.circular(32.0)),
                                ),
                                child: ElevatedButton(
                                  child: const Text(
                                    "Approve",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ]);
                        }
                      },
                    )),
              );
            } else {
              return const Text('');
            }
          }),
    );
  }
}
