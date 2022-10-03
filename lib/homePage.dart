import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/place.dart';
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
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  final Stream<QuerySnapshot> posts =
      FirebaseFirestore.instance.collection('posts').snapshots();

  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  int _selectedIndex = 0;

  var userData;
  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
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
                  toolbarHeight: 80,
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
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
                          return const Text("Loading");
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
                                        return placesList(cate);
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
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          }
                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('There is no places currently',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 17)));
                          } else {
                            final data = snapshot.requireData;
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  if (data.docs[index]['latitude'] != '') {
                                    double latitude = double.parse(
                                        '${data.docs[index]['latitude']}');
                                    double longitude = double.parse(
                                        '${data.docs[index]['longitude']}');

                                    return FutureBuilder(
                                      future: getLocationAsString(
                                          latitude, longitude),
                                      builder: (context, snap) {
                                        if (snap.hasData) {
                                          var reqLoc = snap.data;

                                          String category =
                                              data.docs[index]['category'];
                                          var icon;

                                          if (category == 'Education')
                                            icon = const Icon(Icons.school);
                                          else if (category == 'Transportation')
                                            icon = const Icon(
                                                Icons.directions_car);
                                          else
                                            icon = const Icon(Icons.school);

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24,
                                                right: 24,
                                                top: 8,
                                                bottom: 16),
                                            child: InkWell(
                                              onTap: () =>
                                                  Navigator.pushReplacement(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation1,
                                                          animation2) =>
                                                      place(
                                                    placeID: data.docs[index]
                                                        ['docId'],
                                                  ),
                                                  transitionDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  reverseTransitionDuration:
                                                      Duration.zero,
                                                ),
                                              ),
                                              splashColor: Colors.transparent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          blurRadius: 32,
                                                          color: Colors.black45,
                                                          spreadRadius: -8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      16.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      16.0),
                                                            ),
                                                            child: AspectRatio(
                                                              aspectRatio: 2,
                                                              child:
                                                                  Image.network(
                                                                data.docs[index]
                                                                    ['img'],
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (BuildContext
                                                                        context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                                  return const Text(
                                                                      'Image could not be load');
                                                                },
                                                              ),
                                                            )),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Container(
                                                                    child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          13,
                                                                          8,
                                                                          0,
                                                                          8),
                                                                  child: Text(
                                                                    data.docs[
                                                                            index]
                                                                        [
                                                                        'name'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        13,
                                                                        0,
                                                                        0,
                                                                        15),
                                                                child: Text(
                                                                  data.docs[
                                                                          index]
                                                                      [
                                                                      'category'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.8)),
                                                                )),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );

                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(
                                          //       horizontal: 30.0, vertical: 16),
                                          //   child: Stack(
                                          //     children: [
                                          //       Container(
                                          //         // width: 600,
                                          //         margin: const EdgeInsets.only(top: 12),
                                          //         padding: const EdgeInsets.all(2),
                                          //         decoration: BoxDecoration(
                                          //             color: Colors.white,
                                          //             boxShadow: const [
                                          //               BoxShadow(
                                          //                   blurRadius: 32,
                                          //                   color: Colors.black45,
                                          //                   spreadRadius: -8)
                                          //             ],
                                          //             borderRadius:
                                          //                 BorderRadius.circular(15)),
                                          //         child: Column(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment.spaceEvenly,
                                          //           children: [
                                          //             Container(
                                          //               decoration: BoxDecoration(borderRadius:
                                          //                 BorderRadius.circular(15)),
                                          //                 width: double.infinity,
                                          //                 height: 300,
                                          //                 child: FittedBox(
                                          //                   // padding:
                                          //                   //     const EdgeInsets.fromLTRB(
                                          //                   //         0, 0, 0, 0),
                                          //                   fit: BoxFit.fill,

                                          //                   child: Image.network(
                                          //                     data.docs[index]['img'],
                                          //                     errorBuilder:
                                          //                         (BuildContext context,
                                          //                             Object exception,
                                          //                             StackTrace?
                                          //                                 stackTrace) {
                                          //                       return const Text(
                                          //                           'Image could not be load');
                                          //                     },
                                          //                   ),
                                          //                 )),
                                          //             Padding(
                                          //               padding:
                                          //                   const EdgeInsets.fromLTRB(
                                          //                       0, 0, 0, 0),
                                          //               child: Text(
                                          //                   '${data.docs[index]['name']}',
                                          //                   textAlign: TextAlign.left,
                                          //                   style: const TextStyle(
                                          //                       fontSize: 18)),
                                          //             ),
                                          //             Padding(
                                          //               padding:
                                          //                   const EdgeInsets.fromLTRB(
                                          //                       1, 0, 4, 4),
                                          //               child: Text(
                                          //                   '${data.docs[index]['category']}',
                                          //                   textAlign: TextAlign.left,
                                          //                   style: const TextStyle(
                                          //                       fontSize: 14)),
                                          //             ),
                                          //             Visibility(
                                          //               visible: website ||
                                          //                   phone ||
                                          //                   description,
                                          //               child: ExpansionTile(
                                          //                 title: const Text(
                                          //                   'View more',
                                          //                   style: TextStyle(
                                          //                     fontSize: 15.0,
                                          //                     color: Colors.black,
                                          //                   ),
                                          //                 ),
                                          //                 children: [
                                          //                   SizedBox(
                                          //                     width: 450,
                                          //                     child: Visibility(
                                          //                       visible: phone,
                                          //                       child: Text(
                                          //                         '${data.docs[index]['Phone number']}',
                                          //                         style: const TextStyle(
                                          //                           fontSize: 15.0,
                                          //                           color: Color.fromARGB(
                                          //                               158, 0, 0, 0),
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   SizedBox(
                                          //                     width: 450,
                                          //                     child: Visibility(
                                          //                       visible: website,
                                          //                       child: Text(
                                          //                         '${data.docs[index]['Website']}',
                                          //                         style: const TextStyle(
                                          //                           fontSize: 15.0,
                                          //                           color: Color.fromARGB(
                                          //                               158, 0, 0, 0),
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   SizedBox(
                                          //                     width: 450,
                                          //                     child: Visibility(
                                          //                       visible: website,
                                          //                       child: Text(
                                          //                         '${data.docs[index]['description']}',
                                          //                         style: const TextStyle(
                                          //                           fontSize: 15.0,
                                          //                           color: Color.fromARGB(
                                          //                               158, 0, 0, 0),
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   SizedBox(
                                          //                     width: 450,
                                          //                     child: Visibility(
                                          //                       visible: website,
                                          //                       child: Text(
                                          //                         '${data.docs[index]['description']}',
                                          //                         style: const TextStyle(
                                          //                           fontSize: 15.0,
                                          //                           color: Color.fromARGB(
                                          //                               158, 0, 0, 0),
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                   ElevatedButton(
                                          //                       style: ElevatedButton.styleFrom(
                                          //                           foregroundColor: Colors
                                          //                               .blue,
                                          //                           backgroundColor: Colors
                                          //                               .white,
                                          //                           padding:
                                          //                               const EdgeInsets
                                          //                                       .fromLTRB(
                                          //                                   17,
                                          //                                   16,
                                          //                                   17,
                                          //                                   16),
                                          //                           textStyle:
                                          //                               const TextStyle(
                                          //                                   fontSize: 18),
                                          //                           side: BorderSide(
                                          //                               color: Colors.grey
                                          //                                   .shade400,
                                          //                               width: 1)),
                                          //                       child: const Text(
                                          //                           'Add Image'),
                                          //                       onPressed: () {
                                          //                         double latitude =
                                          //                             double.parse(data
                                          //                                     .docs[index]
                                          //                                 ['latitude']);
                                          //                         double longitude =
                                          //                             double.parse(data
                                          //                                     .docs[index]
                                          //                                 ['longitude']);
                                          //                         (Navigator.push(
                                          //                             context,
                                          //                             MaterialPageRoute(
                                          //                               builder: (context) =>
                                          //                                   MapsPage(
                                          //                                       latitude:
                                          //                                           latitude,
                                          //                                       longitude:
                                          //                                           longitude),
                                          //                             )));
                                          //                       }),
                                          //                 ],
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // );
                                        } else {
                                          return const Center(child: Text(''));
                                        }
                                      },
                                    );
                                  } else {
                                    return const Center(child: Text(''));
                                  }
                                });
                          }
                        })))
          ],
        ));
  }
}
