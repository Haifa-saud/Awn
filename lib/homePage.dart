import 'addPost.dart';
import 'chatPage.dart';
import 'requestWidget.dart';
import 'services/FCM.dart';
import 'package:firestore_search/firestore_search.dart';
import 'services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/placeWidget.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/services/myGlobal.dart';
import 'package:Awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

class homePage extends StatefulWidget {
  // final userType;
  const homePage();

  @override
  MyHomePage createState() => MyHomePage();
}

class MyHomePage extends State<homePage> with TickerProviderStateMixin {
  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  NotificationService notificationService = NotificationService();
  late final PushNotification acceptanceNotification = PushNotification();

  final Storage storage = Storage();
  var userData;
  int _selectedIndex = 0;
  var logo;
  @override
  void initState() {
    userData = readUserData(FirebaseAuth.instance.currentUser!.uid);
    getToken();
    acceptanceNotification.initApp();
    list = FirebaseFirestore.instance.collection('posts').snapshots();

    isSearch = false;

    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    logo = Padding(
        key: Key('logo'),
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: FutureBuilder(
            future: storage.downloadURL('logo.jpg'),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
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
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue,
                ));
              }
              return Container();
            }));

    super.initState();
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        if (payload.contains('-')) {
          if (payload.substring(0, payload.indexOf('-')) ==
              'requestAcceptance') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => requestPage(
                    fromSNUNotification: true,
                    userType: 'Special Need User',
                    reqID: payload.substring(payload.indexOf('-') + 1)),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (payload.substring(0, payload.indexOf('-')) == 'chat') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => ChatPage(
                    requestID: payload.substring(payload.indexOf('-') + 1),
                    fromNotification: true),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      viewRequests(userType: 'Volunteer', reqID: payload)));
        }
      });

  //! FCM
  var fcmToken;
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) async {
      setState(() {
        fcmToken = token;
        print('fcmToken: $fcmToken');
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
    });

    await FirebaseMessaging.instance.onTokenRefresh
        .listen((String token) async {
      print("New token: $token");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
          print(userData);
          return doc.data() as Map<String, dynamic>;
        },
      );

  TextEditingController _searchController = TextEditingController();

  var isSearch;
  var list;

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
                  centerTitle: false,
                  backgroundColor: Colors.white, //(0xFFfcfffe)
                  automaticallyImplyLeading: false,
                  scrolledUnderElevation: 1,
                  toolbarHeight: 70,
                  leading: logo,
                  // Padding(
                  //     key: Key('logo'),
                  //     padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  //     child: FutureBuilder(
                  //         future: storage.downloadURL('logo.jpg'),
                  //         builder: (BuildContext context,
                  //             AsyncSnapshot<String> snapshot) {
                  //           if (snapshot.connectionState ==
                  //                   ConnectionState.done &&
                  //               snapshot.hasData) {
                  //             return Center(
                  //               child: Image.network(
                  //                 snapshot.data!,
                  //                 fit: BoxFit.cover,
                  //                 width: 40,
                  //                 height: 40,
                  //               ),
                  //             );
                  //           }
                  //           if (snapshot.connectionState ==
                  //                   ConnectionState.waiting ||
                  //               !snapshot.hasData) {
                  //             return const Center(
                  //                 child: CircularProgressIndicator(
                  //               color: Colors.blue,
                  //             ));
                  //           }
                  //           return Container();
                  //         })),

                  title: Stack(children: [
                    Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 5.0)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.0),
                        )),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              if (_searchController.text.trim() != '') {
                                setState(() {
                                  list = FirebaseFirestore.instance
                                      .collection('posts')
                                      .orderBy('searchName')
                                      .where('status', isEqualTo: 'Approved')
                                      .startAt([value.toLowerCase()]).endAt([
                                    value.toLowerCase() + '\uf8ff'
                                  ]).snapshots();
                                  _tabController.animateTo((0));
                                  isSearch = true;
                                });
                              } else {
                                setState(() {
                                  isSearch = false;
                                });
                              }
                            },
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.blue.shade800),
                            maxLength: 25,
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2)),
                              contentPadding: EdgeInsets.fromLTRB(20, 1, 20, 1),
                              hintText: 'Looking for a specific place?',
                              hintStyle: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              suffixIcon:
                                  Icon(Icons.search, color: Colors.black),
                            ))),
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
                                    onTap: (index) {
                                      if (isSearch)
                                        _tabController.animateTo((0));
                                    },
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
                              child: isSearch
                                  ? Place(
                                      userId: userData['id'],
                                      category: '',
                                      status: '',
                                      isSearch: true,
                                      searchList: list,
                                      userName: userData['name'],
                                      userType: userData['Type'],
                                    )
                                  : TabBarView(
                                      controller: _tabController,
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        String cate = ((document.data()
                                            as Map)['category']);
                                        return Place(
                                          userId: userData['id'],
                                          category: cate,
                                          status: '',
                                          userName: userData['name'],
                                          userType: userData['Type'],
                                        );
                                      }).toList(),
                                    ),
                            ))
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
