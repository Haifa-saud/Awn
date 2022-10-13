import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class comments2 extends StatefulWidget {
  // final String userId;
  const comments2({super.key});
  @override
  commentsState2 createState() => commentsState2();
}

class commentsState2 extends State<comments2> {
  bool pop = false;
  final ScrollController _scrollController = ScrollController();
  String comment = '';

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> comments = FirebaseFirestore.instance
        .collection('Comments')
        //.where('PostID', isEqualTo: "Post1")
        .snapshots();

    //final delete_comm = FirebaseFirestore.instance.collection('Comments');

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
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
            child: Column(children: [
          // const Divider(),
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
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
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

                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        comment = '';
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: const Text("cancel",
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
          //const Divider(),
          StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection("Comments")
                  .where('PostID', isEqualTo: "M9vFg6LRwhdZAh77g7pw")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("this post has no comments");
                } else {
                  final comment_Data = snapshot.data;
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: comment_Data!.size,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 16),
                            child: Stack(children: [
                              Container(
                                width: 600,
                                margin: const EdgeInsets.only(top: 1),
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 32,
                                          color: Colors.black45,
                                          spreadRadius: -8)
                                    ],
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 1, 1, 1),
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        6, 10, 15, 15),
                                                child: Stack(children: [
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Container(
                                                          width: 235,
                                                          child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                comment_Data.docs[
                                                                        index]
                                                                    ['name'],
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        20),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              )))),
                                                ])),
                                            //comment
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 10, 20, 10),
                                              child: Flexible(
                                                child: Text(
                                                    comment_Data.docs[index]
                                                        ['text'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 17)),
                                              ),
                                            ),
                                            // Text(
                                            //     "_____________________________________________",
                                            //     style: const TextStyle(
                                            //       fontWeight: FontWeight.w400,
                                            //       fontSize: 17,
                                            //       color: Color.fromARGB(
                                            //           115, 172, 169, 169),
                                            //     )),
                                            // date and time
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 0, 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            comment_Data
                                                                    .docs[index]
                                                                ['date'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                  // Divider(),

                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 210),
                                                      child: Visibility(
                                                          visible: comment_Data
                                                                          .docs[
                                                                      index]
                                                                  ['UserID'] ==
                                                              "User5",
                                                          child: IconButton(
                                                            iconSize: 30,
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      194,
                                                                      98,
                                                                      98),
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (ctx) =>
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      "Are You Sure ?"),
                                                                  content:
                                                                      const Text(
                                                                    "Are You Sure You want to delete your comment? , This procces can't be undone",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(ctx)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.all(14),
                                                                        child: const Text(
                                                                            "cancel"),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        // delete_comm
                                                                        //     .doc('id') // <-- Doc ID to be deleted.
                                                                        //     .delete() // <-- Delete
                                                                        //     .then((_) => print('Deleted'))
                                                                        //     .catchError((error) =>
                                                                        //         print('Delete failed: $error'));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.all(14),
                                                                        child: const Text(
                                                                            "Delete",
                                                                            style:
                                                                                TextStyle(color: Color.fromARGB(255, 164, 10, 10))),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          )))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              )
                            ]));
                      });
                }
              }),
          const Spacer(),
        ])),
      ),
    );
  }

  Future<void> addToDB() async {
    CollectionReference Post_comment =
        FirebaseFirestore.instance.collection('Comments');

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    DocumentReference docReference = await Post_comment.add({
      'date': actualDate,
      'name': 'wedd Alhossaiyn',
      //'time': actualTime,
      'text': comment,
      'UserID': 'User5',
      //FirebaseAuth.instance.currentUser!.uid,
      'PostID': 'M9vFg6LRwhdZAh77g7pw'
      //placeID
    });
    dataId = docReference.id;
    print("Document written with ID: ${docReference.id}");
    print('comment added');
    comment = '';
  }
}

//String id = '';
//String UserID = '';

var now = DateTime.now();
var formatterDate = DateFormat('MMM d, h:mm a');
//var formatterTime = DateFormat('kk:mm');
String actualDate = formatterDate.format(now);
//String actualTime = formatterTime.format(now);
