import 'package:awn/addRequest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'editRequest.dart';
import 'mapsPage.dart';

class requestPage extends StatefulWidget {
  final String userType;
  final String reqID;
  // const editRequest({Key? key, required this.userType, required this.reqID})
  //     : super(key: key);
  const requestPage({Key? key, required this.reqID, required this.userType})
      : super(key: key);

  @override
  State<requestPage> createState() => _requestPageState();
}

class _requestPageState extends State<requestPage> {
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
    // editReq() {}
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
                              // var title = data.docs[index]['title'];
                              titleController.text =
                                  data.docs[index]['title'].toString();
                              durationController.text =
                                  data.docs[index]['duration'].toString();
                              descController.text =
                                  data.docs[index]['description'].toString();

                              isPending =
                                  data.docs[index]['status'] == 'Pending'
                                      ? true
                                      : false;
                              isSN = widget.userType == 'Special Need User'
                                  ? true
                                  : false;
                              return Container(
                                  width: 600,
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(1),
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
                                      ///edit

                                      // ///title
                                      // Container(
                                      //   padding: const EdgeInsets.fromLTRB(
                                      //       6, 12, 6, 6),
                                      //   child: Text(
                                      //     'Title',
                                      //     textAlign: TextAlign.left,
                                      //   ),
                                      // ),
                                      // Container(
                                      //     padding: const EdgeInsets.fromLTRB(
                                      //         6, 12, 6, 12),
                                      //     child: TextFormField(
                                      //       maxLength: 20,
                                      //       controller: titleController,
                                      //       decoration: const InputDecoration(
                                      //         hintText:
                                      //             'E.g. Help with shopping',
                                      //       ),
                                      //       // onChanged: (value) {title = value; },
                                      //       validator: (value) {
                                      //         if (value == null ||
                                      //             value.isEmpty ||
                                      //             (value.trim()).isEmpty) {
                                      //           // double s = checkCurrentTime();
                                      //           return 'Please enter a title '; //s.toString()
                                      //         }
                                      //         return null;
                                      //       },
                                      //     )),
                                      // //duration
                                      // Container(
                                      //   padding:
                                      //       EdgeInsets.fromLTRB(6, 35, 6, 8),
                                      //   child: Text('Duration*'),
                                      // ),

                                      // Container(
                                      //   padding: const EdgeInsets.fromLTRB(
                                      //       6, 8, 6, 12),
                                      //   child: TextFormField(
                                      //     controller: durationController,
                                      //     decoration: const InputDecoration(
                                      //       hintText: 'E.g. For about 2 hours',
                                      //     ),
                                      //     // onChanged: (value) {duration = value;},
                                      //     validator: (value) {
                                      //       if (value == null ||
                                      //           value.isEmpty ||
                                      //           (value.trim()).isEmpty) {
                                      //         return 'Please enter the duration';
                                      //       }
                                      //     },
                                      //   ),
                                      // ),

                                      //view

                                      //title
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 15, 15),
                                          child: Stack(children: [
                                            Text(
                                              ' ${data.docs[index]['title']}',
                                              textAlign: TextAlign.left,
                                            ),
                                            Visibility(
                                                visible: isPending,
                                                child: Column(children: [
                                                  InkWell(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      // padding: EdgeInsets.only(right: 0),
                                                      child: Text('Edit',
                                                          //   overflow:
                                                          //   TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              background:
                                                                  Paint()
                                                                    ..strokeWidth =
                                                                        20.0
                                                                    ..color = Colors
                                                                        .blueGrey
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeJoin =
                                                                        StrokeJoin
                                                                            .round,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                    ),
                                                    onTap: (() {
                                                      setState(() {
                                                        // edit = true;
                                                        //  var title;
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => editRequest(
                                                                  userType:
                                                                      "Special Need User",
                                                                  docId: data.docs[
                                                                          index]
                                                                      ['docId'],
                                                                  date_ymd: data
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'date_ymd']),
                                                            ));
                                                      });
                                                      //  editReq();
                                                      //     print(edit);
                                                    }),
                                                  ),
                                                  InkWell(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      // padding: EdgeInsets.only(right: 0),
                                                      child: Text('Delete',
                                                          //   overflow:
                                                          //   TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              background:
                                                                  Paint()
                                                                    ..strokeWidth =
                                                                        20.0
                                                                    ..color = Colors
                                                                        .red
                                                                        .shade300
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeJoin =
                                                                        StrokeJoin
                                                                            .round,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                    ),
                                                    onTap: (() {
                                                      // deletRequest(
                                                      //     docId:
                                                      //         data.docs[index]
                                                      //             ['docId']);

                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            AlertDialog(
                                                          // title: const Text(
                                                          //   "Logout",
                                                          //   textAlign: TextAlign.left,
                                                          // ),
                                                          content: const Text(
                                                            "Are you sure you want to withdraw your request",
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                          actions: <Widget>[
                                                            // cancle button
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        ctx)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(14),
                                                                child: const Text(
                                                                    "Cancel"),
                                                              ),
                                                            ),
                                                            //delete button
                                                            TextButton(
                                                              onPressed: () {
                                                                print(
                                                                    'brefor delet');
                                                                deletRequest(
                                                                    docId: data
                                                                            .docs[
                                                                        index]);
                                                                print(
                                                                    'after delet');
                                                              },
                                                              child: Container(
                                                                //color: Color.fromARGB(255, 164, 20, 20),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(14),
                                                                child: const Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Color.fromARGB(
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
                                                  )
                                                ]))
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
                                                size: 20,
                                                color: Colors.red.shade200),
                                            Text(
                                                ' ${data.docs[index]['date_dmy']}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w400,
                                                )),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 60),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.schedule,
                                                      size: 20,
                                                      color:
                                                          Colors.red.shade300),
                                                  Text(
                                                      ' ${data.docs[index]['time']}',
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                            EdgeInsets.fromLTRB(20, 0, 0, 12),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.schedule,
                                            //     size: 20, color: Colors.red),
                                            Text(
                                                'Duration: ${data.docs[index]['duration']}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w400,
                                                )),
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
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  )),
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
                                                      color:
                                                          Colors.red.shade300),
                                                  Flexible(
                                                      child: Text(reqLoc!,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontSize: 17,
                                                          )))
                                                ],
                                              ))),
                                      // buildTextField(
                                      //     'title', data.docs[index]['title']),
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
    ]);
  }

  Widget myInfo(var userData) {
    var userName = userData['name'];
    bool isVolunteer = false;
    bool isSpecial = false;
    String dis = '';
    if (userData['Type'] == "Volunteer") {
      isVolunteer = true;
    } else {
      isSpecial = true;
      dis = userData['Disability'];
      dis = dis.substring(0, (dis.length - 1));
    }
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        buildTextField('Name', userData['name']),
        buildTextField('Date of Birth', userData['DOB']),
        buildTextField('Gender', userData['gender']),
        buildTextField('Email', userData['Email']),
        buildTextField('Phone Number', userData['phone number']),
        Visibility(
          visible: isVolunteer,
          child: buildTextField('Bio', userData['bio']),
        ),
        Visibility(
            visible: isSpecial, child: buildTextField('Disability', dis)),
      ],
    )));
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
      child: TextField(
        enabled: true,
        maxLength: 180,
        minLines: 1,
        maxLines: 6,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06283D)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}

Future<void> deletRequest({required docId}) async {
  FirebaseFirestore.instance
      .collection('requests')
      .doc(docId.toString())
      .delete();
  print(docId.toString());
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
