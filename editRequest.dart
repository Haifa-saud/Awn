import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'mapsPage.dart';

class editRequest extends StatefulWidget {
  //final String userType;
  final String reqID;
  // const editRequest({Key? key, required this.userType, required this.reqID})
  //     : super(key: key);
  const editRequest({Key? key, required this.reqID}) : super(key: key);

  @override
  State<editRequest> createState() => _editRequestState();
}

class _editRequestState extends State<editRequest> {
  @override
  Widget build(BuildContext context) {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    // var data, latitude, longitude, isLocSet;
    // Future<String> getReq(var id) =>
    //     FirebaseFirestore.instance.collection('requests').doc(id).get().then(
    //       (DocumentSnapshot doc) {
    //         //data = doc.data() as Map<String, dynamic>;
    //         return doc.data() as req<String>;
    //       },
    //     );

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
          title: const Text('Awn Requests'),
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
        body: requestdetails());
  }

  Widget requestdetails() {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    final Stream<QuerySnapshot> reqDetails = FirebaseFirestore.instance
        .collection('requests')
        .where('docId', isEqualTo: 'M32xPzJr2eeJwuahgpcA')
        .snapshots();
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();

    return Column(children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                      var reqLoc;
                      double latitude =
                          double.parse('${data.docs[index]['latitude']}');
                      double longitude =
                          double.parse('${data.docs[index]['longitude']}');
                      return FutureBuilder(
                          future: getLocationAsString(latitude, longitude),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              var reqLoc = snap.data;
                              return Container(
                                  margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                                  decoration: BoxDecoration(
                                      //color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            blurRadius: 32,
                                            color: Colors.black45,
                                            spreadRadius: -8)
                                      ],
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Card(
                                      child: Column(
                                    children: [
                                      //title
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 15, 15),
                                          child: Stack(children: [
                                            Text(
                                              ' ${data.docs[index]['title']}',
                                              textAlign: TextAlign.left,
                                            ),
                                            InkWell(
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                margin: EdgeInsets.only(top: 5),
                                                // padding: EdgeInsets.only(right: 0),
                                                child: Text('Edit',
                                                    //   overflow:
                                                    //   TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        background: Paint()
                                                          ..strokeWidth = 20.0
                                                          ..color =
                                                              Colors.blueGrey
                                                          ..style =
                                                              PaintingStyle
                                                                  .stroke
                                                          ..strokeJoin =
                                                              StrokeJoin.round,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                              onTap: (() {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          editRequest(
                                                        reqID: data.docs[index]
                                                            ['docId'],
                                                      ),
                                                    ));
                                              }),
                                            )
                                          ])),
                                      // Container(
                                      //   alignment: Alignment.topRight,
                                      //   margin: EdgeInsets.only(top: 5),
                                      //   // padding: EdgeInsets.only(right: 0),
                                      //   child: Text('Withdraw',
                                      //       //   overflow:
                                      //       //   TextOverflow.ellipsis,
                                      //       style: TextStyle(
                                      //           color: Colors.white,
                                      //           background: Paint()
                                      //             ..strokeWidth = 20.0
                                      //             ..color = Colors.red
                                      //             ..style = PaintingStyle.stroke
                                      //             ..strokeJoin =
                                      //                 StrokeJoin.round,
                                      //           fontSize: 17,
                                      //           fontWeight: FontWeight.w500)),
                                      // ),
                                      //date and time
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 0, 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 20, color: Colors.red),
                                            Text(
                                                ' ${data.docs[index]['date_dmy']}',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 60),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.schedule,
                                                      size: 20,
                                                      color: Colors.red),
                                                  Text(
                                                      ' ${data.docs[index]['time']}',
                                                      style: TextStyle(
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
                                            EdgeInsets.fromLTRB(20, 0, 0, 12),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.schedule,
                                            //     size: 20, color: Colors.red),
                                            Text(
                                                'Duration: ${data.docs[index]['duration']}',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      //description
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 0, 5),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.description,
                                            //     size: 20, color: Colors.red),
                                            Flexible(
                                              child: Text(
                                                  'Description: ${data.docs[index]['description']}',
                                                  //   overflow:
                                                  //   TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //location
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                // String dataId =
                                                //  docReference.id;
                                                double latitude = double.parse(
                                                    data.docs[index]
                                                        ['latitude']);
                                                double longitude = double.parse(
                                                    data.docs[index]
                                                        ['longitude']);

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
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.white,
                                                  side: BorderSide(
                                                      color: Colors.white,
                                                      width: 2)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_pin,
                                                      size: 20,
                                                      color: Colors.red),
                                                  Flexible(
                                                      child: Text(reqLoc!,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontSize: 17,
                                                          )))
                                                ],
                                              ))),
                                    ],
                                  )));
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          });
                    },
                  );
                },
              )))
    ]);
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
