import 'package:awn/addPost.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'main.dart';

class viewRequests extends StatefulWidget {
  final String userType;
  final String reqID;
  const viewRequests({Key? key, required this.userType, required this.reqID})
      : super(key: key);

  @override
  State<viewRequests> createState() => _AddRequestState();
}

class _AddRequestState extends State<viewRequests> {
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  @override
  void initState() {
    if (widget.reqID != '') {
      showAlert(this.context);
    }
    super.initState();
  }

  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .where('status', isEqualTo: 'Pending')
      .where('date_ymd',
          isGreaterThanOrEqualTo:
              DateFormat('yyyy-MM-dd HH: mm').format(DateTime.now()))
      .orderBy("date_ymd")
      .snapshots();

  int _selectedIndex = 1;

  Future<void> showAlert(BuildContext context) async {
    var data;
    double latitude = 0, longitude = 0;
    await FirebaseFirestore.instance
        .collection('requests')
        .doc('dpP8lm4DiqS5PhdLCn8F')
        .get()
        .then((doc) {
      data = doc.data();
      latitude = double.parse('${data['latitude']}');
      longitude = double.parse('${data['longitude']}');
    });
    bool invalid = (data['status'] != 'Pending') ? true : false;
    String title = invalid ? 'Sorry' : "Someone Needs Help!";
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              icon: Icon(Icons.add),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              content: FutureBuilder(
                  future: getLocationAsString(latitude, longitude),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      var reqLoc = snap.data;
                      if (invalid) {
                        return Container(
                            height: 100,
                            child: const Center(
                                child: Text(
                                    'The request has been approved/expired')));
                      } else {
                        return Container(
                            width: 450,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //title
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Container(
                                    width: 280,
                                    child: Text(
                                      '${data['title']}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                //date and time
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 20, color: Colors.red),
                                      Text(' ${data['date_dmy']}',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                size: 20, color: Colors.red),
                                            Text(' ${data['time']}',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //duration
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    children: [
                                      Text('Duration: ${data['duration']}',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                //description
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                            'Description: ${data['description']}',
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ),
                                // location
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(children: [
                                    const Icon(Icons.location_pin,
                                        size: 20, color: Colors.red),
                                    ElevatedButton(
                                        onPressed: () {
                                          (Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MapsPage(
                                                    latitude: latitude,
                                                    longitude: longitude),
                                              )));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade500,
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.fromLTRB(
                                              1, 0, 1, 0),
                                        ),
                                        child: Container(
                                            width: 255,
                                            child: Text(reqLoc!,
                                                style: const TextStyle(
                                                    color: Colors.black))))
                                  ]),
                                ),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 20.0, bottom: 20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(32.0),
                                          bottomRight: Radius.circular(32.0)),
                                    ),
                                    child: Text(
                                      "Rate Product",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ));
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red.shade300,
                      padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    child: const Text('Discard')),
                Visibility(
                  visible: !(invalid),
                  child: ElevatedButton(
                    onPressed: () {
                      String docId = data['docId'];
                      updateDB(docId);
                      Confermation();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green.shade200,
                      padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ));
  }

