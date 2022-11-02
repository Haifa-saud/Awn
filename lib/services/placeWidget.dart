import 'package:Awn/addPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../editPost.dart';
import '../userProfile.dart';
import 'appWidgets.dart';
import 'myGlobal.dart' as globals;

class Place extends StatefulWidget {
  Place(
      {Key? key,
      required this.userId,
      required this.category,
      required this.status,
      required this.userName,
      required this.userType,
      this.isSearch = false,
      this.searchList});

  var isSearch;
  var searchList;
  final userId;
  final category;
  final status;
  final userName;
  final userType;

  @override
  State<Place> createState() => PlaceState();
}

class PlaceState extends State<Place> {
  @override
  Widget build(BuildContext context) {
    return placesList(widget.category, widget.status, widget.userId,
        widget.isSearch, widget.searchList);
  }

  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  TextEditingController _searchController = TextEditingController();

  Widget placesList(
      String cate, String status, String userId, isSearch, searchList) {
    // Wedd : add search controller
    var isAdmin = false;
    Stream<QuerySnapshot> list = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'Approved')
        .orderBy('date', descending: true)
        .snapshots();
    if (isSearch) {
      list = searchList;
    } else {
      if (cate != 'All' && cate != '') {
        //home page
        list = FirebaseFirestore.instance
            .collection('posts')
            .where('category', isEqualTo: cate)
            .where('status', isEqualTo: 'Approved')
            .snapshots();
      }
      if (status != '' && userId != '') {
        //user profile
        list = FirebaseFirestore.instance
            .collection('posts')
            .where('status', isEqualTo: status)
            .where('userId', isEqualTo: userId)
            .snapshots();
      }
    }

    var textColor;
    var color;
    if (status == 'Denied') {
      color = Colors.red.shade100;
      textColor = Colors.red.shade200;
    } else if (status == 'Pending') {
      color = Colors.orange.shade100;
      textColor = Colors.orange.shade200;
    } else if (status == 'Approved') {
      color = Colors.green.shade100;
      textColor = Colors.green.shade200;
    } else {
      color = Colors.white;
      textColor = Colors.blue.shade800;
    }

