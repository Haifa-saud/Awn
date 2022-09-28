import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'mapsPage.dart';
import 'package:intl/intl.dart';

class ViewMyRequistSN extends StatefulWidget {
  @override
  const ViewMyRequistSN({Key? key}) : super(key: key);
  State<ViewMyRequistSN> createState() => _ViewMyRequistState();
}

class _ViewMyRequistState extends State<ViewMyRequistSN> {
  // getData() async {
  //   //print("test3");
  //   final now = DateTime.now();
  //   final today = DateFormat('yyyy/MM/dd').format(now);
  //   print(now);
  //   print(today);
  //   CollectionReference prevRequests =
  //       FirebaseFirestore.instance.collection('requests');
  //   await prevRequests.where('date_ymd', isLessThan: today).get().then((value) {
  //     value.docs.forEach((element) {
  //       print('${element.data()}');
  //       print("======================================");
  //     });
  //   });
  // }

  Stream<QuerySnapshot> getPrevRequets(BuildContext context) async* {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();
    final today = DateFormat('yyyy/MM/dd').format(now);
    //   final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
    //       .collection('requests')
    //       .orderBy("date_ymd")
    //       .snapshots();
    // }
    //using user data
    // yield* FirebaseFirestore.instance
    //     .collection("userData")
    //     .doc(userId)
    //     .collection('requests')
    //     .where('date_ymd', isLessThanOrEqualTo: today)
    //     .orderBy('date_ymd')
    //     .snapshots();
    yield* FirebaseFirestore.instance
        .collection('requests')
        .where('userID', isEqualTo: userId)
        .where('date_ymd', isLessThanOrEqualTo: today)
        .orderBy('date_ymd')
        .snapshots();
  }

  Stream<QuerySnapshot> getUpcomingRequets(BuildContext context) async* {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();
    final today = DateFormat('yyyy/MM/dd').format(now);
    //   final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
    //       .collection('requests')
    //       .orderBy("date_ymd")
    //       .snapshots();
    // }

    yield* FirebaseFirestore.instance
        .collection('requests')
        .where('userID', isEqualTo: userId)
        .where('date_ymd', isGreaterThan: today)
        .orderBy('date_ymd')
        .snapshots();
  }

  bool showPrev = false;
  bool showUpcoming = false;

  /*getMarkerData() async {
    FirebaseFirestore.instance.collection('requests').;
  }*/

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
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                //prev buttom
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.blue,
                        Color(0xFF39d6ce),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showUpcoming = false;
                        showPrev = true;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                ),
                //upcoming buttom
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.blue,
                        Color(0xFF39d6ce),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showPrev = false;
                        showUpcoming = true;
                      });
                    },
                    child: const Text('Upcoming'),
                  ),
                ),
              ]),
              //show prev
              Visibility(
                  visible: showPrev,
                  child: Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: getPrevRequets(context),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot,
                            ) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading');
                              }
                              final data = snapshot.requireData;
                              return ListView.builder(
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: Column(
                                    children: [
                                      //title
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 0, 20, 15),
                                          child: Row(children: [
                                            Text(
                                              ' ${data.docs[index]['title']}',
                                              textAlign: TextAlign.left,
                                            ),
                                          ])),
                                      //date and time
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                                  EdgeInsets.only(left: 40),
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
                                            EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                          padding: EdgeInsets.all(5),
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
                                                  padding: EdgeInsets.all(10),
                                                  side: BorderSide(
                                                      color: Colors.white,
                                                      width: 2)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_pin,
                                                      size: 20,
                                                      color: Colors.red),
                                                  Text('Location',
                                                      style: TextStyle(
                                                          color: Colors.black))
                                                ],
                                              ))),
                                      //show status
                                      // Padding(
                                      //   padding:
                                      //       EdgeInsets.fromLTRB(20, 0, 18, 12),
                                      //   child: Row(
                                      //     children: [
                                      //       Text('Status: ',
                                      //           //   overflow:
                                      //           //   TextOverflow.ellipsis,
                                      //           style: TextStyle(
                                      //               fontSize: 17,
                                      //               fontWeight:
                                      //                   FontWeight.w500)),
                                      //       Padding(
                                      //         padding: EdgeInsets.all(10),
                                      //         child: Text(
                                      //             '${data.docs[index]['status']}',
                                      //             //   overflow:
                                      //             //   TextOverflow.ellipsis,
                                      //             style: TextStyle(
                                      //                 background: Paint()
                                      //                   ..strokeWidth = 20.0
                                      //                   ..color = getColor(
                                      //                       data.docs[index]
                                      //                           ['status'])
                                      //                   ..style =
                                      //                       PaintingStyle.stroke
                                      //                   ..strokeJoin =
                                      //                       StrokeJoin.round,
                                      //                 fontSize: 17,
                                      //                 fontWeight:
                                      //                     FontWeight.w500)),
                                      //       )
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ));
                                },
                              );
                            },
                          )))),
              //show upcoming
              Visibility(
                  visible: showUpcoming,
                  child: Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: getUpcomingRequets(context),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot,
                            ) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading');
                              }
                              final data = snapshot.requireData;
                              return ListView.builder(
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: Column(
                                    children: [
                                      //title
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 0, 20, 15),
                                          child: Row(children: [
                                            Text(
                                              ' ${data.docs[index]['title']}',
                                              textAlign: TextAlign.left,
                                            ),
                                          ])),
                                      //date and time
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                                  EdgeInsets.only(left: 40),
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
                                            EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                          padding: EdgeInsets.all(5),
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
                                                  padding: EdgeInsets.all(10),
                                                  side: BorderSide(
                                                      color: Colors.white,
                                                      width: 2)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_pin,
                                                      size: 20,
                                                      color: Colors.red),
                                                  Text('Location',
                                                      style: TextStyle(
                                                          color: Colors.black))
                                                ],
                                              ))),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 18, 12),
                                        child: Row(
                                          children: [
                                            Text('Status: ',
                                                //   overflow:
                                                //   TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                  '${data.docs[index]['status']}',
                                                  //   overflow:
                                                  //   TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      background: Paint()
                                                        ..strokeWidth = 20.0
                                                        ..color = getColor(
                                                            data.docs[index]
                                                                ['status'])
                                                        ..style =
                                                            PaintingStyle.stroke
                                                        ..strokeJoin =
                                                            StrokeJoin.round,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ));
                                },
                              );
                            },
                          ))))
            ],
          )),
    );
  }
}

Color getColor(String stat) {
  if (stat == 'Approved')
    return Colors.green.shade300;
  else if (stat == 'Pending')
    return Colors.orange.shade300;
  else
    return Colors.white;
}
