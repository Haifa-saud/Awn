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
    print('test' + FirebaseAuth.instance.currentUser!.uid);
    userData = readUserData(FirebaseAuth.instance.currentUser!.uid);
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
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
                                              onTap: () => showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) =>
                                                      buildPlace(
                                                          data.docs[index]
                                                              ['docId'])),
                                              //     Navigator.pushReplacement(
                                              //   context,
                                              //   PageRouteBuilder(
                                              //     pageBuilder: (context,
                                              //             animation1,
                                              //             animation2) =>
                                              //         place(
                                              //       placeID: data.docs[index]
                                              //           ['docId'],
                                              //     ),
                                              //     transitionDuration:
                                              //         const Duration(
                                              //             seconds: 1),
                                              //     reverseTransitionDuration:
                                              //         Duration.zero,
                                              //   ),
                                              // ),
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

  Widget buildPlace(placeID) {
    late GoogleMapController myController;
    Set<Marker> getMarker(lat, lng) {
      return <Marker>{
        Marker(
            markerId: const MarkerId(''),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'location'))
      };
    }

    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    var data, latitude, longitude, isLocSet;
    Future<Map<String, dynamic>> getPlaceData(var id) =>
        FirebaseFirestore.instance.collection('posts').doc(id).get().then(
          (DocumentSnapshot doc) {
            data = doc.data() as Map<String, dynamic>;
            return doc.data() as Map<String, dynamic>;
          },
        );

    return FutureBuilder<Map<String, dynamic>>(
        future: getPlaceData(placeID),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data as Map<String, dynamic>;
            latitude = data['latitude'];
            longitude = data['longitude'];
            isLocSet = latitude == '' ? false : true;
            return DraggableScrollableSheet(
                maxChildSize: 1,
                minChildSize: 0.9,
                initialChildSize: 1,
                builder: (_, controller) =>
                    //  Scaffold(
                    //     backgroundColor: const Color(0xFFfcfffe),
                    //     body:
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        child: Stack(children: [
                          const Positioned(
                              width: 50,
                              height: 50,
                              top: 10,
                              left: 10,
                              child: Icon(Icons.navigate_before_outlined,
                                  size: 60)),
                          CustomScrollView(
                            controller: controller,
                            slivers: [
                              SliverAppBar(
                                toolbarHeight: 50,
                                automaticallyImplyLeading: false,
                                // leading: const Icon(Icons.navigate_before,
                                //     color: Colors.black),
                                bottom: PreferredSize(
                                    preferredSize: const Size.fromHeight(20),
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40.0),
                                            topRight: Radius.circular(40.0),
                                          ),
                                        ),
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 25, 0, 0),
                                        child: Text(data['name'],
                                            style: const TextStyle(
                                                fontSize: 25)))),
                                pinned: true,
                                expandedHeight: 300,
                                flexibleSpace: FlexibleSpaceBar(
                                    background: Image.network(
                                  data['img'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )),
                              ),
                              SliverToBoxAdapter(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 5, 15, 5),
                                      child: Column(children: [
                                        /*category*/ Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data['category'],
                                              style: const TextStyle(
                                                  wordSpacing: 2,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400),
                                            )),
                                        const SizedBox(height: 20),
                                        /*description*/ Visibility(
                                            visible: data['description'] != '',
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('About'),
                                                    const SizedBox(height: 7),
                                                    ReadMoreText(
                                                      data['description'],
                                                      style: const TextStyle(
                                                          wordSpacing: 2,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      trimLines: 4,
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          'View more',
                                                      trimExpandedText:
                                                          'View less',
                                                      moreStyle: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                      lessStyle: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ],
                                                ))),
                                        const SizedBox(height: 35),
                                        /*phone number, website, location*/ Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              border: Border.all(
                                                color: Colors.blue.shade50,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: Row(children: [
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    /*location*/ Visibility(
                                                        visible: isLocSet,
                                                        child: FutureBuilder(
                                                            future: getLocationAsString(
                                                                double.parse(
                                                                    latitude),
                                                                double.parse(
                                                                    longitude)),
                                                            builder: (context,
                                                                snap) {
                                                              if (snap
                                                                  .hasData) {
                                                                var reqLoc =
                                                                    snap.data;
                                                                return Row(
                                                                  children: [
                                                                    const Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            6,
                                                                            40),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .location_on_outlined,
                                                                          size:
                                                                              25,
                                                                          // color: Colors
                                                                          //     .white
                                                                        )),
                                                                    SizedBox(
                                                                        width:
                                                                            150,
                                                                        child: Text(
                                                                            reqLoc!,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              // color: Colors
                                                                              //     .white
                                                                            )))
                                                                  ],
                                                                );
                                                              } else {
                                                                return const Text(
                                                                    '');
                                                              }
                                                            })),
                                                    const SizedBox(height: 30),
                                                    /*website*/ Visibility(
                                                      visible:
                                                          data['Website'] != '',
                                                      child: InkWell(
                                                          child: Row(
                                                              children: const [
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            8,
                                                                            0),
                                                                    child: FaIcon(
                                                                        FontAwesomeIcons
                                                                            .globe,
                                                                        // color: Colors.white,
                                                                        size:
                                                                            22)),
                                                                Text('Website',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                      // color: Colors.white
                                                                    )),
                                                              ]),
                                                          onTap: () => launchUrl(
                                                              Uri.parse(data[
                                                                  'Website']))),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    /*phone number*/ Visibility(
                                                      visible: data[
                                                              'Phone number'] !=
                                                          '',
                                                      child: InkWell(
                                                          child: Row(children: [
                                                            const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            6,
                                                                            0),
                                                                child: Icon(
                                                                  Icons
                                                                      .call_outlined,
                                                                  // color: Colors.white
                                                                )),
                                                            Text(
                                                                data[
                                                                    'Phone number'],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Colors.white
                                                                )),
                                                          ]),
                                                          onTap: () => launchUrl(
                                                              Uri.parse(
                                                                  "tel:+9 66553014247"))),
                                                    ),
                                                    const SizedBox(height: 50),
                                                  ]),
                                              Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 0, 0, 0),
                                                  width: 180,
                                                  height: 250,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 5)
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0,
                                                                color: Colors
                                                                    .blue
                                                                    .shade50),
                                                          ),
                                                          child: GoogleMap(
                                                            markers: getMarker(
                                                                double.parse(
                                                                    latitude),
                                                                double.parse(
                                                                    longitude)),
                                                            mapType:
                                                                MapType.normal,
                                                            initialCameraPosition:
                                                                CameraPosition(
                                                              target: LatLng(
                                                                  double.parse(
                                                                      latitude),
                                                                  double.parse(
                                                                      longitude)),
                                                              zoom: 12.0,
                                                            ),
                                                            onMapCreated:
                                                                (GoogleMapController
                                                                    controller) {
                                                              myController =
                                                                  controller;
                                                            },
                                                          )))),
                                            ])),
                                        const SizedBox(height: 35),
                                        /*comment*/ Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Comments',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2,
                                                  ),
                                                ),
                                                const SizedBox(height: 7),
                                              ],
                                            )),
                                        const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor sit amet elit eu sagittis. Maecenas at tellus convallis, scelerisque nibh id, condimentum dolor. Nullam in ligula ut felis facilisis pellentesque quis tincidunt elit. Suspendisse potenti. Sed ante urna, mollis id justo ut, mollis imperdiet nunc. Aliquam placerat interdum mauris non tempor. Integer ac diam velit. Vestibulum nec nibh dolor. Morbi ex leo, facilisis quis feugiat eget, gravida non tortor. Phasellus id consequat lacus, sed semper augue. Mauris tortor leo, iaculis gravida metus sed, tristique rutrum est' +
                                            'Pellentesque vehicula purus vitae eros scelerisque pretium. Donec in metus placerat nulla mollis scelerisque a et tellus. Aenean quis blandit turpis. Aliquam ultrices nunc ultrices massa rhoncus, sed rutrum tortor hendrerit. Sed pharetra pellentesque lectus, et posuere ex cursus consectetur. In et est faucibus, cursus mauris vel, tincidunt ex. Aenean a odio at enim sodales consectetur gravida euismod orci. Nunc feugiat urna vel sapien vulputate fringilla. Aliquam erat volutpat. Sed posuere a diam in pretium. Nam nec velit at ante ornare pharetra. Vestibulum turpis ipsum, suscipit at euismod at, malesuada in dui. Etiam nec lacus et justo pharetra malesuada eget eu diam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer tincidunt nulla eget purus tincidunt, in euismod augue iaculis. Duis gravida, lectus eget vestibulum suscipit, velit nunc aliquam nibh, et cursus neque velit eu neque.' +
                                            'Donec sit amet lacinia sem, ut facilisis dui. Curabitur nulla diam, maximus et lacus vel, convallis lobortis erat. Maecenas suscipit et nibh eu facilisis. Ut egestas, turpis in porta feugiat, neque nibh dignissim nulla, non molestie quam orci eget massa. Ut scelerisque molestie pulvinar. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis dictum elit quis nibh venenatis auctor. Nullam ut lacus in enim pretium fringilla. Nullam molestie convallis massa at dictum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Integer placerat, erat quis volutpat porttitor, mi felis tincidunt dolor, quis vulputate nulla nibh nec libero. Mauris egestas volutpat mauris iaculis lacinia. Nulla sollicitudin, sem vitae lobortis sagittis, augue felis finibus sapien, a semper dolor sem et mi. Mauris faucibus, ex in pellentesque commodo, nisi nulla viverra est, pellentesque finibus libero odio a turpis.' +
                                            'Nullam dapibus urna mauris, a rutrum diam mollis nec. Cras eu pellentesque nulla, et commodo enim. Integer ac quam id metus fermentum lobortis eu vel nulla. Morbi et nulla sollicitudin, ultrices urna suscipit, consequat risus. Etiam et sapien sem. Aliquam volutpat vestibulum luctus. Etiam convallis facilisis urna, vel dapibus ligula facilisis vel. Nunc non placerat dolor. Nulla sit amet placerat nibh. Etiam laoreet, sem in imperdiet commodo, enim mi posuere mi, at vestibulum eros magna vitae quam. Cras a felis sed ante placerat rutrum. Etiam efficitur orci ligula, ut scelerisque ante pharetra eget. Vestibulum non turpis tincidunt, porttitor neque at, dignissim risus. Duis et posuere orci, eu dictum nunc.' +
                                            'Vivamus dignissim pulvinar neque a tempus. Praesent sodales, ipsum sit amet placerat egestas, sapien leo posuere lacus, non sagittis elit dolor eget ligula. Proin convallis risus mauris, sit amet hendrerit enim suscipit lacinia. Maecenas vitae pellentesque mi. Vivamus lectus arcu, consequat nec mauris in, lacinia lacinia tortor. Mauris porta egestas ligula sed laoreet. Sed finibus ultricies arcu, at lacinia nulla consequat fe'),
                                      ]))),
                            ],
                          )
                        ])));
          } else {
            return const Text('');
          }
        });
  }

}
