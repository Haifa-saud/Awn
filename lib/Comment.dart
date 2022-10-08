import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'Info.dart';
import 'infoPage.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class comments extends StatefulWidget {
  // final String userId;
  const comments({super.key});
  @override
  commentsState createState() => commentsState();
}

class commentsState extends State<comments> {
  final ScrollController _scrollController = ScrollController();
  String comment = '1';

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> comments =
        FirebaseFirestore.instance.collection('comment').snapshots();

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: double.infinity,
          child: Text('My Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
            // height: 50, //height of button
            // width: 50,
            child: Column(children: [
          const Spacer(),
          const Divider(),
          IconButton(
            icon: const Icon(Icons.comment),
            iconSize: 48,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    "Add comment",
                    textAlign: TextAlign.center,
                  ),
                  //comment

                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      //padding: const EdgeInsets.fromLTRB(80, 60, 80, 60),
                      controller: _scrollController,
                      child: SizedBox(
                        height: 130,
                        width: 350,
                        child: TextFormField(
                          scrollController: _scrollController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          maxLength: 120,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: "Enter comment",
                            labelText: 'comment',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                          validator: (value) {
                            comment = value.toString();
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),

                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        comment = '';
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: const Text("Cancle",
                            style: TextStyle(
                                color: Color.fromARGB(255, 164, 10, 10))),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print(comment);
                          addToDB();
                          Navigator.of(ctx).pop();
                        } else {}
                      },
                      child: Container(
                        //color: Color.fromARGB(255, 164, 20, 20),
                        padding: const EdgeInsets.all(14),
                        child: const Text(
                          "Post",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const Spacer(),
          StreamBuilder<QuerySnapshot>(
              stream: comments,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("this post has no comments");
                } else {
                  return Column(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Container(
                          child: Column(children: [
                        Text((document.data() as Map)['name']),
                        Text((document.data() as Map)['date'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 54, 99, 222))),
                        Text((document.data() as Map)['text'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            )),
                        // Text((document.data() as Map)['time'],
                        //     style: TextStyle(
                        //       fontSize: 18,
                        //       fontWeight: FontWeight.normal,
                        //     )),
                        Divider(),
                      ]));
                    }).toList(),
                  );
                }
              }),
          const Spacer(),
        ])),
      ),
    );
  }

  Future<void> addToDB() async {
    CollectionReference Post_comment =
        FirebaseFirestore.instance.collection('comment');

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    DocumentReference docReference = await Post_comment.add({
      'date': actualDate,
      'name': commenter,
      'time': actualTime,
      'text': comment,
      //'UserID': FirebaseAuth.instance.currentUser!.uid,
      //'PostID': placeID
    });
    dataId = docReference.id;
    print("Document written with ID: ${docReference.id}");
    print('comment added');
    comment = '';
  }
}

String commenter = '';
var now = DateTime.now();
var formatterDate = DateFormat('dd/MM/yy');
var formatterTime = DateFormat('kk:mm');
String actualDate = formatterDate.format(now);
String actualTime = formatterTime.format(now);
