import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'ViewMyRequistSN.dart';
// import 'ViewMyRequistVol.dart';
import 'services/firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'main.dart';

class viewRequests extends StatefulWidget {
  const viewRequests({Key? key}) : super(key: key);

  @override
  State<viewRequests> createState() => _AddRequestState();
}

class _AddRequestState extends State<viewRequests> {
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .where('status', isEqualTo: 'Pending')
      .orderBy("date_ymd")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ViewMyRequistSN(),
                  //     ));
                },
                child: const Text("past req special need"),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                    side: BorderSide(color: Colors.grey.shade400, width: 2)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ViewMyRequistVol(),
                  //     ));
                },
                child: const Text("past req volenteer"),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                    side: BorderSide(color: Colors.grey.shade400, width: 2)),
              ),
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
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          var data = snapshot.requireData;
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              var reqLoc;
                              double latitude = double.parse(
                                  '${data.docs[index]['latitude']}');
                              double longitude = double.parse(
                                  '${data.docs[index]['longitude']}');
                              return FutureBuilder(
                                  future:
                                      getLocationAsString(latitude, longitude),
                                  builder: (context, snap) {
                                    if (snap.hasData) {
                                      var reqLoc = snap.data;
                                      return Card(
                                          child: Column(
                                        children: [
                                          //title
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 20, 15),
                                            child: Text(
                                              ' ${data.docs[index]['title']}',
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          //date and time
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 18, 12),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 20,
                                                    color: Colors.red),
                                                Text(
                                                    ' ${data.docs[index]['date_dmy']}',
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 40),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.schedule,
                                                          size: 20,
                                                          color: Colors.red),
                                                      Text(
                                                          ' ${data.docs[index]['time']}',
                                                          style: const TextStyle(
                                                              fontSize: 17,
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
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 0, 12),
                                            child: Row(
                                              children: [
                                                // Icon(Icons.schedule,
                                                //     size: 20, color: Colors.red),
                                                Text(
                                                    'Duration: ${data.docs[index]['duration']}',
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          //description
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 18, 12),
                                            child: Row(
                                              children: [
                                                // Icon(Icons.description,
                                                //     size: 20, color: Colors.red),
                                                Flexible(
                                                  child: Text(
                                                      'Description: ${data.docs[index]['description']}',
                                                      //
                                                      //   TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //location
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    (Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MapsPage(
                                                                  latitude:
                                                                      latitude,
                                                                  longitude:
                                                                      longitude),
                                                        )));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor: Colors
                                                          .grey.shade500,
                                                      backgroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          14, 20, 14, 20),
                                                      side: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 2)),
                                                  child: Text(reqLoc!,
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black)))),
                                          //buttons
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            // width: 150,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      String docId = data
                                                          .docs[index]['docId'];

                                                      updateDB(docId);
                                                      Confermation();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.green.shade400,
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          17, 13, 17, 13),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 17),
                                                    ),
                                                    child: const Text('Accept'),
                                                  ),
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        backgroundColor:
                                                            Colors.red.shade300,
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                17, 13, 17, 13),
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 17),
                                                      ),
                                                      child:
                                                          const Text('Deny')),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ));
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  });
                            },
                          );
                        },
                      )))
            ],
          )),
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

class MapsPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  @override
  const MapsPage({Key? key, required this.latitude, required this.longitude})
      : super(key: key);
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController myController;
  /*getMarkerData() async {
    FirebaseFirestore.instance.collection('requests').;
  }*/

  Widget build(BuildContext context) {
    Set<Marker> getMarker() {
      return <Marker>[
        Marker(
            markerId: const MarkerId(''),
            position: LatLng(widget.latitude, widget.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'Special need location'))
      ].toSet();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Awn Request Location'),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GoogleMap(
          markers: getMarker(),
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            myController = controller;
          },
        ));
  }
}
