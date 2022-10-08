import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'mapsPage.dart';

class editRequest extends StatefulWidget {
  final String userType;
  final String reqID;
  // const editRequest({Key? key, required this.userType, required this.reqID})
  //     : super(key: key);
  const editRequest({Key? key, required this.userType, required this.reqID})
      : super(key: key);

  @override
  State<editRequest> createState() => _editRequestState();
}

class _editRequestState extends State<editRequest> {
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  void initState() {
    if (widget.reqID != '') {
      showAlert(this.context);
    }
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold();
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
