import 'package:Awn/addPost.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/viewRequests.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'chatPage.dart';
import 'main.dart';
import 'package:Awn/map.dart';

import 'requestWidget.dart';
import 'services/localNotification.dart';

//! bottom bar done
class addRequest extends StatefulWidget {
  final String userType;
  const addRequest({Key? key, required this.userType}) : super(key: key);

  @override
  State<addRequest> createState() => _AddRequestState();
}

TextEditingController titleController = TextEditingController();
TextEditingController durationController = TextEditingController();
TextEditingController descController = TextEditingController();
final Storage storage = Storage();

void clearForm() {
  titleController.clear();
  durationController.clear();
  descController.clear();
}

class _AddRequestState extends State<addRequest> {
  int _selectedIndex = 2;

  NotificationService notificationService = NotificationService();
  @override
  void initState() {
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
                  requestID: payload.substring(payload.indexOf('-') + 1),
                  fromNotification: true),
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
        title: const Text('Request Awn', textAlign: TextAlign.center),
      ),
      body: AwnRequestForm(),
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
      bottomNavigationBar: BottomNavBar(
        onPress: (int value) => setState(() {
          _selectedIndex = value;
        }),
        userType: widget.userType,
        currentI: 2,
      ),
    );
  }
}

class AwnRequestForm extends StatefulWidget {
  AwnRequestFormState createState() {
    return AwnRequestFormState();
  }
}

class AwnRequestFormState extends State<AwnRequestForm> {
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

  var selectedDuration;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            Container(
                child: Text(
              '*indicates required fields',
              style: TextStyle(fontSize: 15),
            )),

            /*title*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
              child: Text('What help do you need?*'),
            ),

            Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: TextFormField(
                  maxLength: 20,
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'E.g. Help with shopping',
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
              padding: EdgeInsets.fromLTRB(6, 35, 6, 6),
              child: Text('Time and Date'),
            ),

            //date picker
            Row(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                        showDate = true;
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          side: BorderSide(
                              color: Colors.grey.shade400, width: 1)),
                      child: showDate
                          ? Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Text(getDate_formated()
                                        //   data.docs[index]
                                        //    ['date_dmy']
                                        )),
                                Icon(Icons.calendar_today,
                                    size: 25, color: Colors.grey.shade600),
                              ],
                            )
                          : const SizedBox(),
                      //  const Text('Edit Date'),
                    ),
                  ],
                ),
              ),
              //time picker
              Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectTime(context);
                        showTime = true;
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          side: BorderSide(
                              color: Colors.grey.shade400, width: 1)),
                      child: showDate
                          ? Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Text(getTime(selectedTime)
                                        //   data.docs[index]
                                        //    ['date_dmy']
                                        )),
                                Icon(Icons.schedule,
                                    size: 25, color: Colors.grey.shade600),
                              ],
                            )
                          : const SizedBox(),
                      //  const Text('Edit Date'),
                    ),
                  ],
                ),
              )
            ]),

            //duration
            Container(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 8),
              child: Text('Duration*'),
            ),

            Container(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
                child: TextFormField(
                  readOnly: true,
                  controller: durationController,
                  onTap: () async {
                    selectedDuration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(minutes: 0),
                        snapToMins: 5.0);
                    String twoDigits(int n) => n.toString().padLeft(0);
                    durationController.text =
                        '${twoDigits(selectedDuration!.inHours.remainder(60))}:${twoDigits(selectedDuration.inMinutes.remainder(60))}';
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.schedule, size: 25),
                      onPressed: () async {
                        selectedDuration = await showDurationPicker(
                            context: context,
                            initialTime: const Duration(minutes: 0),
                            snapToMins: 5.0);
                        String twoDigits(int n) => n.toString().padLeft(0);
                        durationController.text =
                            '${twoDigits(selectedDuration!.inHours.remainder(60))}:${twoDigits(selectedDuration.inMinutes.remainder(60))}';
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        (value.trim()).isEmpty) {
                      return 'Please specify a duration';
                    }
                  },
                )),

            //description
            Container(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 8),
              child: Text('Description*',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
              child: TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Describe the help in more details',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),

                //keyboardType: TextInputType.datetime,
                keyboardType: TextInputType.multiline,
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

            /*button*/ Container(
              margin: const EdgeInsets.fromLTRB(60, 10, 50, 10),
              width: 300,
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
                  // if (checkCurrentTime() >= 0) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text('Please select a later time'),
                  //       backgroundColor: Colors.red.shade400,
                  //       margin: EdgeInsets.fromLTRB(8, 0, 20, 0),
                  //       behavior: SnackBarBehavior.floating,
                  //       action: SnackBarAction(
                  //         label: 'Dismiss',
                  //         disabledTextColor: Colors.white,
                  //         textColor: Colors.white,
                  //         onPressed: () {
                  //           //Do whatever you want
                  //         },
                  //       ),
                  //     ),
                  //   );
                  // }
                  if (_formKey.currentState!.validate() &&
                      checkCurrentTime() < 0) {
                    addToDB();
                  } else if (checkCurrentTime() >= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a later time'),
                        backgroundColor: Colors.red.shade400,
                        margin: EdgeInsets.fromLTRB(8, 0, 20, 0),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Dismiss',
                          disabledTextColor: Colors.white,
                          textColor: Colors.white,
                          onPressed: () {
                            //Do whatever you want
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill the required fields above'),
                        backgroundColor: Colors.red.shade400,
                        margin: EdgeInsets.fromLTRB(8, 0, 20, 0),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Dismiss',
                          disabledTextColor: Colors.white,
                          textColor: Colors.white,
                          onPressed: () {
                            //Do whatever you want
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToDB() async {
    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;

    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    DocumentReference docReference = await requests.add({
      'title': titleController.text,
      'date_ymd': getDateTimeSelected(), //getDate
      'date_dmy': getDate_formated(),
      'time': getTime(selectedTime),
      'duration': durationController.text,
      'description': descController.text,
      'latitude': '',
      'longitude': '',
      'status': 'Pending',
      'docId': '',
      'userID': userId,
      'VolID': '',
      'notificationStatus': ''
    });
    String reqId = docReference.id;
    requests.doc(reqId).update({'docId': reqId});
    DocumentReference chatReference =
        await requests.doc(reqId).collection('chats').add({
      'audio': '',
      'audioDuration': '',
      'author': userId,
      'id': '',
      'img': '',
      'read': true,
      'text':
          'This chat offers Text to Speech service, please long press on the chat to try it.',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    String chatId = chatReference.id;
    requests.doc(reqId).collection('chats').doc(chatId).update({'id': chatId});

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => maps(dataId: reqId, typeOfRequest: 'R'),
        ));
    clearForm();
  }

  void clearForm() {
    titleController.clear();
    durationController.clear();
    descController.clear();
    ;
  }
}
