import 'package:Awn/addPost.dart';
import 'package:Awn/mapsPage.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'chatPage.dart';
import 'requestWidget.dart';
import 'services/localNotification.dart';

class viewRequests extends StatefulWidget {
  final String userType;
  String reqID;
  viewRequests({Key? key, required this.userType, this.reqID = ''})
      : super(key: key);

  @override
  State<viewRequests> createState() => _AddRequestState();
}

class _AddRequestState extends State<viewRequests> {
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  NotificationService notificationService = NotificationService();
  @override
  void initState() {
    if (widget.reqID != '') {
      showAlert(this.context);
    }
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        if (payload.substring(0, payload.indexOf('-')) == 'requestAcceptance') {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => requestPage(
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
                  requestID: payload.substring(payload.indexOf('-') + 1)),
              transitionDuration: const Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      viewRequests(userType: 'Volunteer', reqID: payload)));
        }
      });

  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .where('status', isEqualTo: 'Pending')
      .orderBy("date_ymd")
      .snapshots();

  int _selectedIndex = 1;

  Future<void> showAlert(BuildContext context) async {
    var data;
    double latitude = 0, longitude = 0;
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.reqID)
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
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: const EdgeInsets.only(top: 8.0),
              content: FutureBuilder(
                  future: getLocationAsString(latitude, longitude),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      var reqLoc = snap.data;
                      if (invalid) {
                        return Container(
                          width: 450.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: Text("Sorry",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ))),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: Icon(Icons.close),
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 0,
                              ),
                              const Divider(
                                color: Colors.grey,
                                height: 4.0,
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 15, 0, 15),
                                  child: Container(
                                      height: 100,
                                      child: const Center(
                                          child: Text(
                                              'The request has been approved/expired')))),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          width: 450.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text("Someone Needs Help!",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: Icon(Icons.close),
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 0,
                              ),
                              const Divider(
                                color: Colors.grey,
                                height: 4.0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 0, 15),
                                child: Container(
                                  width: 280,
                                  child: Text('${data['title']}',
                                      // textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ),
                              //date and time
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 20,
                                              color: Colors.red.shade200),
                                          Text(' ${data['date_dmy']}',
                                              style: const TextStyle(
                                                fontSize: 17,
                                              )),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: Row(
                                        children: [
                                          Icon(Icons.schedule,
                                              size: 20,
                                              color: Colors.red.shade200),
                                          Text(' ${data['time']}',
                                              style: const TextStyle(
                                                fontSize: 17,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //duration
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 15),
                                child: Row(
                                  children: [
                                    Text('Duration: ${data['duration']}',
                                        style: const TextStyle(fontSize: 17)),
                                  ],
                                ),
                              ),
                              //description
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                          'Description: ${data['description']}',
                                          style: const TextStyle(fontSize: 17)),
                                    ),
                                  ],
                                ),
                              ),
                              //location
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(children: [
                                  Icon(Icons.location_pin,
                                      size: 20, color: Colors.red.shade200),
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
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color:
                                                      Colors.grey.shade500))))
                                ]),
                              ),
                              InkWell(
                                child: Container(
                                  padding:
                                      const EdgeInsets.only(top: 2, bottom: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade200,
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(32.0),
                                        bottomRight: Radius.circular(32.0)),
                                  ),
                                  child: ElevatedButton(
                                    child: const Text(
                                      "Approve",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      String docId = data['docId'];
                                      updateDB(docId);
                                      Confermation();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ));
  }

  int numOFReq = 0;
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
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
                                child: Text('There is no requests currently',
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
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 16),
                                            child: Stack(children: [
                                              InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              requestPage(
                                                            reqID:
                                                                data.docs[index]
                                                                    ['docId'],
                                                            userType:
                                                                widget.userType,
                                                          ),
                                                        ));
                                                  },
                                                  child: Container(
                                                    width: 600,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 12),
                                                    padding:
                                                        const EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                              blurRadius: 32,
                                                              color: Colors
                                                                  .black45,
                                                              spreadRadius: -8)
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    8, 1, 1, 1),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            6,
                                                                            10,
                                                                            15,
                                                                            15),
                                                                    child: Stack(
                                                                        children: [
                                                                          Align(
                                                                              alignment: Alignment.topLeft,
                                                                              child: Container(
                                                                                  width: 235,
                                                                                  child: Align(
                                                                                      alignment: Alignment.topLeft,
                                                                                      child: Text(
                                                                                        '${data.docs[index]['title']}',
                                                                                        style: const TextStyle(
                                                                                          fontWeight: FontWeight.w500,
                                                                                        ),
                                                                                        textAlign: TextAlign.left,
                                                                                      )))),
                                                                        ])),
                                                                // date and time
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          6,
                                                                          20,
                                                                          0,
                                                                          10),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.calendar_today,
                                                                                size: 20,
                                                                                color: Colors.red.shade200),
                                                                            Text(' ${data.docs[index]['date_dmy']}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 17,
                                                                                  fontWeight: FontWeight.w400,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 40),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.schedule,
                                                                                size: 20,
                                                                                color: Colors.red.shade200),
                                                                            Text(' ${data.docs[index]['time']}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 17,
                                                                                  fontWeight: FontWeight.w400,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ]),
                                                  ))
                                            ]));
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
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  addPost(userType: 'Volunteer'),
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
  }
}

Future<void> updateDB(docId) async {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  final postID = FirebaseFirestore.instance.collection('requests').doc(docId);

  postID.update({
    'status': 'Approved',
    'VolID': userId,
  });
}
