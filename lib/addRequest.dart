import 'package:Awn/addPost.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/userProfile.dart';
import 'package:Awn/viewRequests.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:justino_icons/justino_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'TextToSpeech.dart';
import 'chatPage.dart';
import 'homePage.dart';
import 'main.dart';
import 'package:Awn/map.dart';
import 'requestWidget.dart';
import 'services/localNotification.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    initializeDateFormatting('en');

    super.initState();
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
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

  //! bottom bar nav
  final iconSNU = <IconData>[
    Icons.home,
    Icons.volume_up,
    Icons.handshake,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    var iconList = <IconData, String>{
      Icons.home: "Home",
      JustinoIcons.getByName('speech') as IconData: "Text to Speech",
      Icons.handshake: "Awn Request",
      Icons.person: "Profile",
    };

    Future<void> _onItemTapped(int index) async {
      if (widget.userType == 'Special Need User') {
        if (index == 0) {
          var nav = const homePage();
          alertDialog(nav);
        } else if (index == 1) {
          var nav = Tts(userType: widget.userType);
          alertDialog(nav);
        } else if (index == 2) {
          var nav = addRequest(userType: widget.userType);
          alertDialog(nav);
        } else if (index == 3) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          alertDialog(nav);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: FutureBuilder(
                future: storage.downloadURL('logo.jpg'),
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
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  }
                  return Container();
                })),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  color: Colors.blue.shade800,
                  height: 1.0,
                ))),
        title: const Text('Request Awn', textAlign: TextAlign.center),
        centerTitle: true,
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
              pageBuilder: (context, animation1, animation2) => addPost(
                userType: widget.userType,
              ),
              transitionDuration: const Duration(seconds: 1),
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
        activeIndex: 2,
        itemCount: 4,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
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
  DateTime endDateTime = DateTime.now();
  var selectedEndDateTime;

  DateTime SelectedDateTime = DateTime.now();
  bool showDate = true;
  bool showTime = true;
  bool showDateTime = false;
  bool invalidStartDate = false;
  var title = '';
  var description = '';
  var duration = '';
  var startDateTime = DateTime.now();

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      locale: Localizations.localeOf(context),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2023),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    getDateTimeSelected();
    return selectedDate;
  }

  // Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
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
    getDateTimeSelected();
    return selectedTime;
  }

  // select date time picker
  // Future _selectDateTime(BuildContext context) async {
  //   final date = await _selectDate(context);
  //   if (date == null) return;
  //   final time = await _selectTime(context);
  //   if (time == null) return;
  //   setState(() {
  //     dateTime = DateTime(
  //       date.year,
  //       date.month,
  //       date.day,
  //       time.hour,
  //       time.minute,
  //     );
  //   });
  // }

  String getDate() {
    if (selectedDate == null) {
      return 'select date';
    } else {
      print(selectedDate);
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
      return DateFormat('MMM dd, yyyy').format(selectedDate);
    }
  }

  String getDateTimeSelected() {
    //used to add to database
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

  var selectedDuration;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            // Container(
            //     child: Text(
            //   '*indicates required fields',
            //   style: TextStyle(fontSize: 15),
            // )),

            /*title*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
              child: Text('What help do you need?'),
            ),

            Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: TextFormField(
                  maxLength: 20,
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'E.g. Help with shopping',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        (value.trim()).isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                )),

            // time and date
            Container(
              padding: EdgeInsets.fromLTRB(6, 15, 6, 6),
              child: Text('Start Time and Date'),
            ),

            //date picker

            Row(children: [
              Container(
                // padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _selectDate(context);
                        showDate = true;
                        await _selectTime(context);
                        showTime = true;
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(370, 50),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(17, 13, 17, 10),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          alignment: Alignment.topLeft,
                          side: BorderSide(
                              color: invalidStartDate
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              width: invalidStartDate ? 2 : 1)),
                      child: showDate
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                      style: TextStyle(
                                          fontSize: 18,
                                          letterSpacing: 1,
                                          wordSpacing: 2),
                                      textAlign: TextAlign.left,
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
            Visibility(
              visible: invalidStartDate,
              child: const SizedBox(height: 10),
            ),
            Visibility(
                visible: invalidStartDate,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 0, 0, 0),
                      child: Text('Please enter a later time.',
                          style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              wordSpacing: 0.1,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal)),
                    ))),

            //End time
            Container(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 6),
              child: Text('End Time and Date'),
            ),

            Padding(
                padding: const EdgeInsets.fromLTRB(4, 5, 4, 0),
                child: DateTimePicker(
                  type: DateTimePickerType.dateTime,
                  initialValue: '',
                  locale: Localizations.localeOf(context),
                  initialDate: SelectedDateTime,
                  initialTime: selectedTime,
                  firstDate: SelectedDateTime,
                  lastDate: DateTime((SelectedDateTime.year + 1),
                      SelectedDateTime.month, SelectedDateTime.day),
                  dateLabelText: "Pick a date and time",
                  // dateLabelText: 'End date and time',
                  // timeLabelText: 'End Time',
                  timeFieldWidth: 150,
                  // use24HourFormat: false,
                  onChanged: (val) => print(val),
                  validator: (val) {
                    if (val!.isEmpty || val == null) {
                      return 'Please specify a time and a date.';
                    } else if (checkEndTime(val) == -1) {
                      return 'Please specify a time and a date after the start time.';
                    }
                    print('val $val');
                    return null;
                  },
                  onSaved: (val) => print(val),
                )),

            //description
            Container(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 8),
              child: Text('Description',
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
                  if (_formKey.currentState!.validate() &&
                      checkCurrentTime() < 0) {
                    setState(() {
                      invalidStartDate = false;
                    });
                    addToDB();
                  } else if (checkCurrentTime() >= 0) {
                    setState(() {
                      invalidStartDate = true;
                    });
                  } else {
                    setState(() {
                      invalidStartDate = false;
                    });
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('Please fill the required fields above'),
                    //     backgroundColor: Colors.red.shade400,
                    //     margin: EdgeInsets.fromLTRB(8, 0, 20, 0),
                    //     behavior: SnackBarBehavior.floating,
                    //     action: SnackBarAction(
                    //       label: 'Dismiss',
                    //       disabledTextColor: Colors.white,
                    //       textColor: Colors.white,
                    //       onPressed: () {
                    //         //Do whatever you want
                    //       },
                    //     ),
                    //   ),
                    // );
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
      // 'duration': durationController.text,
      'description': descController.text,
      'latitude': '',
      'longitude': '',
      'status': 'Pending',
      'docId': '',
      'userID': userId,
      'VolID': '',
      'notificationStatus': '',
      'endDateTime': selectedEndDateTime,
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
  }
}
