import 'package:awn/addRequest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import 'editRequest.dart';
import 'map.dart';
import 'mapsPage.dart';

class editRequest extends StatefulWidget {
  final String userType;
  //final String reqID;
  // const editRequest({Key? key, required this.userType, required this.reqID})
  //     : super(key: key);
  const editRequest({Key? key, required this.userType}) : super(key: key);

  @override
  State<editRequest> createState() => _EditRequestState();
}

class _EditRequestState extends State<editRequest> {
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
          title: const Text('Edit Request'),
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

  final _formKey = GlobalKey<FormState>();
//setting up methods
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  DateTime SelectedDateTime = DateTime.now();
  bool showDate = true;
  bool showTime = true;
  bool showDateTime = false;
  var title = '';
  var description = '';
  var duration = '';

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // firstDate: DateTime(2000),
      firstDate: DateTime.now(),
      lastDate: DateTime(2023),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  // Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }
  // select date time picker

  Future _selectDateTime(BuildContext context) async {
    final date = await _selectDate(context);
    if (date == null) return;

    final time = await _selectTime(context);

    if (time == null) return;
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String getDate() {
    // ignore: unnecessary_null_comparison
    if (selectedDate == null) {
      return 'select date';
    } else {
      print(selectedDate);
      //return DateFormat('MMM d, yyyy').format(selectedDate);
      return DateFormat('yyyy/MM/dd').format(selectedDate);
    }
  }

  String getDate_formated() {
    // ignore: unnecessary_null_comparison
    if (selectedDate == null) {
      return 'select date';
    } else {
      print(selectedDate);
      //return DateFormat('MMM d, yyyy').format(selectedDate);
      return DateFormat('dd/MM/yyyy').format(selectedDate);
    }
  }

  String getDateTimeSelected() {
    setState(() {
      SelectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
    return DateFormat('yyyy-MM-dd HH: mm').format(SelectedDateTime);
  }

  String getDateTime() {
    // ignore: unnecessary_null_comparison
    if (dateTime == null) {
      return 'select date timer';
    } else {
      return DateFormat('yyyy-MM-dd HH: mm').format(dateTime);
    }
  }

  String getTime(TimeOfDay tod) {
    final now = DateTime.now();

    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  double checkCurrentTime() {
    DateTime now = DateTime.now();
    final today = DateFormat('dd/MM/yyyy').format(now);
    String selectedday = selectedDate.toString();
    if (selectedDate.isAfter(now)) {
      return -1;
    } else {
      double finalTiemSelected =
          selectedTime.hour.toDouble() + (selectedTime.minute.toDouble() / 60);
      TimeOfDay ST = TimeOfDay.now();

      double finalTimeNow = ST.hour.toDouble() + (ST.minute.toDouble() / 60);
      double _timeDiff = finalTimeNow - finalTiemSelected;

      // String strinf = finalTimeNow.toString() +
      //     " " +
      //     finalTimSelected.toString() +
      //     " " +
      //     _timeDiff.toString();
      return _timeDiff;
    }
  }

  Widget requestdetails() {
    TextEditingController titleController = TextEditingController();
    TextEditingController durationController = TextEditingController();
    TextEditingController descController = TextEditingController();

    bool edit = false;
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
                              return Form(
                                  key: _formKey,
                                  child: Container(
                                      margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                                      decoration: BoxDecoration(
                                          //color: Colors.white,
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
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ///edit

                                          ///title
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 12, 6, 6),
                                            child: Text(
                                              'Title',
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 12, 6, 12),
                                              child: TextFormField(
                                                maxLength: 20,
                                                controller: titleController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'E.g. Help with shopping',
                                                ),
                                                // onChanged: (value) {title = value; },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      (value.trim()).isEmpty) {
                                                    // double s = checkCurrentTime();
                                                    return 'Please enter a title '; //s.toString()
                                                  }
                                                  return null;
                                                },
                                              )),

                                          // time and date
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                6, 35, 6, 6),
                                            child: Text('Time and Date'),
                                          ),

                                          //date picker
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 12, 6, 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _selectDate(context);
                                                    showDate = true;
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                          foregroundColor: Colors
                                                              .blue,
                                                          backgroundColor: Colors
                                                              .white,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  17,
                                                                  16,
                                                                  17,
                                                                  16),
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                          side: BorderSide(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              width: 1)),
                                                  child:
                                                      const Text('Update Date'),
                                                ),
                                                showDate
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            right: 50),
                                                        child: Text(
                                                            getDate_formated()))
                                                    // DateFormat('yyyy/MM/dd').format(selectedDate)
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                          //time picker
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 12, 6, 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _selectTime(context);
                                                      showTime = true;
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            foregroundColor:
                                                                Colors.blue,
                                                            backgroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    17,
                                                                    16,
                                                                    17,
                                                                    16),
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                width: 1)),
                                                    child: const Text(
                                                        'Update Time'),
                                                  ),
                                                  showTime
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 50),
                                                          child: Text(getTime(
                                                              selectedTime)))
                                                      : const SizedBox(),
                                                ],
                                              )),

                                          //duration
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                6, 35, 6, 8),
                                            child: Text('Duration*'),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 8, 6, 12),
                                            child: TextFormField(
                                              controller: durationController,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    'E.g. For about 2 hours',
                                              ),
                                              // onChanged: (value) {duration = value;},
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    (value.trim()).isEmpty) {
                                                  return 'Please enter the duration';
                                                }
                                              },
                                            ),
                                          ),
                                          //description
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                6, 35, 6, 8),
                                            child: Text('Description*',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 8, 6, 12),
                                            child: TextFormField(
                                              controller: descController,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Describe the help in more details',
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                        borderSide: BorderSide(
                                                            color: Colors.grey
                                                                .shade400)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2),
                                                ),
                                              ),

                                              //keyboardType: TextInputType.datetime,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: 3,
                                              maxLength: 150,
                                              onChanged: (value) {
                                                description = value;
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    (value.trim()).isEmpty) {
                                                  return 'Please provide a description';
                                                }
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                6, 35, 6, 8),
                                            child: Text('Location',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 20),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    // String dataId =
                                                    //  docReference.id;
                                                    double latitude =
                                                        double.parse(
                                                            data.docs[index]
                                                                ['latitude']);
                                                    double longitude =
                                                        double.parse(
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors
                                                                  .transparent,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 2)),
                                                  child: Row(
                                                    children: [
                                                      // Icon(Icons.location_pin,
                                                      //     size: 20,
                                                      //     color: Colors.red),
                                                      Flexible(
                                                          child: Text(reqLoc!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17,
                                                              ))),
                                                      InkWell(
                                                        child: Container(
                                                          alignment: Alignment
                                                              .topRight,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5,
                                                                  right: 7),
                                                          // padding: EdgeInsets.only(right: 0),
                                                          child: Text('Edit',
                                                              //   overflow:
                                                              //   TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  background:
                                                                      Paint()
                                                                        ..strokeWidth =
                                                                            20.0
                                                                        ..color =
                                                                            Colors.blueGrey
                                                                        ..style =
                                                                            PaintingStyle.stroke
                                                                        ..strokeJoin =
                                                                            StrokeJoin
                                                                                .round,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                        onTap: (() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => maps(
                                                                    dataId:
                                                                        'M32xPzJr2eeJwuahgpcA',
                                                                    typeOfRequest:
                                                                        'R'),
                                                              ));
                                                        }),
                                                      )
                                                    ],
                                                  ))),
                                          Row(
                                            children: [
                                              /*button*/ Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 20, 10, 20),
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(0, 4),
                                                        blurRadius: 5.0)
                                                  ],
                                                  gradient:
                                                      const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    stops: [0.0, 1.0],
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 122, 146, 166),
                                                      Color.fromARGB(
                                                          255, 83, 100, 99),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    textStyle: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: const Text('Cancel'),
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 20, 10, 20),
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(0, 4),
                                                        blurRadius: 5.0)
                                                  ],
                                                  gradient:
                                                      const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    stops: [0.0, 1.0],
                                                    colors: [
                                                      Colors.blue,
                                                      Color(0xFF39d6ce),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    textStyle: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                            .validate() &&
                                                        checkCurrentTime() <
                                                            0) {
                                                      //   addToDB();
                                                    } else if (checkCurrentTime() >=
                                                        0) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Please select a later time'),
                                                          backgroundColor:
                                                              Colors
                                                                  .red.shade400,
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  8, 0, 20, 0),
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          action:
                                                              SnackBarAction(
                                                            label: 'Dismiss',
                                                            disabledTextColor:
                                                                Colors.white,
                                                            textColor:
                                                                Colors.white,
                                                            onPressed: () {
                                                              //Do whatever you want
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Please fill the required fields above'),
                                                          backgroundColor:
                                                              Colors
                                                                  .red.shade400,
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  8, 0, 20, 0),
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          action:
                                                              SnackBarAction(
                                                            label: 'Dismiss',
                                                            disabledTextColor:
                                                                Colors.white,
                                                            textColor:
                                                                Colors.white,
                                                            onPressed: () {
                                                              //Do whatever you want
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Update'),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ))));
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