    return Scaffold(
      body: Container(
          height: double.infinity,
          child: Column(
            children: [
              //! places list
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      // color: color,
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
                              return Center(
                                  child: Text(
                                      isSearch
                                          ? 'Your search does not match any place.'
                                          : 'There is no places currently.',
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)));
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
                                            return isSearch &&
                                                    data.docs[index]
                                                            ['status'] !=
                                                        'Approved'
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24,
                                                            right: 24,
                                                            top: 8,
                                                            bottom: 16),
                                                    child: InkWell(
                                                      onTap: () => showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          builder: (context) =>
                                                              buildPlace(
                                                                  data.docs[
                                                                          index]
                                                                      ['docId'],
                                                                  isAdmin,
                                                                  data.docs[
                                                                          index]
                                                                      [
                                                                      'status'])),
                                                      splashColor:
                                                          Colors.transparent,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: color,
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      32,
                                                                  color: Colors
                                                                      .black45,
                                                                  spreadRadius:
                                                                      -8)
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Column(
                                                              children: <
                                                                  Widget>[
                                                                ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              16.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              16.0),
                                                                    ),
                                                                    child:
                                                                        AspectRatio(
                                                                      aspectRatio:
                                                                          2,
                                                                      child: Image
                                                                          .network(
                                                                        data.docs[index]
                                                                            [
                                                                            'img'],
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        errorBuilder: (BuildContext context,
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
                                                                    children: <
                                                                        Widget>[
                                                                      Expanded(
                                                                        child: Container(
                                                                            child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              13,
                                                                              8,
                                                                              0,
                                                                              8),
                                                                          child:
                                                                              Text(
                                                                            data.docs[index]['name'],
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.w600,
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
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            13,
                                                                            0,
                                                                            0,
                                                                            15),
                                                                        child:
                                                                            Text(
                                                                          data.docs[index]
                                                                              [
                                                                              'category'],
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.grey.withOpacity(0.8)),
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
                                            return const Center(
                                                child: Text(''));
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
          )),
    );
  }

  Widget buildPlace(placeID, var isAdmin, var status) {
    bool isPending = status == 'Pending' ? true : false;
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

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
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
                                            style:
                                                const TextStyle(fontSize: 25)),
                                        const Spacer(),
                                        Visibility(
                                          visible: isPending,
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: (() {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => editPost(
                                                            userType:
                                                                widget.userType,
                                                            name: data['name'],
                                                            description: data[
                                                                'description'],
                                                            number: data[
                                                                'Phone number'],
                                                            website:
                                                                data['Website'],
                                                            category: data[
                                                                'category'],
                                                            docId:
                                                                data['docId'],
                                                            oldImg: data['img'],
                                                            latitude: data[
                                                                'latitude'],
                                                            longitude: data[
                                                                'longitude'],
                                                            userId:
                                                                data['userId']),
                                                      ));
                                                }),
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 7),
                                                  child: Icon(Icons.edit,
                                                      size: 30,
                                                      color: Colors.blueGrey),
                                                ),
                                              ),
                                              //delete
                                              InkWell(
                                                onTap: (() {
                                                  String docId = data['docId'];
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title:
                                                          Text("Delete Place?"),
                                                      content: const Text(
                                                        "Are you sure you want to delete your Place ?",
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(14),
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                        ),
                                                        //delete button
                                                        TextButton(
                                                          onPressed: () {
                                                            deletPost(docId);
                                                            Hive.box(
                                                                    "currentPage")
                                                                .put(
                                                                    "RequestId",
                                                                    '');
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => userProfile(
                                                                      userType:
                                                                          widget
                                                                              .userType,
                                                                      selectedTab:
                                                                          2,
                                                                      selectedSubTab:
                                                                          1),
                                                                ));
                                                            // ConfermationDelet();
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(14),
                                                            child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            164,
                                                                            10,
                                                                            10))),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                child: Container(
                                                  // alignment:
                                                  //     Alignment.topRight,
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 7),
                                                  child: Icon(Icons.delete,
                                                      size: 30,
                                                      color:
                                                          Colors.red.shade300),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 5, 15, 30),
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
                                                    textAlign:
                                                        TextAlign.justify,
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
                                                        color: Colors.blue,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        decoration:
                                                            TextDecoration
                                                                .underline),
                                                    lessStyle: const TextStyle(
                                                        color: Colors.blue,
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
                                                    visible:
                                                        data['Phone number'] !=
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
                                                            Uri.parse("tel:" +
                                                                data[
                                                                    'Phone number']))),
                                                  ),
                                                  const SizedBox(height: 50),
                                                ]),
                                            Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        6, 0, 0, 0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.43,
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
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 0,
                                                              color: Colors.blue
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
                                      isAdmin
                                          ? const SizedBox(height: 25)
                                          : const SizedBox(height: 35),
                                      isAdmin
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                  const Spacer(),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            fixedSize: const Size(
                                                                120, 50),
                                                            backgroundColor: Colors
                                                                .green.shade300,
                                                            foregroundColor:
                                                                Colors.white,
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
                                                    child:
                                                        const Text('Approve'),
                                                    onPressed: () {
                                                      String docId =
                                                          data['docId'];
                                                      updateDBA(docId);

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "the place has been approved"),
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
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Comments',
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      CommentField(
                                                          placeID: placeID,
                                                          userID: widget.userId,
                                                          userName:
                                                              widget.userName),
                                                      const SizedBox(height: 7),
                                                      Comments(placeID)
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
          }),
    );
  }

  void ConfermationDelet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Your place has been deleted"),
      ),
    );
  }

  Future<void> deletPost(docId) async {
    final db =
        FirebaseFirestore.instance.collection('posts').doc(docId.toString());
    db.delete();

    ConfermationDelet();
  }

  Widget Comments(placeID) {
    var comments = FirebaseFirestore.instance.collection("Comments");
    return StreamBuilder<dynamic>(
        stream: comments
            .where('placeID', isEqualTo: placeID)
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("This post has no comments");
          } else {
            final comment_Data = snapshot.data;
            return ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemCount: comment_Data.size,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                      child: Stack(children: [
                        Container(
                          width: 600,
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    blurRadius: 32,
                                    color: Colors.black45,
                                    spreadRadius: -8)
                              ],
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(children: [
                                    /*comment*/ Flexible(
                                        child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            comment_Data.docs[index]['text'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 17)),
                                      ),
                                    )),
                                    // Visibility(
                                    //     visible: comment_Data.docs[index]
                                    //             ['UserID'] ==
                                    //         widget.userId,
                                    //     child: Spacer()),
                                    Visibility(
                                        visible: comment_Data.docs[index]
                                                ['UserID'] ==
                                            widget.userId,
                                        child: IconButton(
                                          iconSize: 25,
                                          icon: const Icon(
                                            Icons.delete_forever,
                                          ),
                                          color: Colors.red,
                                          onPressed: () {
                                            //Wedd addition
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    "Delete Comment?"),
                                                content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: const [
                                                      Text(
                                                        "Are You Sure You want to delete your comment?",
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                      Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            "\n*This action can't be undone",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ))
                                                    ]),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              14),
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "Comments")
                                                          .doc(comment_Data
                                                                  .docs[index]
                                                              ['commentID'])
                                                          .delete()
                                                          .then((_) {
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                          (_) => ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: const Text(
                                                                'Comment is deleted'),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            action:
                                                                SnackBarAction(
                                                              label: 'Dismiss',
                                                              disabledTextColor:
                                                                  Colors.white,
                                                              textColor:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                //Do whatever you want
                                                              },
                                                            ),
                                                          )),
                                                        );
                                                        print(
                                                            "success!, document deleted");
                                                      });
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              14),
                                                      child: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      164,
                                                                      10,
                                                                      10))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                  ]),
                                ),
                                /*date, delete*/ Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      /*user name*/ Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 10, 0, 10),
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              comment_Data.docs[index]['name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13),
                                              textAlign: TextAlign.left,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: Text(
                                            DateFormat(', d MMM y, hh:mm a')
                                                .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        comment_Data.docs[index]
                                                            ['date']))
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      // const Spacer(),
                                    ],
                                  ),
                                ),
                              ]),
                        )
                      ]));
                });
          }
        });
  }
}

