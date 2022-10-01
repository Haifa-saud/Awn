import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;
import 'package:buttons_tabbar/buttons_tabbar.dart';

class homePage extends StatefulWidget {
  // final userType;
  const homePage();

  @override
  MyHomePage createState() => MyHomePage();
}

class MyHomePage extends State<homePage> with TickerProviderStateMixin {
  final Stream<QuerySnapshot> posts =
      FirebaseFirestore.instance.collection('posts').snapshots();

//  Future<dynamic> readCategory() =>
//       FirebaseFirestore.instance.collection('postCategory').get().then(
//         (Query<DocumentSnapshot> doc) {
//           print('test');
//           print(doc.data() as Map<String, dynamic>);
//           userData = doc.data() as Map<String, dynamic>;
//           print('test3');

//           return doc.data() as Map<String, dynamic>;
//         },
//       );

  CollectionReference category = FirebaseFirestore.instance.collection(
      'postCategory'); //   var categories = snapshot.docs.map((d) => Category.fromJson(d.data())).toList();

  int _selectedIndex = 0;

  var userData;
  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          print('test');
          print(doc.data() as Map<String, dynamic>);
          userData = doc.data() as Map<String, dynamic>;
          print('test3');

          return doc.data() as Map<String, dynamic>;
        },
      );

  late final NotificationService notificationService;
  @override
  void initState() {
    print('test' + FirebaseAuth.instance.currentUser!.uid);
    userData = readUserData(FirebaseAuth.instance.currentUser!.uid);
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print(payload);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });
  final Storage storage = Storage();

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
                                return Center(
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
                  toolbarHeight: 80,
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
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
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(children: [
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
                                  border:
                                      Border.all(color: Colors.blue, width: 5),
                                ),
                                radius: 30,
                                // borderColor: Colors.blue,
                                buttonMargin:
                                    const EdgeInsets.fromLTRB(6, 4, 6, 4),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                // unselectedBackgroundColor: Colors.white,
                                labelStyle: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                                tabs: const [
                                  Tab(text: "All"),
                                  Tab(text: "Education"),
                                  Tab(text: 'Entertainment'),
                                  Tab(text: 'Transportation'),
                                  Tab(text: 'government'),
                                  Tab(text: 'Other')
                                ]),
                          ]),
                      Expanded(
                        child: Container(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: category.snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text("Loading");
                                  } else {
                                    return TabBarView(
                                      controller: _tabController,
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        String cate = ((document.data()
                                            as Map)['category']);
                                        return placesList(cate);
                                      }).toList(),
                                    );
                                  }
                                })),
                      )
                    ])),
                floatingActionButton: FloatingActionButton(
                  child: Container(
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.add,
                      size: 40,
                    ),
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
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            addPost(userType: userData['Type']),
                        transitionDuration: Duration(seconds: 1),
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

  Widget placesList(String cate) {
    Stream<QuerySnapshot> list =
        FirebaseFirestore.instance.collection('posts').snapshots();
    if (cate != 'All') {
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('category', isEqualTo: cate)
          .snapshots();
    }

    return Container(
        height: double.infinity,
        child: Column(
          children: [
            //! places list
            Expanded(
                child: Container(
                    height: double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: list,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: Text('No available posts'));
                          } else {
                            final data = snapshot.requireData;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: data.size,
                              itemBuilder: (context, index) {
                                bool phone =
                                    data.docs[index]['Phone number'] == ''
                                        ? false
                                        : true;
                                bool website = data.docs[index]['Website'] == ''
                                    ? false
                                    : true;
                                bool description =
                                    data.docs[index]['description'] == ''
                                        ? false
                                        : true;
                                bool loc = data.docs[index]['latitude'] == ''
                                    ? false
                                    : true;
                                bool img = data.docs[index]['img'] == ''
                                    ? false
                                    : true;

                                // Icon icon = data.docs[index]['img'] == '' ? Icon(Icons.navigate_before,
                                //     color: Colors.white);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36.0, vertical: 16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 600,
                                        margin: const EdgeInsets.only(top: 12),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                  blurRadius: 32,
                                                  color: Colors.black45,
                                                  spreadRadius: -8)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                              child: Text(
                                                  '${data.docs[index]['name']}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      1, 0, 4, 4),
                                              child: Text(
                                                  '${data.docs[index]['category']}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                            ),
                                            Visibility(
                                              visible: img,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        1, 0, 4, 4),
                                                child: Image.network(
                                                  data.docs[index]['img'],
                                                  width: 100,
                                                  height: 100,
                                                  //     // fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return const Text(
                                                        'Image could not be load');
                                                  },
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: website ||
                                                  phone ||
                                                  description,
                                              child: ExpansionTile(
                                                title: const Text(
                                                  'View more',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                children: [
                                                  SizedBox(
                                                    width: 450,
                                                    child: Visibility(
                                                      visible: phone,
                                                      child: Text(
                                                        '${data.docs[index]['Phone number']}',
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          color: Color.fromARGB(
                                                              158, 0, 0, 0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 450,
                                                    child: Visibility(
                                                      visible: website,
                                                      child: Text(
                                                        '${data.docs[index]['Website']}',
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          color: Color.fromARGB(
                                                              158, 0, 0, 0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 450,
                                                    child: Visibility(
                                                      visible: website,
                                                      child: Text(
                                                        '${data.docs[index]['description']}',
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          color: Color.fromARGB(
                                                              158, 0, 0, 0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 450,
                                                    child: Visibility(
                                                      visible: website,
                                                      child: Text(
                                                        '${data.docs[index]['description']}',
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          color: Color.fromARGB(
                                                              158, 0, 0, 0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          foregroundColor: Colors
                                                              .blue,
                                                          backgroundColor: Colors
                                                              .white,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  17,
                                                                  16,
                                                                  17,
                                                                  16),
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                          side: BorderSide(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              width: 1)),
                                                      child: const Text(
                                                          'Add Image'),
                                                      onPressed: () {
                                                        double latitude =
                                                            double.parse(data
                                                                    .docs[index]
                                                                ['latitude']);
                                                        double longitude =
                                                            double.parse(data
                                                                    .docs[index]
                                                                ['longitude']);
                                                        (Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MapsPage(
                                                                      latitude:
                                                                          latitude,
                                                                      longitude:
                                                                          longitude),
                                                            )));
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        })))
          ],
        ));
  }
}

class Category {
  String category;

  Category({
    required this.category,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'],
    );
  }
}