  int numOFReq = 0;
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 8, 0),
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
                      return const CircularProgressIndicator();
                    }
                    return Container();
                  }))
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: requests,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading');
                          }
                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text(
                                    'There is no pending requests currently',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 17)));
                          }
                          final data = snapshot.requireData;
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              numOFReq = data.size;
                              if (numOFReq > 0) {
                                var reqLoc;
                                double latitude = double.parse(
                                    '${data.docs[index]['latitude']}');
                                double longitude = double.parse(
                                    '${data.docs[index]['longitude']}');
                                bool description =
                                    data.docs[index]['description'] == ''
                                        ? false
                                        : true;
                                return FutureBuilder(
                                    future: getLocationAsString(
                                        latitude, longitude),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        var reqLoc = snap.data;
                                        return Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                5, 12, 5, 0),
                                            decoration: BoxDecoration(
                                                boxShadow: const [
                                                  BoxShadow(
                                                      blurRadius: 32,
                                                      color: Colors.black45,
                                                      spreadRadius: -8)
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Card(
                                                child: Column(
                                              children: [
                                                //title
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 20, 15),
                                                  child: Text(
                                                    ' ${data.docs[index]['title']}',
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                //date and time
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          25, 0, 18, 12),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_today,
                                                          size: 20,
                                                          color: Colors.red),
                                                      Text(
                                                          ' ${data.docs[index]['date_dmy']}',
                                                          style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 40),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.schedule,
                                                                size: 20,
                                                                color:
                                                                    Colors.red),
                                                            Text(
                                                                ' ${data.docs[index]['time']}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                //duration
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          25, 0, 0, 12),
                                                  child: Row(
                                                    children: [
                                                      // Icon(Icons.schedule,
                                                      //     size: 20, color: Colors.red),
                                                      Text(
                                                          'Duration: ${data.docs[index]['duration']}',
                                                          style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                    visible: description,
                                                    child: Theme(
                                                        data: Theme.of(context)
                                                            .copyWith(
                                                                dividerColor: Colors
                                                                    .transparent),
                                                        child: ExpansionTile(
                                                            title: const Text(
                                                              'View more',
                                                              style: TextStyle(
                                                                fontSize: 15.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            children: [
                                                              //description
                                                              Visibility(
                                                                  visible:
                                                                      description,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            25,
                                                                            0,
                                                                            18,
                                                                            12),
                                                                    child: Row(
                                                                      children: [
                                                                        // Icon(Icons.description,
                                                                        //     size: 20, color: Colors.red),
                                                                        Flexible(
                                                                          child: Text(
                                                                              'Description: ${data.docs[index]['description']}',
                                                                              //   overflow:
                                                                              //   TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                              //location
                                                              Visibility(
                                                                visible:
                                                                    description,
                                                                child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          // String dataId =
                                                                          //  docReference.id;
                                                                          double
                                                                              latitude =
                                                                              double.parse(data.docs[index]['latitude']);
                                                                          double
                                                                              longitude =
                                                                              double.parse(data.docs[index]['longitude']);

                                                                          (Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => MapsPage(latitude: latitude, longitude: longitude),
                                                                              )));
                                                                        },
                                                                        style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2)),
                                                                        child: Row(
                                                                          children: [
                                                                            const Icon(Icons.location_pin,
                                                                                size: 20,
                                                                                color: Colors.red),
                                                                            Flexible(
                                                                                child: Text(reqLoc!,
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey.shade500,
                                                                                      fontSize: 17,
                                                                                    )))
                                                                          ],
                                                                        ))),
                                                              ),
                                                              //buttoms
                                                              Visibility(
                                                                visible:
                                                                    description,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(20),
                                                                  // width: 150,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                        margin: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5),
                                                                        width:
                                                                            100,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            String
                                                                                docId =
                                                                                data.docs[index]['docId'];

                                                                            updateDB(docId);
                                                                            Confermation();
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            backgroundColor:
                                                                                Colors.green.shade400,
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                17,
                                                                                13,
                                                                                17,
                                                                                13),
                                                                            textStyle:
                                                                                const TextStyle(fontSize: 17),
                                                                          ),
                                                                          child:
                                                                              const Text('Accept'),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ]))),
                                              ],
                                            )));
                                      } else {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                    });
                              } else {
                                return const Center(
                                    child: Text('No available requests'));
                              }
                            },
                          );
                        },
                      ))),
            ],
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
          showAlert(this.context);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => addPost(userType: 'Volunteer')));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavBar(
        onPress: (int value) => setState(() {
          _selectedIndex = value;
        }),
        userType: 'Volunteer',
        currentI: 1,
      ),
    );
  }

  void Confermation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Awn request has been accepted"),
      ),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MyHomePage()),
    // );

    // Navigator.of(context).popUntil((route) => route.isFirst);
  }
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
