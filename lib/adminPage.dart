import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:Awn/TextToSpeech.dart';
import 'package:Awn/addPost.dart';
import 'package:Awn/addRequest.dart';
import 'package:Awn/login.dart';

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
import 'services/firebase_options.dart';
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
    // userData = readUserData(FirebaseAuth.instance.currentUser!.uid);

    super.initState();
  }

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
          return doc.data() as Map<String, dynamic>;
        },
      );

  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  @override
  Widget build(BuildContext context) {
    //! Logout
    Future<void> _signOut() async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Workmanager().cancelAll();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const login()));
        Future.delayed(const Duration(seconds: 1),
            () async => await FirebaseAuth.instance.signOut());
      });
    }

    print(userData);
    TabController _tabController = TabController(length: 3, vsync: this);

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
                                      color: Color.fromARGB(255, 164, 10, 10))),
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
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: FutureBuilder(
                    future: storage.downloadURL('logo.png'),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                    })),
            // Container(
            //   height: 45,
            //   width: 45,
            //   margin: const EdgeInsets.fromLTRB(8, 12, 10, 0),
            //   child: const CircleAvatar(
            //     backgroundColor:
            //         Color.fromARGB(255, 149, 204, 250), //Color(0xffE6E6E6),
            //     radius: 30,
            //     child: Icon(Icons.person,
            //         size: 35, color: Colors.white //Color(0xffCCCCCC),
            //         ),
            //   ),
            // ),

            Text('Hello, Awn Admin', style: const TextStyle(fontSize: 22)),
          ]),
        ),
        body: Column(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ButtonsTabBar(
              controller: _tabController,
              height: 50,
              radius: 15,
              buttonMargin: const EdgeInsets.fromLTRB(4, 8, 4, 1),
              unselectedDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              unselectedLabelStyle:
                  const TextStyle(color: Colors.white, fontSize: 16),
              labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
              tabs: <Tab>[
                Tab(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: Colors.red.shade300),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    "Denied",
                    style: TextStyle(color: Colors.red.shade300),
                  ),
                )),
                Tab(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(width: 2, color: Colors.orange.shade200),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    "Pending",
                    style: TextStyle(color: Colors.orange.shade200),
                  ),
                )),
                Tab(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: Colors.green.shade300),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    "Approved",
                    style: TextStyle(color: Colors.green.shade300),
                  ),
                )),
              ],
            ),
          ]),
          Expanded(
              child: Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: TabBarView(controller: _tabController, children: [
                    placesList('', 'Denied'),
                    placesList('', 'Pending'),
                    placesList('', 'Approved'),
                  ])))
        ]));
  }

  Widget placesList(String cate, String status) {
    var isAdmin = false;
    Stream<QuerySnapshot> list =
        FirebaseFirestore.instance.collection('posts').snapshots();
    //admin page
    isAdmin = true;
    list = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'Pending')
        .snapshots();

    var color;
    if (status == 'Declined') {
      color = Colors.red.shade100;
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: 'Denied')
          .snapshots();
    } else if (status == 'Pending') {
      color = Colors.orange.shade100;
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: 'Pending')
          .snapshots();
    } else if (status == 'Approved') {
      color = Colors.green.shade100;
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: 'Approved')
          .snapshots();
    } else {
      color = Colors.white;
    }

    return Column(
      children: [
        //! places list
        StreamBuilder<QuerySnapshot>(
            stream: list,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No available posts'));
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: Text('There is no places currently.',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 17))));
              } else {
                final data = snapshot.requireData;
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      if (data.docs[index]['latitude'] != '') {
                        double latitude =
                            double.parse('${data.docs[index]['latitude']}');
                        double longitude =
                            double.parse('${data.docs[index]['longitude']}');

                        return FutureBuilder(
                          future: getLocationAsString(latitude, longitude),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              var reqLoc = snap.data;
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, right: 24, top: 8, bottom: 16),
                                child: InkWell(
                                  onTap: () => showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) => buildPlace(
                                          data.docs[index]['docId'],
                                          isAdmin,
                                          data.docs[index]['status'])),
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: color,
                                        boxShadow: const [
                                          BoxShadow(
                                              blurRadius: 32,
                                              color: Colors.black45,
                                              spreadRadius: -8)
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Stack(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(16.0),
                                                  topRight:
                                                      Radius.circular(16.0),
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 2,
                                                  child: Image.network(
                                                    data.docs[index]['img'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
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
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                        child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          13, 8, 0, 8),
                                                      child: Text(
                                                        data.docs[index]
                                                            ['name'],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(13, 0, 0, 15),
                                                    child: Text(
                                                      data.docs[index]
                                                          ['category'],
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey
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
            })
      ],
    );
  }

  Widget buildPlace(placeID, var isAdmin, var status) {
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
                builder: (_, controller) => Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    child: Stack(children: [
                      const Positioned(
                          width: 50,
                          height: 50,
                          top: 10,
                          left: 10,
                          child:
                              Icon(Icons.navigate_before_outlined, size: 60)),
                      CustomScrollView(
                        controller: controller,
                        slivers: [
                          SliverAppBar(
                            toolbarHeight: 60,
                            automaticallyImplyLeading: false,
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
                                        16, 25, 15, 5),
                                    child: Row(children: [
                                      Text(data['name'],
                                          style: const TextStyle(fontSize: 25)),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade400,
                                              radius: 18,
                                              child: const Icon(
                                                  Icons.arrow_downward,
                                                  color: Colors.white))),
                                    ]))),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 5, 15, 30),
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
                                                  textAlign: TextAlign.justify,
                                                  style: const TextStyle(
                                                      wordSpacing: 2,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  trimLines: 4,
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText:
                                                      'View more',
                                                  trimExpandedText: 'View less',
                                                  moreStyle: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .underline),
                                                  lessStyle: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
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
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                /*location*/ Visibility(
                                                    visible: isLocSet,
                                                    child: FutureBuilder(
                                                        future:
                                                            getLocationAsString(
                                                                double.parse(
                                                                    latitude),
                                                                double.parse(
                                                                    longitude)),
                                                        builder:
                                                            (context, snap) {
                                                          if (snap.hasData) {
                                                            var reqLoc =
                                                                snap.data;
                                                            return Row(
                                                              children: [
                                                                const Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            6,
                                                                            40),
                                                                    child: Icon(
                                                                      Icons
                                                                          .location_on_outlined,
                                                                      size: 25,
                                                                      // color: Colors
                                                                      //     .white
                                                                    )),
                                                                SizedBox(
                                                                    width: 150,
                                                                    child: Text(
                                                                        reqLoc!,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400,
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
                                                      child:
                                                          Row(children: const [
                                                        Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 8, 0),
                                                            child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .globe,
                                                                // color: Colors.white,
                                                                size: 22)),
                                                        Text('Website',
                                                            style: TextStyle(
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
                                                          Uri.parse(data[
                                                              'Website']))),
                                                ),
                                                const SizedBox(height: 30),
                                                /*phone number*/ Visibility(
                                                  visible:
                                                      data['Phone number'] !=
                                                          '',
                                                  child: InkWell(
                                                      child: Row(children: [
                                                        const Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 6, 0),
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
                                                          Uri.parse("tel:" +
                                                              data[
                                                                  'Phone number']))),
                                                ),
                                                const SizedBox(height: 50),
                                              ]),
                                          Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  6, 0, 0, 0),
                                              width: 180,
                                              height: 250,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 5)
                                                ],
                                              ),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 0,
                                                            color: Colors
                                                                .blue.shade50),
                                                      ),
                                                      child: GoogleMap(
                                                        markers: getMarker(
                                                            double.parse(
                                                                latitude),
                                                            double.parse(
                                                                longitude)),
                                                        mapType: MapType.normal,
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
                                    isAdmin
                                        ? const SizedBox(height: 25)
                                        : const SizedBox(height: 35),
                                    status == 'Pending'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                                const Spacer(),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          fixedSize:
                                                              const Size(
                                                                  120, 50),
                                                          backgroundColor:
                                                              Colors.green
                                                                  .shade300,
                                                          foregroundColor: Colors
                                                              .white,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  17,
                                                                  15,
                                                                  17,
                                                                  15),
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade300,
                                                              width: 1)),
                                                  child: const Text('Approve'),
                                                  onPressed: () {
                                                    String docId =
                                                        data['docId'];
                                                    updateDBA(docId);
                                                    Navigator.pushNamed(
                                                        context, '/adminPage');
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "The place has been approved"),
                                                      ),
                                                    );
                                                  }, //!for haifa
                                                ),
                                                const SizedBox(width: 15),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      fixedSize: const Size(
                                                          120, 50),
                                                      backgroundColor: Colors
                                                          .red.shade300,
                                                      foregroundColor: Colors
                                                          .white,
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          17, 15, 17, 15),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 18),
                                                      side: BorderSide(
                                                          color: Colors
                                                              .red.shade300,
                                                          width: 1)),
                                                  child: const Text('Deny'),
                                                  onPressed: () {
                                                    String docId =
                                                        data['docId'];
                                                    updateDBD(docId);
                                                    Navigator.pushNamed(
                                                        context, '/adminPage');
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "the place has been denied"),
                                                      ),
                                                    );
                                                  }, //!for haifa
                                                ),
                                                const Spacer(),
                                              ])
                                        : (status == 'Approved'
                                            ? /*comment*/ Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Comments',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    // CommentField(
                                                    //     placeID: placeID,
                                                    //     userID: widget.userId,
                                                    //     userName:
                                                    //         widget.userName),
                                                    // const SizedBox(height: 7),
                                                    // Comments(placeID)
                                                  ],
                                                ))
                                            : const Text('')),
                                  ]))),
                        ],
                      )
                    ])));
          } else {
            return const Text('');
          }
        });
  }

  Future<void> updateDBA(docId) async {
    final postID = FirebaseFirestore.instance.collection('posts').doc(docId);
    postID.update({
      'status': 'Approved',
    });
  }

  Future<void> updateDBD(docId) async {
    final postID = FirebaseFirestore.instance.collection('posts').doc(docId);
    postID.update({
      'status': 'Denied',
    });
  }
}
