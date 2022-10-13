import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mapsPage.dart';

class place extends StatefulWidget {
  final placeID;
  const place({required this.placeID, super.key});

  @override
  _place createState() => _place();
}

class _place extends State<place> with TickerProviderStateMixin {
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

  late final NotificationService notificationService;
  @override
  void initState() {
    data = getPlaceData(widget.placeID);

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
  Future<void> _launchUrl(var _url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return FutureBuilder<Map<String, dynamic>>(
        future: getPlaceData(widget.placeID),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data as Map<String, dynamic>;
            latitude = data['latitude'];
            longitude = data['longitude'];
            isLocSet = latitude == '' ? false : true;
            return Dismissible(
                direction: DismissDirection.up,
                key: const Key('key'),
                onDismissed: (_) => Navigator.of(context).pop(),
                child: Scaffold(
                    body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 50,
                      leading: const Icon(Icons.navigate_before,
                          color: Colors.black),
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(20),
                          child: Container(
                              child: Text(data['name'],
                                  // textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 25)),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0),
                                ),
                              ),
                              width: double.maxFinite,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 25, 0, 0))),
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
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                                                fontWeight: FontWeight.w400),
                                            trimLines: 4,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'View more',
                                            trimExpandedText: 'View less',
                                            moreStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.underline),
                                            lessStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.underline),
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
                                    borderRadius: BorderRadius.circular(15),
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
                                                  future: getLocationAsString(
                                                      double.parse(latitude),
                                                      double.parse(longitude)),
                                                  builder: (context, snap) {
                                                    if (snap.hasData) {
                                                      var reqLoc = snap.data;
                                                      return Row(
                                                        children: [
                                                          const Padding(
                                                              padding:
                                                                  EdgeInsets
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
                                                                        FontWeight
                                                                            .w400,
                                                                    // color: Colors
                                                                    //     .white
                                                                  )))
                                                        ],
                                                      );
                                                    } else {
                                                      return const Text('');
                                                    }
                                                  })),
                                          const SizedBox(height: 30),
                                          /*website*/ Visibility(
                                            visible: data['Website'] != '',
                                            child: InkWell(
                                                child: Row(children: const [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
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
                                                            FontWeight.w400,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        // color: Colors.white
                                                      )),
                                                ]),
                                                onTap: () => launchUrl(
                                                    Uri.parse(
                                                        data['Website']))),
                                          ),
                                          const SizedBox(height: 30),
                                          /*phone number*/ Visibility(
                                            visible: data['Phone number'] != '',
                                            child: InkWell(
                                                child: Row(children: [
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 6, 0),
                                                      child: Icon(
                                                        Icons.call_outlined,
                                                        // color: Colors.white
                                                      )),
                                                  Text(data['Phone number'],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                                      color:
                                                          Colors.blue.shade50),
                                                ),
                                                child: GoogleMap(
                                                  markers: getMarker(
                                                      double.parse(latitude),
                                                      double.parse(longitude)),
                                                  mapType: MapType.normal,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: LatLng(
                                                        double.parse(latitude),
                                                        double.parse(
                                                            longitude)),
                                                    zoom: 12.0,
                                                  ),
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    myController = controller;
                                                  },
                                                )))),
                                  ])),
                              const SizedBox(height: 35),
                              /*comment*/ Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Comments',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
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
                )));
          } else {
            return const Text('');
          }
        });
  }
}
