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
  final Stream<QuerySnapshot> requests =
      FirebaseFirestore.instance.collection('requests').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awn Requist(view)'),
        centerTitle: true,
        backgroundColor: Color(0xFF39d6ce),
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
                                          horizontal: 100, vertical: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 30,
                                                    color: Colors.red),
                                                Text(
                                                    ' ${data.docs[index]['date']}',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule,
                                                    size: 30,
                                                    color: Colors.red),
                                                Text(
                                                    ' ${data.docs[index]['time']}',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule,
                                                    size: 30,
                                                    color: Colors.red),
                                                Text(
                                                    ' Duration: ${data.docs[index]['duration']}',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Icon(Icons.description,
                                                    size: 30,
                                                    color: Colors.red),
                                                Text(
                                                    ' ${data.docs[index]['description']}',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            // width: 150,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      onPressed: () {},
                                                      child: Text('Accept')),
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      onPressed: () {},
                                                      child: Text('Deny')),
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