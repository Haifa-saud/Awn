import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/chatPage.dart';
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

class homePage extends StatefulWidget {
  // final userType;
  const homePage();

  @override
  MyHomePage createState() => MyHomePage();
}

class MyHomePage extends State<homePage> with TickerProviderStateMixin {
  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  late final NotificationService notificationService;

  final Storage storage = Storage();
  var userData;

  int _selectedIndex = 0;

  @override
  void initState() {
    userData = readUserData(FirebaseAuth.instance.currentUser!.uid);
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
          return doc.data() as Map<String, dynamic>;
        },
      );

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: FutureBuilder(
                            future: storage.downloadURL('logo.png'),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Center(
                                  child: Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ));
                              }
                              return Container();
                            }))
                  ],

                  centerTitle: false,
                  backgroundColor: Colors.white, //(0xFFfcfffe)
                  automaticallyImplyLeading: false,
                  scrolledUnderElevation: 1,
                  toolbarHeight: 60,
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 2),
                          child: Text(
                            "Hello, " + userData['name'],
                          ),
                        ),

                        // Container(
                        //   width: double.infinity,
                        //   height: 50,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(100),
                        //     boxShadow: const [
                        //       BoxShadow(
                        //           blurRadius: 15, color: Colors.black45, spreadRadius: -8)
                        //     ],
                        //   ),
                        //   child: Center(
                        //     child: TextField(
                        //       decoration: InputDecoration(
                        //           enabledBorder: const OutlineInputBorder(
                        //               borderSide: BorderSide(color: Colors.transparent)),
                        //           suffixIcon: IconButton(
                        //             icon: const Icon(Icons.search),
                        //             onPressed: () {
                        //               /* Clear the search field */
                        //             },
                        //           ),
                        //           hintText: 'Search...',
                        //           border: InputBorder.none),
                        //     ),
                        //   ),
                        // ),
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
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ButtonsTabBar(
                                    controller: _tabController,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: [0.0, 1.0],
                                        colors: [
                                          Colors.blue,
                                          Color(0xFF39d6ce),
                                        ],
                                      ),
                                    ),
                                    unselectedDecoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.blue, width: 5),
                                    ),
                                    radius: 30,
                                    buttonMargin:
                                        const EdgeInsets.fromLTRB(6, 4, 6, 4),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 10),
                                    labelStyle: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    tabs: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      String cate = ((document.data()
                                          as Map)['category']);
                                      return Tab(text: cate);
                                    }).toList(),
                                  ),
                                ]),
                            Expanded(
                                child: Container(
                                    width: double.maxFinite,
                                    height: MediaQuery.of(context).size.height,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        String cate = ((document.data()
                                            as Map)['category']);
                                        return Place(
                                            userId: '',
                                            category: cate,
                                            status: '');
                                      }).toList(),
                                    )))
                          ]);
                        }
                      },
                    )),
                floatingActionButton: FloatingActionButton(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                        colors: [
                          Colors.blue,
                          Color(0xFF39d6ce),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 40,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            addPost(userType: userData['Type']),
                        transitionDuration: const Duration(seconds: 1),
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                bottomNavigationBar: BottomNavBar(
                  onPress: (int value) => setState(() {
                    _selectedIndex = value;
                  }),
                  userType: userData['Type'],
                  currentI: 0,
                ),
              );
            } else {
              return const Text('');
            }
          }),
    );
  }
}
