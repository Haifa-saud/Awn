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

class addRequest extends StatefulWidget {
  const addRequest({Key? key}) : super(key: key);

  @override
  State<addRequest> createState() => _AddRequestState();
}

class _AddRequestState extends State<addRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awn Requist'),
        centerTitle: true,
        backgroundColor: Color(0xFF39d6ce),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: <Widget>[
              Text('',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              AwnRequestForm(),
            ]),
          ],
        ),
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
  bool showDate = false;
  bool showTime = false;
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
      return DateFormat('MMM d, yyyy').format(selectedDate);
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

  Widget build(BuildContext context) {
    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    return Form(
      key: _formKey,
      // Expanded(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //title
              Container(
                //calin methods
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: Text('Title',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                //  child: Text('Duration'),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  // icon: Icon(Icons.schedule),
                  hintText: 'title',
                  /*   enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black),
                //<-- SEE HERE
              ),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.red)),*/ //boarder style
                  //labelText: 'duration',
                ),
                onChanged: (value) {
                  title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the title';
                  }
                },
              ),
              // time and date
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Please select the time and date',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              //date picker
              Container(
                //padding: const EdgeInsets.symmetric(horizontal: 15),
                //  margin: EdgeInsets.only(bottom: 10, top: 20),
                // width: 150,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                        showDate = true;
                      },
                      child: const Text('Date Picker'),
                    ),
                    showDate
                        ? Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(getDate()))
                        : const SizedBox(),
                  ],
                ),
              ),

              //time picker
              Container(
                  //padding: const EdgeInsets.symmetric(horizontal: 15),
                  //width: 150,
                  child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _selectTime(context);
                      showTime = true;
                    },
                    child: const Text('Timer Picker'),
                  ),
                  showTime
                      ? Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Text(getTime(selectedTime)))
                      : const SizedBox(),
                ],
              )),
              //showTime ? Text(getTime(selectedTime)) : const SizedBox(),
              //duration
              Container(
                //calin methods
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Duration',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                //  child: Text('Duration'),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  //icon: Icon(Icons.schedule),
                  hintText: 'for about 2 hours',

                  //labelText: 'duration',
                ),
                onChanged: (value) {
                  duration = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the duration';
                  }
                },
              ),

              Container(
                //calin methods
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Describtion',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  // icon: Icon(Icons.description),
                  hintText: 'enter location here',

                  // labelText: 'describtion',
                ),
                //keyboardType: TextInputType.datetime,
                keyboardType: TextInputType.multiline,
                //   maxLines: 2,
                maxLength: 150,
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Provide a description';
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Sending Data to firestor'),
                        ));
                        requests
                            .add({
                              'title': title,
                              'date': getDate(),
                              'time': getTime(selectedTime),
                              'duration': duration,
                              'description': description
                            })
                            .then((value) => backToHomePage())
                            .catchError((error) =>
                                print("Failed to add request:$error"));
                      }
                    },
                    child: Text('Submit'),
                  ))
            ],
          ))),
    );
  }

  void backToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}
