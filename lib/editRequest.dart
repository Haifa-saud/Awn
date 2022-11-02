import 'package:Awn/addRequest.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/userProfile.dart';
import 'package:Awn/viewRequests.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:justino_icons/justino_icons.dart';

import 'TextToSpeech.dart';
import 'addPost.dart';
import 'chatPage.dart';
import 'editRequest.dart';
import 'homePage.dart';
import 'map.dart';
import 'mapsPage.dart';
import 'requestWidget.dart';
import 'services/localNotification.dart';

class editRequest extends StatefulWidget {
  final String userType;
  final String docId;
  final String date_ymd;
  final String title;
  final String discription;
  final String endDate;
  //final String reqID;
  // const editRequest({Key? key, required this.userType, required this.reqID})
  //     : super(key: key);
  const editRequest(
      {Key? key,
      required this.userType,
      required this.docId,
      required this.date_ymd,
      required this.title,
      required this.discription,
      required this.endDate})
      : super(key: key);

  @override
  State<editRequest> createState() => _EditRequestState();
}

late TextEditingController titleController;
late TextEditingController durationController = TextEditingController();
late TextEditingController descController;
var isEdited;
//final Storage storage = Storage();

class _EditRequestState extends State<editRequest> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descController = TextEditingController(text: widget.discription);
    isEdited = false;
    // durationController = TextEditingController(text: widget.duartion);
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print(payload.substring(payload.indexOf('-')));
        if (payload.contains('-')) {
          if (payload.substring(0, payload.indexOf('-')) ==
              'requestAcceptance') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => requestPage(
                    fromSNUNotification: true,
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
                    requestID: payload.substring(payload.indexOf('-') + 1),
                    fromNotification: true),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      viewRequests(userType: 'Volunteer', reqID: payload)));
        }
      });

  int _selectedIndex = 2;
  editing(var value) {
    setState(() {
      isEdited = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    var iconList = widget.userType == 'Volunteer'
        ? <IconData, String>{
            Icons.home: 'Home',
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          }
        : <IconData, String>{
            Icons.home: "Home",
            JustinoIcons.getByName('speech') as IconData: "Text to Speech",
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          };

    Future<void> _onItemTapped(int index) async {
      if (widget.userType == 'Special Need User') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = Tts(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = addRequest(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 3) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      } else if (widget.userType == 'Volunteer') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = viewRequests(userType: widget.userType, reqID: '');
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  color: Colors.blue.shade800,
                  height: 1.0,
                ))),
        // actions: <Widget>[
        //   Padding(
        //       padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        //       child: FutureBuilder(
        //           future: storage.downloadURL('logo.png'),
        //           builder:
        //               (BuildContext context, AsyncSnapshot<String> snapshot) {
        //             if (snapshot.connectionState == ConnectionState.done &&
        //                 snapshot.hasData) {
        //               return Center(
        //                 child: Image.network(
        //                   snapshot.data!,
        //                   fit: BoxFit.cover,
        //                   width: 40,
        //                   height: 40,
        //                 ),
        //               );
        //             }
        //             if (snapshot.connectionState == ConnectionState.waiting ||
        //                 !snapshot.hasData) {
        //               return Center(
        //                   child: CircularProgressIndicator(
        //                 color: Colors.blue,
        //               ));
        //             }
        //             return Container();
        //           }))
        // ],
        title: const Text('Edit Request', textAlign: TextAlign.center),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade800),
            onPressed: () {
              if (isEdited) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: const Text(
                      "Discard the changes you made?",
                      textAlign: TextAlign.left,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("Keep editing"),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // int count = 0;
                          var n = Navigator.of(context);
                          n.pop();
                          n.pop();

                          clearForm();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("Discard",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 164, 10, 10))),
                        ),
                      ),
                    ],
                  ),
                );
                // print('alertDialogBack');
              } else {
                Navigator.of(context).pop();
              }
            }),
      ),
      body: requestdetails(),
      floatingActionButton: FloatingActionButton(
        child: Container(
          width: 60,
          height: 60,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
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
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        splashColor: Colors.blue,
        backgroundColor: Colors.white,
        splashRadius: 1,
        splashSpeedInMilliseconds: 100,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          final size = isActive ? 30.0 : 25.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList.keys.toList()[index],
                size: size,
                color: color,
              ),
              const SizedBox(height: 1),
              Visibility(
                visible: isActive,
                child: Text(
                  iconList.values.toList()[index],
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      letterSpacing: 1,
                      wordSpacing: 1),
                ),
              )
            ],
          );
        },
        activeIndex: 3,
        itemCount: widget.userType == 'Volunteer' ? 3 : 4,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  String getDateFromDb() {
    String dateFromDb =
        widget.date_ymd.substring(0, 10).replaceAll(RegExp('[^0-9]'), '');
    print('dateFromDb $dateFromDb');
    return dateFromDb;
    // DateTime dateFromDb = DateTime.parse(d);
  }

  int getHourFromDb() {
    String hour = widget.date_ymd.substring(11, 13);
    print(hour);
    return int.parse(hour);
  }

  int getMinuteFromDb() {
    String min = widget.date_ymd.substring(15, 17);
    print(min);
    return int.parse(min);
  }

  String getEndDateFromDb() {
    String dateFromDb =
        widget.endDate.substring(0, 10).replaceAll(RegExp('[^0-9]'), '');
    print('dateFromDb $dateFromDb');
    return dateFromDb;
    // DateTime dateFromDb = DateTime.parse(d);
  }

  int getEndHourFromDb() {
    String hour = widget.endDate.substring(11, 13);
    print(hour);
    return int.parse(hour);
  }

  int getEndMinuteFromDb() {
    String min = widget.endDate.substring(15, 17);
    print(min);
    return int.parse(min);
  }

  late DateTime selectedDate = DateTime.parse(getDateFromDb());
  late TimeOfDay selectedTime =
      TimeOfDay(hour: getHourFromDb(), minute: getMinuteFromDb());
  DateTime dateTime = DateTime.now();
  DateTime SelectedDateTime = DateTime.now();
  var selectedEndDateTime;

  bool showDate = true;
  bool showTime = true;
  bool showDateTime = false;
  //var title = '';
  var description = '';

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      locale: Localizations.localeOf(context),
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
    print(selectedTime);
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!),
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
    if (selectedDate == null) {
      return 'select date';
    } else {
      return DateFormat('yyyy/MM/dd').format(selectedDate);
    }
  }

  String getDate_formated() {
    if (selectedDate == null) {
      return 'select date';
    } else {
      return DateFormat('MMM dd, yyyy').format(selectedDate);
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

      return _timeDiff;
    }
  }

  double checkEndTime(endDateTime) {
    getDateTimeSelected();
    print(SelectedDateTime);
    DateTime startDate = SelectedDateTime;
    TimeOfDay startTime = selectedTime;
    var end = DateTime.parse(endDateTime);
    print('end $end');
    print('startDate $startDate');
    if (end.isBefore(startDate) || end.isAtSameMomentAs(startDate)) {
      print('-1');
      return -1;
    } else {
      selectedEndDateTime = endDateTime;
      double finalTiemSelected =
          selectedTime.hour.toDouble() + (selectedTime.minute.toDouble() / 60);
      TimeOfDay ST = TimeOfDay.now();

      double finalTimeNow = ST.hour.toDouble() + (ST.minute.toDouble() / 60);
      double _timeDiff = finalTimeNow - finalTiemSelected;

      return _timeDiff;
    }
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

    bool edit = false;
    var selectedDuration;
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    final Stream<QuerySnapshot> reqDetails = FirebaseFirestore.instance
        .collection('requests')
        .where('docId', isEqualTo: widget.docId)
        .snapshots();
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();

    return Column(children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
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
                              selectedDuration = durationController;
                              return Form(
                                key: _formKey,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ///title
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 12, 6, 6),
                                        child: Text(
                                          'Title',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      StatefulBuilder(builder:
                                          (BuildContext context,
                                              void Function(void Function())
                                                  setState) {
                                        return Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 12, 6, 6),
                                            child: TextFormField(
                                                maxLength: 20,
                                                controller: titleController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'E.g. Help with shopping',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      (value.trim()).isEmpty) {
                                                    // double s = checkCurrentTime();
                                                    return 'Please enter a title '; //s.toString()
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  if (titleController.text
                                                          .trim() !=
                                                      '') {
                                                    setState(() {
                                                      isEdited = true;
                                                    });
                                                    // editing(true);
                                                  } else {
                                                    setState(() {
                                                      isEdited = false;
                                                    });
                                                    // editing(false);
                                                  }
                                                }));
                                      }),

                                      // time and date
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 15, 6, 6),
                                        child: Text('Start Time and Date'),
                                      ),

                                      //date picker
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 10, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await _selectDate(context);
                                                  showDate = true;
                                                  await _selectTime(context);
                                                  showTime = true;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    minimumSize: Size(380, 50),
                                                    foregroundColor:
                                                        Colors.black,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        17, 13, 17, 10),
                                                    textStyle: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    side: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width: 1)),
                                                child: showDate
                                                    ? Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Text(
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    letterSpacing:
                                                                        1,
                                                                    wordSpacing:
                                                                        2),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                getDate_formated() +
                                                                    '  -  ' +
                                                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                                                          ],
                                                        ))
                                                    : const SizedBox(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),

                                      //End time
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 35, 6, 6),
                                        child: Text('End Time and Date'),
                                      ),

                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 5, 4, 0),
                                          child: DateTimePicker(
                                            type: DateTimePickerType.dateTime,
                                            initialValue: widget.endDate,
                                            locale:
                                                Localizations.localeOf(context),
                                            initialDate: SelectedDateTime,
                                            initialTime: selectedTime,
                                            firstDate: SelectedDateTime,
                                            lastDate: DateTime(
                                                (SelectedDateTime.year + 1),
                                                SelectedDateTime.month,
                                                SelectedDateTime.day),
                                            // dateLabelText: 'End date and time',
                                            // timeLabelText: 'End Time',
                                            timeFieldWidth: 150,
                                            // use24HourFormat: false,
                                            onChanged: (val) => print(val),
                                            validator: (val) {
                                              print(checkEndTime(val) < 0);
                                              if (val!.isEmpty || val == null) {
                                                return 'Please specify a time and a date.';
                                              } else if (checkEndTime(val) ==
                                                  -1) {
                                                return 'Please specify a time and a date after the start time.';
                                              }
                                              print('val $val');
                                              return null;
                                            },
                                            onSaved: (val) => print(val),
                                          )),

                                      //description
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 35, 6, 8),
                                        child: Text('Description',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),

                                      StatefulBuilder(builder:
                                          (BuildContext context,
                                              void Function(void Function())
                                                  setState) {
                                        return Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 8, 6, 12),
                                          child: TextFormField(
                                            controller: descController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Describe the help in more details',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .grey.shade400)),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
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
                                              if (descController.text.trim() !=
                                                  '') {
                                                setState(() {
                                                  isEdited = true;
                                                });
                                                // editing(true);
                                              } else {
                                                setState(() {
                                                  isEdited = false;
                                                });
                                                // editing(false);
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  (value.trim()).isEmpty) {
                                                return 'Please provide a description';
                                              }
                                            },
                                          ),
                                        );
                                      }),

                                      /*location*/
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 15, 6, 8),
                                        child: Text('Location',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),

                                      Container(
                                          // width: 180,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  child: GoogleMap(
                                                gestureRecognizers: Set()
                                                  ..add(Factory<
                                                          TapGestureRecognizer>(
                                                      () => Gesture(() {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => maps(
                                                                      dataId: data
                                                                              .docs[index]
                                                                          [
                                                                          'docId'],
                                                                      typeOfRequest:
                                                                          'E',
                                                                      latitude: double.parse(
                                                                          data.docs[index]
                                                                              [
                                                                              'latitude']),
                                                                      longitude:
                                                                          double.parse(
                                                                              data.docs[index]['longitude'])),
                                                                ));
                                                          }))),
                                                markers: getMarker(
                                                    latitude, longitude),
                                                mapType: MapType.normal,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: LatLng(
                                                      latitude, longitude),
                                                  zoom: 12.0,
                                                ),
                                                onMapCreated:
                                                    (GoogleMapController
                                                        controller) {
                                                  myController = controller;
                                                },
                                              )))),
                                      /*location*/ Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => maps(
                                                          dataId:
                                                              data.docs[index]
                                                                  ['docId'],
                                                          typeOfRequest: 'E',
                                                          latitude: double.parse(
                                                              data.docs[index]
                                                                  ['latitude']),
                                                          longitude:
                                                              double.parse(data
                                                                          .docs[
                                                                      index][
                                                                  'longitude'])),
                                                    ));
                                              },
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                      // width: 150,
                                                      child: Text(reqLoc!,
                                                          style: TextStyle(
                                                            // color: Colors
                                                            //     .grey.shade500,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            letterSpacing: 0.1,
                                                            wordSpacing: 0.1,
                                                            fontSize: 15,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          )))
                                                ],
                                              ))),
                                      Center(
                                          child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          /*button*/ Container(
                                            width: 150,
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
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                textStyle: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    content: const Text(
                                                      "Discard the changes you made?",
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    actions: <Widget>[
                                                      // cancle button
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(14),
                                                          child: const Text(
                                                              "Keep Editing"),
                                                        ),
                                                      ),
                                                      //ok button
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => userProfile(
                                                                    userType: widget
                                                                        .userType,
                                                                    selectedTab:
                                                                        1,
                                                                    selectedSubTab:
                                                                        1),
                                                              ));
                                                          clearForm();
                                                        },
                                                        child: Container(
                                                          //color: Color.fromARGB(255, 164, 20, 20),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(14),
                                                          child: const Text(
                                                              "Discard",
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
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                10, 20, 10, 20),
                                            width: 150,
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
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Visibility(
                                                //visible: isEdited,
                                                child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                textStyle: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    checkCurrentTime() < 0) {
                                                  updateDB(data.docs[index]
                                                      ['docId']);
                                                  Confermation();
                                                } else if (checkCurrentTime() >=
                                                    0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Please select a later time'),
                                                      backgroundColor:
                                                          Colors.red.shade400,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              8, 0, 20, 0),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      action: SnackBarAction(
                                                        label: 'Dismiss',
                                                        disabledTextColor:
                                                            Colors.white,
                                                        textColor: Colors.white,
                                                        onPressed: () {
                                                          //Do whatever you want
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Please fill the required fields above'),
                                                      backgroundColor:
                                                          Colors.red.shade400,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              8, 0, 20, 0),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      action: SnackBarAction(
                                                        label: 'Dismiss',
                                                        disabledTextColor:
                                                            Colors.white,
                                                        textColor: Colors.white,
                                                        onPressed: () {
                                                          //Do whatever you want
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Update'),
                                            )),
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              );
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

  void Confermation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Awn request has been updated"),
      ),
    );
  }

  Future<void> updateDB(docId) async {
    final postID = FirebaseFirestore.instance.collection('requests').doc(docId);
    print(titleController.text);
    postID.update({
      'title': titleController.text,
      'duration': durationController.text,
      'description': descController.text,
      'date_ymd': getDateTimeSelected(), //getDate
      'date_dmy': getDate_formated(),
      'time': getTime(selectedTime),
      'endDateTime': selectedEndDateTime,
    });
    Navigator.of(context).pop();
    //clearForm();
  }

  void clearForm() {
    titleController.clear();
    durationController.clear();
    descController.clear();
    isEdited = false;
  }

  Future<dynamic> alertDialog(var nav) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          "Discard the changes you made?",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Keep editing"),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => nav,
                  transitionDuration: const Duration(seconds: 1),
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              clearForm();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Discard",
                  style: TextStyle(color: Color.fromARGB(255, 164, 10, 10))),
            ),
          ),
        ],
      ),
    );
  }
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
