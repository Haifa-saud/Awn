import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/FirstPage.dart';
import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/login.dart';
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
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;
import 'package:buttons_tabbar/buttons_tabbar.dart';

class homePage extends StatefulWidget {
  final userType;
  const homePage({Key? key, required this.userType}) : super(key: key);

  @override
  MyHomePage createState() => MyHomePage();
}

class MyHomePage extends State<homePage> with TickerProviderStateMixin {
  final Stream<QuerySnapshot> posts =
      FirebaseFirestore.instance.collection('posts').snapshots();

  final Stream<QuerySnapshot> education = FirebaseFirestore.instance
      .collection('posts')
      .where('category', isEqualTo: 'Education')
      .snapshots();
  final Stream<QuerySnapshot> entertainment = FirebaseFirestore.instance
      .collection('posts')
      .where('category', isEqualTo: 'Entertainment')
      .snapshots();
  final Stream<QuerySnapshot> government = FirebaseFirestore.instance
      .collection('posts')
      .where('category', isEqualTo: 'Government')
      .snapshots();
  final Stream<QuerySnapshot> transportation = FirebaseFirestore.instance
      .collection('posts')
      .where('category', isEqualTo: 'Transportation')
      .snapshots();
  final Stream<QuerySnapshot> other = FirebaseFirestore.instance
      .collection('posts')
      .where('category', isEqualTo: 'Other')
      .snapshots();

  var userData;
  int _selectedIndex = 0;

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

  late final NotificationService notificationService;
  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print(payload);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => viewRequests(payload)));
      });

  final iconList = <IconData>[
    Icons.home,
    Icons.volume_up,
    Icons.handshake,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    print(widget.userType);
    TabController _tabController = TabController(length: 6, vsync: this);

    Future<void> _onItemTapped(int index) async {
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => homePage(userType: widget.userType)),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const addPost()),
        );
      } else if (index == 2) {
        if (widget.userType == 'Special Need User') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const addRequest()),
          );
        } else if (widget.userType == 'Volunteer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const viewRequests()),
          );
        }
      } else if (index == 3) {
        Workmanager().cancelAll();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => login()));
        FirebaseAuth.instance.signOut();
      }
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: readUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              var userName = userData['name'];

              return Scaffold(
                  appBar: AppBar(
                    centerTitle: false,
                    backgroundColor: const Color(0xFFfcfffe),
                    foregroundColor: Colors.black,
                    automaticallyImplyLeading: false,
                    scrolledUnderElevation: 1,
                    toolbarHeight: 160,
                    title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            textAlign: TextAlign.left,
                            "Awn",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          Text(
                            "Hello, " + userData['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text("Category",
                                style: TextStyle(fontSize: 10)),
                          ),
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
                                  const EdgeInsets.fromLTRB(6, 8, 6, 1),
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
                  ),
                  body: SingleChildScrollView(
                    // controller: _controller,
                    child: Container(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height,
                      child: TabBarView(controller: _tabController, children: [
                        placesList(posts),
                        placesList(education),
                        placesList(entertainment),
                        placesList(transportation),
                        placesList(government),
                        placesList(other),
                      ]),
                    ),
                  ));
            } else {
              return const Text('');
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        splashColor: Colors.blue,
        splashRadius: 1,
        splashSpeedInMilliseconds: 100,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          final size = isActive ? 35.0 : 26.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: size,
                color: color,
              ),
            ],
          );
        },
        activeIndex: _selectedIndex,
        itemCount: 4,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          setState() {
            _selectedIndex = index;
          }

          _onItemTapped(index);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget placesList(Stream<QuerySnapshot> list) {
    return Container(
        child: Column(
      children: [
        //! places list
        Expanded(
            child: Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: list,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: Text('No available posts'));
                      } else {
                        final data = snapshot.requireData;
                        return Container(
                            height: double.infinity,
                            child: ListView.builder(
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
                            ));
                      }
                    })))
      ],
    ));
  }
}