//! chat text field
class CommentField extends StatefulWidget {
  final placeID, userID, userName;
  const CommentField(
      {required this.placeID,
      required this.userID,
      required this.userName,
      Key? key})
      : super(key: key);

  @override
  State<CommentField> createState() => CommentFieldState();
}

class CommentFieldState extends State<CommentField>
    with SingleTickerProviderStateMixin {
  TextEditingController comment = TextEditingController();

  bool showIcons = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: false,
              controller: comment,
              maxLines: null,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              onChanged: (text) {
                if (comment.text.trim() != "") {
                  setIcons(false);
                } else {
                  setIcons(true);
                }
              },
              decoration: InputDecoration(
                suffixIcon: showIcons
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // IconButton(
                          //   icon: const Icon(Icons.camera_alt_outlined),
                          //   onPressed: () {
                          //     // sendImage(ImageSource.camera);
                          //   },
                          // ),
                          // IconButton(
                          //   icon: const Icon(Icons.insert_photo_outlined),
                          //   onPressed: () {
                          //     // sendImage(ImageSource.gallery);
                          //   },
                          // ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            IconButton(
                              icon: const Icon(Icons.send),
                              color: Colors.blue,
                              iconSize: 30,
                              onPressed: () {
                                comment.text.trim().isEmpty
                                    ? null
                                    : AddCommentToDB();
                                setIcons(true);
                              },
                            ),
                            const SizedBox(width: 10),
                          ]),
                labelText: 'Share your experience...',
                labelStyle: const TextStyle(fontSize: 18),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              ),
            ),
          )
        ]));
  }

  void setIcons(bool isTyping) {
    setState(() {
      showIcons = isTyping;
    });
  }

//! Firebase
  Future<void> sendImage(var imgSource) async {
    // String imagePath = '';
    // File? imageDB;
    // String strImg = '';
    // await Permission.photos.request();
    // var permissionStatus = await Permission.photos.status;
    // if (permissionStatus.isGranted) {
    //   XFile? img = await ImagePicker().pickImage(source: imgSource);
    //   File imagee = File(img!.path);
    //   imagePath = imagee.toString();
    //   imageDB = imagee;
    //   File image = imageDB;
    //   final storage =
    //       FirebaseStorage.instance.ref().child('postsImage/${image}');
    //   strImg = Path.basename(image.path);
    //   UploadTask uploadTask = storage.putFile(image);
    //   TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    //   imagePath = await (await uploadTask).ref.getDownloadURL();
    //   sendMessage('', imagePath, '', '');
    // }
  }

  void AddCommentToDB() async {
    CollectionReference Post_comment =
        FirebaseFirestore.instance.collection('Comments');

    var docReference = await Post_comment.add({
      'UserID': widget.userID,
      'commentID': '',
      'date': DateTime.now().millisecondsSinceEpoch,
      'name': widget.userName,
      'text': comment.text,
      'placeID': widget.placeID
    });

    var dataId = docReference.id;
    Post_comment.doc(dataId).update({'commentID': dataId});
    print("Document written with ID: ${docReference.id}");
    comment.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Comment is added successfully'),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        disabledTextColor: Colors.white,
        textColor: Colors.white,
        onPressed: () {
          //Do whatever you want
        },
      ),
    ));
  }
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
