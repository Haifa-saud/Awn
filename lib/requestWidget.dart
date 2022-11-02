//

import 'dart:math';

import 'package:Awn/addRequest.dart';
import 'package:Awn/chatPage.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'addPost.dart';
import 'editRequest.dart';
import 'mapsPage.dart';
import 'services/appWidgets.dart';
import 'userProfile.dart';

class requestPage extends StatefulWidget {
  final String userType;
  final String reqID;
  String userID;
  bool fromVolNotification, fromSNUNotification;

  requestPage(
      {Key? key,
      required this.reqID,
      required this.userType,
      this.userID = '',
      this.fromVolNotification = false,
      this.fromSNUNotification = false})
      : super(key: key);

  @override
  State<requestPage> createState() => _requestPageState();
}

class _requestPageState extends State<requestPage> {
  int _selectedIndex = 2;
  var currentUserID;
  NotificationService notificationService = NotificationService();

  @override
  initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    Hive.box("currentPage").put("RequestId", widget.reqID);
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

  Future<Map<String, dynamic>> readUserData(userID) =>
      FirebaseFirestore.instance.collection('users').doc(userID).get().then(
        (DocumentSnapshot doc) {
          return doc.data() as Map<String, dynamic>;
        },
      );

  @override
  Widget build(BuildContext context) {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Awn Request'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade800),
            onPressed: () {
              Hive.box("currentPage").put("RequestId", '');
              if (widget.fromSNUNotification) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        userProfile(
                      userType: 'Special Need User',
                      selectedTab: 1,
                      selectedSubTab: 1,
                    ),
                    transitionDuration: const Duration(seconds: 1),
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else if (widget.fromVolNotification) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        viewRequests(userType: widget.userType),
                    transitionDuration: const Duration(seconds: 1),
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            }),
        automaticallyImplyLeading: false,
      ),
      body: requestdetails(),
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
          Hive.box("currentPage").put("RequestId", '');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  addPost(userType: widget.userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavBar(
        onPress: (int value) => setState(() {
          _selectedIndex = value;
        }),
        userType: widget.userType,
        currentI: widget.userType == 'Volunteer' ? 2 : 3,
      ),
    );
  }

  Widget requestdetails() {
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

    TextEditingController titleController = TextEditingController();
    TextEditingController durationController = TextEditingController();
    TextEditingController descController = TextEditingController();

    bool isPending = false;
    bool isSN = false;
    bool isVol = false;
    bool viewAcceptButtom = true;

    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    final Stream<QuerySnapshot> reqDetails = FirebaseFirestore.instance
        .collection('requests')
        .where('docId', isEqualTo: widget.reqID)
        .snapshots();
    final now = DateTime.now();

    return Column(children: [
      Expanded(
          child: Container(
              child: StreamBuilder<QuerySnapshot>(
        stream: reqDetails,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading');
          }
          final data = snapshot.requireData;
          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var isRequestActive = false;
              var endDateTime = DateTime.parse(data.docs[index]['endDateTime']);
              // print('total duration: $duration');

              var dateTime = data.docs[index]['date_ymd'];
              final now = DateTime.now();
              var year = int.parse(dateTime.substring(0, 4));
              var month = int.parse(dateTime.substring(5, 7));
              var day = int.parse(dateTime.substring(8, 10));
              var hours = int.parse(dateTime.substring(11, 13));
              var minutes = int.parse(dateTime.substring(14));
              var requestDate = DateTime(year, month, day, hours, minutes);
              // var expirationDate = DateTime(year, month, day, hours, minutes)
              //     .add(Duration(
              //         hours: int.parse(
              //             duration.substring(0, duration.indexOf(':'))),
              //         minutes: int.parse(
              //             duration.substring(duration.indexOf(':') + 1))));
              isRequestActive = endDateTime.isAfter(now);

              print("expirationDate $endDateTime $isRequestActive");

              var reqLoc;
              double latitude = double.parse('${data.docs[index]['latitude']}');
              double longitude =
                  double.parse('${data.docs[index]['longitude']}');
              return FutureBuilder(
                  future: getLocationAsString(latitude, longitude),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      var reqLoc = snap.data;
                      // var title = data.docs[index]['title'];
                      titleController.text =
                          data.docs[index]['title'].toString();
                      // durationController.text =
                      //     data.docs[index]['duration'].toString();
                      descController.text =
                          data.docs[index]['description'].toString();

                      isPending = data.docs[index]['status'] == 'Pending'
                          ? true
                          : false;
                      isSN =
                          widget.userType == 'Special Need User' ? true : false;
                      var userID = !isSN
                          ? data.docs[index]['userID']
                          : data.docs[index]['VolID'];

                      isVol = widget.userType == 'Volunteer' ? true : false;

                      return Container(
                          width: 600,
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
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
                            children: [
                              //title and status
                              Row(children: [
                                Row(children: [
                                  Text(
                                    '${data.docs[index]['title']}',
                                    textAlign: TextAlign.left,
                                  ),
                                ]),
                                Spacer(),
                                Visibility(
                                    visible: isPending && isSN,
                                    child: Row(children: [
                                      InkWell(
                                        onTap: (() {
                                          setState(() {
                                            Hive.box("currentPage")
                                                .put("RequestId", '');
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      editRequest(
                                                    userType:
                                                        "Special Need User",
                                                    docId: data.docs[index]
                                                        ['docId'],
                                                    date_ymd: data.docs[index]
                                                        ['date_ymd'],
                                                    discription:
                                                        data.docs[index]
                                                            ['description'],
                                                    endDate: data.docs[index]
                                                        ['endDateTime'],
                                                    title: data.docs[index]
                                                        ['title'],
                                                  ),
                                                ));
                                          });
                                        }),
                                        child: Container(
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7),
                                          child: Icon(Icons.edit,
                                              size: 30, color: Colors.blueGrey),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (() {
                                          String docId =
                                              data.docs[index]['docId'];
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              content: const Text(
                                                "Are you sure you want to withdraw your request ?",
                                                textAlign: TextAlign.left,
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    child: const Text("Cancel"),
                                                  ),
                                                ),
                                                //delete button
                                                TextButton(
                                                  onPressed: () {
                                                    deletRequest(docId);
                                                    Hive.box("currentPage")
                                                        .put("RequestId", '');
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              userProfile(
                                                                  userType: widget
                                                                      .userType,
                                                                  selectedTab:
                                                                      1,
                                                                  selectedSubTab:
                                                                      1),
                                                        ));
                                                    ConfermationDelet();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    child: const Text(
                                                        "Withdraw",
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
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
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7),
                                          child: Icon(Icons.delete,
                                              size: 30,
                                              color: Colors.red.shade300),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ])),
                                Visibility(
                                  visible: isSN,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    margin: const EdgeInsets.only(
                                      top: 5,
                                    ),
                                    child: Text(data.docs[index]['status'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            background: Paint()
                                              ..strokeWidth = 18.0
                                              ..color = getColor(
                                                  data.docs[index]['status'])
                                              ..style = PaintingStyle.stroke
                                              ..strokeJoin = StrokeJoin.round,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ]),
                              SizedBox(height: 30),
                              Row(children: [
                                /*date*/ Row(children: [
                                  Icon(Icons.calendar_today,
                                      size: 20, color: Colors.red.shade200),
                                  Text(
                                      DateFormat('MMM dd, yyyy')
                                                  .format(requestDate)
                                                  .toString() ==
                                              DateFormat('MMM dd, yyyy')
                                                  .format(endDateTime)
                                                  .toString()
                                          ? DateFormat(' MMM dd, yyyy')
                                              .format(requestDate)
                                              .toString()
                                          : DateFormat(' MMM dd, yy')
                                                  .format(requestDate)
                                                  .toString() +
                                              DateFormat(' - MMM dd, yy')
                                                  .format(endDateTime)
                                                  .toString(),
                                      style: const TextStyle(
                                        letterSpacing: 0.1,
                                        wordSpacing: 0.1,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      )),
                                ]),
                                Container(
                                    constraints: BoxConstraints(
                                        minWidth: 15,
                                        maxWidth: double.infinity)),
                                /*time*/ Row(children: [
                                  Icon(Icons.schedule,
                                      size: 20, color: Colors.red.shade200),
                                  Padding(
                                    padding: EdgeInsets.only(left: 0),
                                    child: Row(
                                      children: [
                                        Text(
                                            DateFormat(' hh:mm a ')
                                                    .format(requestDate)
                                                    .toString() +
                                                DateFormat('- hh:mm a')
                                                    .format(endDateTime)
                                                    .toString(),
                                            style: const TextStyle(
                                              letterSpacing: 0.1,
                                              wordSpacing: 0.1,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ],
                                    ),
                                  ),
                                ]),
                              ]),
                              const SizedBox(height: 20),
                              /*location*/ Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: InkWell(
                                      onTap: () {
                                        Hive.box("currentPage")
                                            .put("RequestId", '');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MapsPage(
                                                  latitude: latitude,
                                                  longitude: longitude),
                                            ));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_pin,
                                              size: 20,
                                              color: Colors.red.shade200),
                                          Flexible(
                                              // width: 150,
                                              child: Text(reqLoc!,
                                                  style: TextStyle(
                                                    // color: Colors
                                                    //     .grey.shade500,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.1,
                                                    wordSpacing: 0.1,
                                                    fontSize: 15,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  )))
                                        ],
                                      ))),
                              const SizedBox(height: 30),
                              Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                          child: GoogleMap(
                                        gestureRecognizers: Set()
                                          ..add(Factory<TapGestureRecognizer>(
                                              () => Gesture(() {
                                                    Hive.box("currentPage")
                                                        .put("RequestId", '');

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MapsPage(
                                                                  latitude:
                                                                      latitude,
                                                                  longitude:
                                                                      longitude),
                                                        ));
                                                  }))),
                                        markers: getMarker(latitude, longitude),
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(latitude, longitude),
                                          zoom: 12.0,
                                        ),
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          myController = controller;
                                        },
                                      )))),
                              SizedBox(height: 30),
                              //description
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Description',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          )),
                                      const SizedBox(height: 7),
                                      Text('${data.docs[index]['description']}',
                                          //   overflow:
                                          //   TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          )),
                                    ],
                                  )),
                              SizedBox(height: 20),
                              //User info //mark_unread_chat_alt_outlined
                              data.docs[index]['status'] == 'Approved'
                                  ? FutureBuilder(
                                      future: readUserData(userID),
                                      builder: (context, snap) {
                                        if (snap.hasData) {
                                          var userData = snap
                                              .data; //the other user from request data
                                          return Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                                height: 50,
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    border: Border.all(
                                                      width: 1,
                                                      color:
                                                          Colors.blue.shade50,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                        widget.userType !=
                                                                'Special Need User'
                                                            ? 'Special Need User:'
                                                            : 'Volunteer:',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          wordSpacing: 0.1,
                                                          letterSpacing: 0.1,
                                                        )),
                                                    const SizedBox(height: 7),
                                                    Text(
                                                        ' ${userData!['name']}',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          wordSpacing: 0.1,
                                                          letterSpacing: 0.1,
                                                        )),
                                                    // SizedBox(width: 5),
                                                    Spacer(),
                                                    Visibility(
                                                        visible:
                                                            isRequestActive,
                                                        child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            // .shade200,
                                                            // const Color(
                                                            //     0xFF39d6ce), //Color(0xffE6E6E6),
                                                            radius: 22,
                                                            child: IconButton(
                                                              icon: const Icon(Icons
                                                                  .chat_outlined),
                                                              iconSize: 25,
                                                              color:
                                                                  Colors.blue,
                                                              onPressed: () {
                                                                Hive.box(
                                                                        "currentPage")
                                                                    .put(
                                                                        "RequestId",
                                                                        '');
                                                                Navigator.push(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (context,
                                                                            animation1,
                                                                            animation2) =>
                                                                        ChatPage(
                                                                            requestID:
                                                                                data.docs[index]['docId']),
                                                                    transitionDuration:
                                                                        const Duration(
                                                                            seconds:
                                                                                1),
                                                                    reverseTransitionDuration:
                                                                        Duration
                                                                            .zero,
                                                                  ),
                                                                );
                                                              },
                                                            ))),
                                                  ],
                                                )),
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      })
                                  : SizedBox(height: 0),

                              Visibility(
                                visible: isVol & isPending,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      width: 100,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          String docId =
                                              data.docs[index]['docId'];

                                          updateDB(docId);
                                          Confermation();
                                          // setAccept();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Colors.green.shade400,
                                          padding: const EdgeInsets.fromLTRB(
                                              17, 13, 17, 13),
                                          textStyle:
                                              const TextStyle(fontSize: 17),
                                        ),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  });
            },
          );
        },
      )))
    ]);
  }

  void Confermation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Awn request has been accepted"),
      ),
    );
  }

  Color getColor(String stat) {
    if (stat == 'Approved')
      return Colors.green.shade300;
    else if (stat == 'Pending')
      return Colors.orange.shade300;
    else if (stat == 'Expired')
      return Colors.red.shade300;
    else
      return Colors.white;
  }

  String getStatus(String stat, String docId) {
    if (stat == 'Pending') {
      final user = FirebaseAuth.instance.currentUser!;
      String userId = user.uid;

      final postID =
          FirebaseFirestore.instance.collection('requests').doc(docId);

      postID.update({
        'status': 'Expired',
      });
      return 'Expired';
    }
    return stat;
  }

  void ConfermationDelet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Awn request has been deleted"),
      ),
    );
  }
}

Future<void> deletRequest(docId) async {
  final db =
      FirebaseFirestore.instance.collection('requests').doc(docId.toString());
  db.delete();

  print(docId);
}

Future<void> updateDB(docId) async {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
//String docId=
  final postID = FirebaseFirestore.instance
      // .collection('userData')
      // .doc(userId)
      .collection('requests')
      .doc(docId);

  postID.update({
    'status': 'Approved',
    'VolID': userId,
  });
}

class Gesture extends TapGestureRecognizer {
  Function _test;

  Gesture(this._test);

  @override
  void resolve(GestureDisposition disposition) {
    super.resolve(disposition);
    this._test();
  }

  @override
  // TODO: implement debugDescription
  String get debugDescription => throw UnimplementedError();

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    // TODO: implement isFlingGesture
    throw UnimplementedError();
  }
}
