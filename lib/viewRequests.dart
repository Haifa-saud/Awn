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

class viewRequests extends StatefulWidget {
  const viewRequests({Key? key}) : super(key: key);

  @override
  State<viewRequests> createState() => _AddRequestState();
}

class _AddRequestState extends State<viewRequests> {
  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .orderBy("date_ymd")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.max,
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
                            print('line 48');
                            return Text('Something went wring');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('line 51');
                            return Text('Loading');
                          }
                          final data = snapshot.requireData;
                          print('line 55');
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              print('line 59');
                              return Card(
                                  child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //title
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 0, 290, 15),
                                    child: Text(
                                      ' ${data.docs[index]['title']}',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
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
                                              Text(
                                                  ' ${data.docs[index]['time']}',
                                                  style: TextStyle(
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
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        // Icon(Icons.schedule,
                                        //     size: 20, color: Colors.red),
                                        Text(
                                            'Duration: ${data.docs[index]['duration']}',
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
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 20, color: Colors.red),
                                        Text('location',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  //buttons
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    // width: 150,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          width: 100,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Colors.green.shade400,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      17, 13, 17, 13),
                                              textStyle:
                                                  const TextStyle(fontSize: 17),
                                            ),
                                            child: Text('Accept'),
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    Colors.red.shade300,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        17, 13, 17, 13),
                                                textStyle: const TextStyle(
                                                    fontSize: 17),
                                              ),
                                              child: Text('Deny')),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                            },
                          );
                        },
                      )))
            ],
          )),
    );
  }
}
