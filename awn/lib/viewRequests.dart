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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
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
                        print('line 48');
                        return Text('Something went wring');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print('line 51');
                        return Text('Loading');
                      }
                      final data = snapshot.requireData;
                      print('line 55');
                      return ListView.builder(
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          print('line 59');
                          return Text(
                              'Date: ${data.docs[index]['date']} Time:${data.docs[index]['time']} Description: ${data.docs[index]['description']} Duration: ${data.docs[index]['duration']}');
                        },
                      );
                    },
                  ))
            ],
          )
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
          ),
    );
  }
}
