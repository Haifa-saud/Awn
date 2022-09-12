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
import 'package:awn/ViewMap.dart';

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
        title: const Text('View Requests'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      // child: Text('hello')
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
                              return Container(

                                  //elevation: 5.0,
                                  // height: 150,
                                  //width: 150,
                                  child: Card(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, right: 5, bottom: 10),
                                            child: Row(
                                              children: [
                                                Text(
                                                    ' ${data.docs[index]['title']}',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 20,
                                                    color: Colors.red),
                                                Text(
                                                    ' ${data.docs[index]['date_dmy']}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 80),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.schedule,
                                                          size: 20,
                                                          color: Colors.red),
                                                      Text(
                                                          ' ${data.docs[index]['time']}',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, top: 15),
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule,
                                                    size: 20,
                                                    color: Colors.red),
                                                Text(
                                                    ' Duration: ${data.docs[index]['duration']}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, top: 20, right: 20),
                                            // padding: EdgeInsets.symmetric(
                                            //    horizontal: 50, vertical: 50),
                                            child: Row(
                                              children: [
                                                Icon(Icons.description,
                                                    size: 20,
                                                    color: Colors.red),
                                                Flexible(
                                                    child: Text(
                                                        ' ${data.docs[index]['description']}',
                                                        //   overflow:
                                                        //   TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600))),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    /* Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              viewMap(),
                                                        ));*/
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey.shade500,
                                                      backgroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              14, 20, 14, 20),
                                                      side: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 2)),
                                                  child: Text('Location',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black)))),
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
                                                          foregroundColor: Colors
                                                              .grey.shade500,
                                                          backgroundColor:
                                                              Colors.white,
                                                          padding:
                                                              EdgeInsets.fromLTRB(
                                                                  14, 20, 14, 20),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade400,
                                                              width: 2)),
                                                      child: Text('Accept',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black))),
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton.styleFrom(
                                                          foregroundColor: Colors
                                                              .grey.shade500,
                                                          backgroundColor:
                                                              Colors.white,
                                                          padding:
                                                              EdgeInsets.fromLTRB(
                                                                  14, 20, 14, 20),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .red.shade400,
                                                              width: 2)),
                                                      child: Text('Deny',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black))),
                                                ),
                                              ],
                                            ),
                                          ),
                                          /* Container(
                                              child: ElevatedButton(
                                                  onPressed: (() {}),
                                                  child: Text('apdove'))),*/
                                        ],
                                      )));
                            },
                          );
                        },
                      )))
            ],
          )),
    );
  }
}
 /*
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                // child: Text('hello')
                child: StreamBuilder<QuerySnapshot>(
                  stream: requests,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Text('Something went wring');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }
                    final data = snapshot.requireData;
                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return Text(
                            'Date: ${data.docs[index]['date']} Time:${data.docs[index]['time']} Description: ${data.docs[index]['description']} Duration: ${data.docs[index]['duration']}');
                      },
                    );
                  },
                ))
          ],
        ),*/