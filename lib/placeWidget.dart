import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class Place extends StatelessWidget {
  Place(
      {Key? key,
      required this.userId,
      required this.category,
      required this.status});
  final userId;
  final category;
  final status;

  @override
  Widget build(BuildContext context) {
    return placesList(category, status, userId);
  }

  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  Widget placesList(String cate, String status, String userId) {
    //Wedd addition / For reem
    commenter = userId;
    var isAdmin = false;
    Stream<QuerySnapshot> list =
        FirebaseFirestore.instance.collection('posts').snapshots();
    if (cate != 'All' && cate != '') {
      //home page
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('category', isEqualTo: cate)
          .snapshots();
    }
    if (status != '' && userId != '') {
      //user profile
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: status)
          .where('userId', isEqualTo: userId)
          .snapshots();
    } else if (status != '') {
      //admin page
      isAdmin = true;
      list = FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: status)
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
                                                              ['docId'],
                                                          isAdmin,
                                                          data.docs[index]
                                                              ['status'])),
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

  Widget buildPlace(placeID, var isAdmin, var status) {
    Place_id = placeID; //Wedd addition / For reem
    print('status $status');
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
                                      Spacer(),
                                      InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade400,
                                              radius: 18,
                                              child: Icon(Icons.arrow_downward,
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
                                      const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                                                          Uri.parse(
                                                              "tel:+9 66553014247"))),
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
                                    isAdmin
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                                Spacer(),
                                                ElevatedButton(
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                          fixedSize: Size(
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
                                                  child: Text('Approve'),
                                                  onPressed: () {}, //!for haifa
                                                ),
                                                SizedBox(width: 15),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      fixedSize: Size(120, 50),
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
                                                  child: Text('Deny'),
                                                  onPressed: () {}, //!for haifa
                                                ),
                                                Spacer(),
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
                                                    TextField(
                                                      //Wedd addition
                                                      controller: comment ,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      autocorrect: true,
                                                      enableSuggestions: true,
                                                      onChanged: (text) {
                                                        // if (_controller.text.trim() != "") {
                                                        //   setIcons(false);
                                                        // } else {
                                                        //   // setIcons(true);
                                                        // }
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        suffixIcon: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IconButton(
                                                                icon: const Icon(
                                                                    Icons.send),
                                                                color: const Color(
                                                                    0xFF39d6ce),
                                                                iconSize: 30,
                                                                onPressed: () {
                                                                  // _controller.text
                                                                  //         .trim()
                                                                  //         .isEmpty
                                                                  //     ? null
                                                                  //     : sendMessage(
                                                                  //         _controller
                                                                  //             .text,
                                                                  //         '',
                                                                  //         '',
                                                                  //         '');
                                                                  // setIcons(true);
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                            ]),
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey.shade50,
                                                        labelText:
                                                            'Share your experiences...',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400)),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                20, 20, 20, 20),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            borderSide: const BorderSide(
                                                                color: const Color(
                                                                    0xFF39d6ce),
                                                                width: 2)),
                                                        floatingLabelStyle:
                                                            const TextStyle(
                                                                fontSize: 22,
                                                                color: Color(
                                                                    0xFF39d6ce)),
                                                        helperStyle:
                                                            const TextStyle(
                                                                fontSize: 14),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 7),
                                                    StreamBuilder<dynamic>(
                                                        // Weddd addition
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Comments")
                                                            .where('PostID',
                                                                isEqualTo:
                                                                    Place_id)
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Text(
                                                                "this post has no comments");
                                                          } else {
                                                            final comment_Data =
                                                                snapshot.data;
                                                            return ListView
                                                                .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const BouncingScrollPhysics(),
                                                                    reverse:
                                                                        true,
                                                                    itemCount:
                                                                        comment_Data!
                                                                            .size,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  10.0,
                                                                              vertical:
                                                                                  16),
                                                                          child:
                                                                              Stack(children: [
                                                                            Container(
                                                                              width: 600,
                                                                              margin: const EdgeInsets.only(top: 12),
                                                                              padding: const EdgeInsets.all(1),
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors
                                                                                      .white,
                                                                                  boxShadow: const [
                                                                                    BoxShadow(blurRadius: 32, color: Colors.black45, spreadRadius: -8)
                                                                                  ],
                                                                                  borderRadius: BorderRadius.circular(15)),
                                                                              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max, children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(8, 1, 1, 1),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(6, 10, 15, 15),
                                                                                          child: Stack(children: [
                                                                                            Align(
                                                                                                alignment: Alignment.topLeft,
                                                                                                child: Container(
                                                                                                    width: 235,
                                                                                                    child: Align(
                                                                                                        alignment: Alignment.topLeft,
                                                                                                        child: Text(
                                                                                                          comment_Data.docs[index]['name'],
                                                                                                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                                                                                                          textAlign: TextAlign.left,
                                                                                                        )))),
                                                                                          ])),
                                                                                      //comment
                                                                                      Align(
                                                                                          alignment: Alignment.topLeft,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(6, 0, 0, 10),
                                                                                            child: Flexible(
                                                                                              child: Text(comment_Data.docs[index]['text'], style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17)),
                                                                                            ),
                                                                                          )),

                                                                                      Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 0),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Text(comment_Data.docs[index]['date'],
                                                                                                      style: const TextStyle(
                                                                                                        fontSize: 13,
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                      )),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Align(
                                                                                                alignment: Alignment.centerRight,
                                                                                                child: Padding(
                                                                                                    padding: const EdgeInsets.only(left: 0),
                                                                                                    child: Visibility(
                                                                                                        visible: comment_Data.docs[index]['UserID'] == commenter,
                                                                                                        child: IconButton(
                                                                                                          iconSize: 30,
                                                                                                          icon: const Icon(
                                                                                                            Icons.delete,
                                                                                                          ),
                                                                                                          onPressed: () {
                                                                                                            //Wedd  addition
                                                                                                            showDialog(
                                                                                                              context: context,
                                                                                                              builder: (ctx) => AlertDialog(
                                                                                                                title: const Text("Are You Sure ?"),
                                                                                                                content: const Text(
                                                                                                                  "Are You Sure You want to delete your comment? , This procces can't be undone",
                                                                                                                  textAlign: TextAlign.center,
                                                                                                                ),
                                                                                                                actions: <Widget>[
                                                                                                                  TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.of(ctx).pop();
                                                                                                                    },
                                                                                                                    child: Container(
                                                                                                                      padding: const EdgeInsets.all(14),
                                                                                                                      child: const Text("cancel"),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      FirebaseFirestore.instance.collection("Comments").doc(comment_Data.docs[index]['commentID']).delete().then((_) {
                                                                                                                        print("success!, document deleted");
                                                                                                                      });
                                                                                                                      Navigator.of(ctx).pop();
                                                                                                                    },
                                                                                                                    child: Container(
                                                                                                                      padding: const EdgeInsets.all(14),
                                                                                                                      child: const Text("Delete", style: TextStyle(color: Color.fromARGB(255, 164, 10, 10))),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            );
                                                                                                          },
                                                                                                        ))))
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                            )
                                                                          ]));
                                                                    });
                                                          }
                                                        }),
                                                  ],
                                                ))
                                            : Text('')),
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

//Wedd addition - every thing below
Future<void> addToDB() async {
  CollectionReference Post_comment =
      FirebaseFirestore.instance.collection('Comments');
  String dataId = '';
  print('will be added to db');
  DocumentReference docReference = await Post_comment.add({
    'commentID': '',
    'date': actualDate,
    //user name
    'name': 'wedd Alhossaiyn',
    'text': comment,
    //user id
    'UserID': commenter,
    //place id
    'PostID': Place_id
  });
  dataId = docReference.id;
  Post_comment.doc(dataId).update({'commentID': dataId});
  print("Document written with ID: ${docReference.id}");
  print('comment added');
  comment.text = '';
  commenter = '';
  Place_id = '';
}

var commenter, commenter_name, Place_id;
var now = DateTime.now();
var formatterDate = DateFormat('MMM d, h:mm a');
String actualDate = formatterDate.format(now);
TextEditingController comment = TextEditingController();
