import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'mapsPage.dart';
import 'package:intl/intl.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

String getuid() {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  return userId;
}

Stream<QuerySnapshot> getPrevRequets(BuildContext context) async* {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  final now = DateTime.now();

  final today = DateFormat('yyyy-MM-dd HH: ss').format(now);

  // print(today);
  // final today = DateFormat('yyyy/MM/dd').format(now);
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

String getTime() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd HH: ss').format(now);
}

class ViewMyRequistSN extends StatefulWidget {
  @override
  const ViewMyRequistSN({Key? key}) : super(key: key);
  State<ViewMyRequistSN> createState() => _ViewMyRequistState();
}

class _ViewMyRequistState extends State<ViewMyRequistSN>
    with TickerProviderStateMixin {
  Stream<QuerySnapshot> getUpcomingRequets(BuildContext context) async* {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
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
    TabController _tabController = TabController(length: 2, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
          //  padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonsTabBar(
                    controller: _tabController,
                    decoration: const BoxDecoration(
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
                    radius: 30,
                    borderColor: Colors.white,
                    buttonMargin: const EdgeInsets.fromLTRB(6, 8, 6, 1),
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    unselectedBackgroundColor: Colors.white,
                    labelStyle:
                        const TextStyle(color: Colors.white, fontSize: 15),
                    tabs: const [
                      Tab(text: "Previous"),
                      Tab(text: "Upcoming"),
                    ]),
              ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: []),
          Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height,
            child: TabBarView(controller: _tabController, children: [
              showPrevList(getPrevRequets(context)),
              showUpcomingList(getUpcomingRequets(context))
            ]),
          ),
        ],
      )),
    );
  }

  Widget showUpcomingList(Stream<QuerySnapshot> list) {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();

    final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
    final Stream<QuerySnapshot> ulist = FirebaseFirestore.instance
        .collection('requests')
        .where('userID', isEqualTo: userId)
        .where('date_ymd', isGreaterThan: today)
        .orderBy('date_ymd')
        .snapshots();

    return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: ulist,
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
                    return Card(
                        child: Column(
                      children: [
                        //title
                        Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 15),
                            child: Row(children: [
                              Text(
                                ' ${data.docs[index]['title']}',
                                textAlign: TextAlign.left,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 60),
                                padding: EdgeInsets.all(10),
                                child: Text('${data.docs[index]['status']}',
                                    //   overflow:
                                    //   TextOverflow.ellipsis,
                                    style: TextStyle(
                                        background: Paint()
                                          ..strokeWidth = 20.0
                                          ..color = getColor(
                                              data.docs[index]['status'])
                                          ..style = PaintingStyle.stroke
                                          ..strokeJoin = StrokeJoin.round,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)),
                              )
                            ])),
                        //date and time
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.red),
                              Text(' ${data.docs[index]['date_dmy']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              Padding(
                                padding: EdgeInsets.only(left: 40),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 20, color: Colors.red),
                                    Text(' ${data.docs[index]['time']}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        //duration
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                          child: Row(
                            children: [
                              // Icon(Icons.schedule,
                              //     size: 20, color: Colors.red),
                              Text('Duration: ${data.docs[index]['duration']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        //description
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        //location
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                                onPressed: () {
                                  // String dataId =
                                  //  docReference.id;
                                  double latitude = double.parse(
                                      data.docs[index]['latitude']);
                                  double longitude = double.parse(
                                      data.docs[index]['longitude']);

                                  (Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapsPage(
                                            latitude: latitude,
                                            longitude: longitude),
                                      )));
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white, width: 2)),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_pin,
                                        size: 20, color: Colors.red),
                                    Text('Location',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500))
                                  ],
                                ))),
                      ],
                    ));
                  },
                );
              },
            )));
  }

  Widget showPrevList(Stream<QuerySnapshot> list) {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();

    final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
    final Stream<QuerySnapshot> Plist = FirebaseFirestore.instance
        .collection('requests')
        .where('userID', isEqualTo: userId)
        .where('date_ymd', isLessThanOrEqualTo: today)
        .orderBy('date_ymd')
        .snapshots();

    return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: Plist,
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
                    return Card(
                        child: Column(
                      children: [
                        //title
                        Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 15),
                            child: Row(children: [
                              Text(getStatus(data.docs[index]['status'],
                                  data.docs[index]['docId'])),
                              Container(
                                margin: EdgeInsets.only(left: 60),
                                padding: EdgeInsets.all(10),
                                child: Text('${data.docs[index]['status']}',
                                    //   overflow:
                                    //   TextOverflow.ellipsis,
                                    style: TextStyle(
                                        background: Paint()
                                          ..strokeWidth = 20.0
                                          ..color = getColor(
                                              data.docs[index]['status'])
                                          ..style = PaintingStyle.stroke
                                          ..strokeJoin = StrokeJoin.round,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)),
                              )
                            ])),
                        //date and time
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.red),
                              Text(' ${data.docs[index]['date_dmy']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              Padding(
                                padding: EdgeInsets.only(left: 40),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 20, color: Colors.red),
                                    Text(' ${data.docs[index]['time']}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        //duration
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                          child: Row(
                            children: [
                              // Icon(Icons.schedule,
                              //     size: 20, color: Colors.red),
                              Text('Duration: ${data.docs[index]['duration']}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        //description
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
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
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        //location
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                                onPressed: () {
                                  // String dataId =
                                  //  docReference.id;
                                  double latitude = double.parse(
                                      data.docs[index]['latitude']);
                                  double longitude = double.parse(
                                      data.docs[index]['longitude']);

                                  (Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapsPage(
                                            latitude: latitude,
                                            longitude: longitude),
                                      )));
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white, width: 2)),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_pin,
                                        size: 20, color: Colors.red),
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ))),
                      ],
                    ));
                  },
                );
              },
            )));
  }

  setShowPrev() {
    showPrev = true;
  }

  setShowUpcoming() {
    showPrev = false;
    showUpcoming = true;
  }
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

    final postID = FirebaseFirestore.instance.collection('requests').doc(docId);

    postID.update({
      'status': 'Expired',
    });
    return 'Expired';
  } else
    return stat;
}
