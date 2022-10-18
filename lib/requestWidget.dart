//

import 'dart:math';

import 'package:awn/addRequest.dart';
import 'package:awn/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'addPost.dart';
import 'editRequest.dart';
import 'mapsPage.dart';
import 'services/appWidgets.dart';
import 'userProfile.dart';

class requestPage extends StatefulWidget {
  final String userType;
  final String reqID;

  const requestPage({Key? key, required this.reqID, required this.userType})
      : super(key: key);

  @override
  State<requestPage> createState() => _requestPageState();
}

class _requestPageState extends State<requestPage> {
  int _selectedIndex = 2;

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
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  color: Colors.grey,
                  height: 1.0,
                ))),
        actions: <Widget>[
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
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
                    }
                    return Container();
                  }))
        ],
        title: const Text('Awn Requests'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        automaticallyImplyLeading: false,
        // actions: <Widget>[
        //   Padding(
        //       padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        //       child: FutureBuilder(
        //           //  future: storage.downloadURL('logo.png'),
        //           builder:
        //               (BuildContext context, AsyncSnapshot<String> snapshot) {
        //         if (snapshot.connectionState == ConnectionState.done &&
        //             snapshot.hasData) {
        //           return Center(
        //             child: Image.network(
        //               snapshot.data!,
        //               fit: BoxFit.cover,
        //               width: 40,
        //               height: 40,
        //             ),
        //           );
        //         }
        //         if (snapshot.connectionState == ConnectionState.waiting ||
        //             !snapshot.hasData) {
        //           return Center(
        //               child: CircularProgressIndicator(
        //             color: Colors.blue,
        //           ));
        //         }
        //         return Container();
        //       }))
        // ],
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
        currentI: 3,
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

    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    final Stream<QuerySnapshot> reqDetails = FirebaseFirestore.instance
        .collection('requests')
        .where('docId', isEqualTo: widget.reqID)
        .snapshots();
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
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
              var duration = data.docs[index]['duration'];
              print('total duration: $duration');

              var dateTime = data.docs[index]['date_ymd'];
              final now = DateTime.now();
              var year = int.parse(dateTime.substring(0, 4));
              var month = int.parse(dateTime.substring(5, 7));
              var day = int.parse(dateTime.substring(8, 10));
              var hours = int.parse(dateTime.substring(11, 13));
              var minutes = int.parse(dateTime.substring(14));
              var requestDate = DateTime(year, month, day, hours, minutes);
              var expirationDate = DateTime(year, month, day, hours, minutes)
                  .add(Duration(
                      hours: int.parse(
                          duration.substring(0, duration.indexOf(':'))),
                      minutes: int.parse(
                          duration.substring(duration.indexOf(':') + 1))));
              isRequestActive = expirationDate.isAfter(now);

              print("expirationDate $expirationDate $isRequestActive");

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
                      durationController.text =
                          data.docs[index]['duration'].toString();
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
                      return Container(
                          width: 600,
                          // margin: const EdgeInsets.only(top: 12),
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
                                  Visibility(
                                      visible: isPending,
                                      child: Row(children: [
                                        InkWell(
                                          onTap: (() {
                                            setState(() {
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
                                                      duartion: data.docs[index]
                                                          ['duration'],
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
                                                size: 30,
                                                color: Colors.blueGrey),
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
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                  ),
                                                  //delete button
                                                  TextButton(
                                                    onPressed: () {
                                                      deletRequest(docId);
                                                      // Navigator.of(
                                                      //         context)
                                                      //     .popUntil(
                                                      //         (route) =>
                                                      //             route.isFirst);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                userProfile(
                                                                    userType: widget
                                                                        .userType),
                                                          ));
                                                      ConfermationDelet();
                                                    },
                                                    child: Container(
                                                      //color: Color.fromARGB(255, 164, 20, 20),
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
                                      ]))
                                ]),
                              ]),
                              SizedBox(height: 30),
                              Row(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceAround,
                                  children: [
                                    /*date*/ Row(children: [
                                      Icon(Icons.calendar_today,
                                          size: 20, color: Colors.red.shade200),
                                      Text(
                                          DateFormat('d MMM, yy')
                                                      .format(requestDate)
                                                      .toString() ==
                                                  DateFormat('d MMM, yy')
                                                      .format(expirationDate)
                                                      .toString()
                                              ? DateFormat(' d MMM, yy')
                                                  .format(requestDate)
                                                  .toString()
                                              : DateFormat(' d MMM, yy')
                                                      .format(requestDate)
                                                      .toString() +
                                                  DateFormat(' - d MMM, yy')
                                                      .format(expirationDate)
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
                                                        .format(expirationDate)
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
                                  // width: 180,
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        9, 5, 9, 5),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    border: Border.all(
                                                      width: 1,
                                                      color:
                                                          Colors.grey.shade100,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    // SizedBox(width: 25),
                                                    Text(
                                                        !isSN
                                                            ? 'Special Need User:'
                                                            : 'Volunteer:',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          // color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        )),
                                                    const SizedBox(height: 7),
                                                    Text(
                                                        ' ${userData!['name']}',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          // color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                    SizedBox(width: 15),
                                                    Visibility(
                                                        visible:
                                                            isRequestActive,
                                                        // child: CircleAvatar(
                                                        //     backgroundColor:
                                                        //         Colors.white,
                                                        //     // .shade200,
                                                        //     // const Color(
                                                        //     //     0xFF39d6ce), //Color(0xffE6E6E6),
                                                        //     radius: 25,
                                                        child: IconButton(
                                                          icon: const Icon(Icons
                                                              .chat_outlined),
                                                          iconSize: 25,
                                                          color: Colors.blue,
                                                          onPressed: () {
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
                                                        )),
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
                              //edit and delete
                              // data.docs[index]['status'] == 'Pending'
                              //     ? Center(
                              //         child: Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.center,
                              //         children: [
                              //           Container(
                              //             // margin: const EdgeInsets.fromLTRB(
                              //             //     10, 10, 10, 10),
                              //             width: 150,
                              //             decoration: BoxDecoration(
                              //               boxShadow: const [
                              //                 BoxShadow(
                              //                     color: Colors.black26,
                              //                     offset: Offset(0, 4),
                              //                     blurRadius: 5.0)
                              //               ],
                              //               gradient: const LinearGradient(
                              //                 begin: Alignment.topLeft,
                              //                 end: Alignment.bottomRight,
                              //                 stops: [0.0, 1.0],
                              //                 colors: [
                              //                   Colors.blue,
                              //                   Color(0xFF39d6ce),
                              //                 ],
                              //               ),
                              //               borderRadius:
                              //                   BorderRadius.circular(30),
                              //             ),
                              //             child: ElevatedButton(
                              //               style: ElevatedButton.styleFrom(
                              //                 textStyle: const TextStyle(
                              //                   fontSize: 18,
                              //                 ),
                              //               ),
                              //               onPressed: () {
                              //                 setState(() {});
                              //               },
                              //               child: const Text('Edit'),
                              //             ),
                              //           ),
                              //           const SizedBox(
                              //             width: 20,
                              //           ),
                              //           Container(
                              //             // margin: const EdgeInsets.fromLTRB(
                              //             //     10, 10, 10, 10),
                              //             width: 150,
                              //             decoration: BoxDecoration(
                              //               boxShadow: const [
                              //                 BoxShadow(
                              //                     color: Colors.black26,
                              //                     offset: Offset(0, 4),
                              //                     blurRadius: 5.0)
                              //               ],
                              //               gradient: const LinearGradient(
                              //                 begin: Alignment.topLeft,
                              //                 end: Alignment.bottomRight,
                              //                 stops: [0.0, 1.0],
                              //                 colors: [
                              //                   Colors.blue,
                              //                   Color(0xFF39d6ce),
                              //                 ],
                              //               ),
                              //               borderRadius:
                              //                   BorderRadius.circular(30),
                              //             ),
                              //             child: ElevatedButton(
                              //               style: ElevatedButton.styleFrom(
                              //                 textStyle: const TextStyle(
                              //                   fontSize: 18,
                              //                 ),
                              //               ),
                              //               onPressed: () {},
                              //               child: const Text('Withdraw'),
                              //             ),
                              //           ),
                              //         ],
                              //       ))
                              //     : SizedBox(),
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
