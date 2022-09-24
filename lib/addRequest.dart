import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:awn/map.dart';

class addRequest extends StatefulWidget {
  const addRequest({Key? key}) : super(key: key);

  @override
  State<addRequest> createState() => _AddRequestState();
}

TextEditingController titleController = TextEditingController();
TextEditingController durationController = TextEditingController();
TextEditingController descController = TextEditingController();
void clearForm() {
  titleController.clear();
  durationController.clear();
  descController.clear();
  ;
}

class _AddRequestState extends State<addRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Request Awn', textAlign: TextAlign.center),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Discard the changes you made?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () {
                      clearForm();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Discard'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: AwnRequestForm());
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
      lastDate: DateTime(2025),
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

  String getDateTime() {
    // ignore: unnecessary_null_comparison
    if (dateTime == null) {
      return 'select date timer';
    } else {
      return DateFormat('yyyy-MM-dd HH: ss a').format(dateTime);
    }
  }

  String getTime(TimeOfDay tod) {
    final now = DateTime.now();

    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

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
              '*indicates requered fields',
              style: TextStyle(fontSize: 15),
            )),
            /*title*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
              child: Text('What help do you need?*'),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'E.g. Help with shopping',
                  ),
                  // onChanged: (value) {title = value; },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
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
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1)),
                    child: const Text('Update Date'),
                  ),
                  showDate
                      ? Container(
                          margin: EdgeInsets.only(right: 50),
                          child: Text(getDate_formated()))
                      // DateFormat('yyyy/MM/dd').format(selectedDate)
                      : const SizedBox(),
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
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          side: BorderSide(
                              color: Colors.grey.shade400, width: 1)),
                      child: const Text('Update Time'),
                    ),
                    showTime
                        ? Container(
                            margin: EdgeInsets.only(right: 50),
                            child: Text(getTime(selectedTime)))
                        : const SizedBox(),
                  ],
                )),

            //duration
            Container(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 8),
              child: Text('Duration*'),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
              child: TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  hintText: 'E.g. For about 2 hours',
                ),
                // onChanged: (value) {duration = value;},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                },
              ),
            ),

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
                  if (value == null || value.isEmpty) {
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
                  if (_formKey.currentState!.validate()) {
                    addToDB();
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
    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    DocumentReference docReference = await requests.add({
      'title': titleController.text,
      'date_ymd': getDate(),
      'date_dmy': getDate_formated(),
      'time': getTime(selectedTime),
      'duration': durationController.text,
      'description': descController.text,
      'latitude': '',
      'longitude': ''
    });
    String dataId = docReference.id;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => maps(dataId: dataId, typeOfRequest: 'R'),
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
