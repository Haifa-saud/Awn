import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
                                                              ['docId'])),
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
                            // leading: const Icon(Icons.navigate_before,
                            //     color: Colors.black),
                            bottom: PreferredSize(
                                preferredSize: const Size.fromHeight(20),
                                child: Container(
                                    // padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
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
                                                decoration:
                                                    TextDecoration.underline,
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
