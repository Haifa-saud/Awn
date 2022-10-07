import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final requestID;
  const ChatPage({required this.requestID, Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  String message = '';
  User currentUser = FirebaseAuth.instance.currentUser!;

  Future<Map<String, dynamic>> getOtherUserID() async {
    var user, volID, userID, id;
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestID)
        .get()
        .then(
      (DocumentSnapshot doc) {
        // print(doc.data() as Map<String, dynamic>);
        user = doc.data() as Map<String, dynamic>;
        volID = user['VolID'];
        // print(user['VolID']);
        userID = user['userID'];
      },
    );
    if (volID == FirebaseAuth.instance.currentUser!.uid) {
      print('userID:' + userID);
      id = userID;
    } else {
      print('volID' + volID);
      id = volID;
    }

    // await FirebaseFirestore.instance
    //     .collection('requests')
    //     .doc(widget.requestID)
    //     .collection('chats')
    //     .where('author', isNotEqualTo: (id)) //'xW3YJxbVvihOSeAjdiw24WyI6SE3')
    //     .get()
    //     .then((var doc) {
    //   doc.update({'read': true});
    // });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(id) //'xW3YJxbVvihOSeAjdiw24WyI6SE3')
        .get()
        .then(
      (DocumentSnapshot doc) {
        print(id);
        user = doc.data() as Map<String, dynamic>;
      },
    );
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: getOtherUserID(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                var userData = snapshot.data as Map<String, dynamic>;
                return Scaffold(
                    appBar: AppBar(
                      centerTitle: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      backgroundColor: Colors.white, //(0xFFfcfffe)
                      scrolledUnderElevation: 1,
                      toolbarHeight: 60,
                      title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 2),
                              child: Text(
                                userData['name'],
                              ),
                            ),
                          ]),
                    ),
                    body: SafeArea(
                        child: Column(children: [
                      Expanded(
                          child: StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('requests')
                            .doc(widget.requestID)
                            .collection('chats')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                  child: CircularProgressIndicator());
                            default:
                              if (snapshot.hasError) {
                                return const Text(
                                    'Something Went Wrong Try later');
                              } else {
                                final messages = snapshot.data;

                                return
                                    // StickyGroupedListView<String, dynamic>(
                                    //       elements: messages,
                                    //       groupSeparatorBuilder:(String groupByValue) => Text(groupByValue),
                                    //       groupBy: (Element element) => element['group'],
                                    //   shrinkWrap: true,
                                    //   physics: const BouncingScrollPhysics(),
                                    //   reverse: true,
                                    //   // itemCount: messages.size,
                                    //   itemBuilder: (context, index) {
                                    //     final message =
                                    //         messages.docs[index]['text'];

                                    //     return Message(
                                    //       message: message,
                                    //       isMe: messages.docs[index]['author'] ==
                                    //           currentUser.uid,
                                    //       time: DateTime.fromMillisecondsSinceEpoch(
                                    //           messages.docs[index]['createdAt']),
                                    //     );
                                    //   },
                                    // );
                                    ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  reverse: true,
                                  itemCount: messages.size,
                                  itemBuilder: (context, index) {
                                    final message =
                                        messages.docs[index]['text'];

                                    return Message(
                                      message: message,
                                      isMe: messages.docs[index]['author'] ==
                                          currentUser.uid,
                                      time: DateTime.fromMillisecondsSinceEpoch(
                                          messages.docs[index]['createdAt']),
                                    );
                                  },
                                );
                              }
                          }
                        },
                      )),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                autocorrect: true,
                                enableSuggestions: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  labelText: 'Type your message',
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0),
                                    gapPadding: 10,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                // onChanged: (value) => setState(() {
                                //   message = value;
                                // }),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                _controller.text.trim().isEmpty
                                    ? null
                                    : sendMessage(_controller.text);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child:
                                    const Icon(Icons.send, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    ])));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  void sendMessage(var message) async {
    print(197);
    CollectionReference messages = FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestID)
        .collection('chats');

    var docReference = await messages.add({
      'author': currentUser.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'id': '',
      'text': message,
      'read': false
    });
    _controller.clear();

    var dataId = docReference.id;
    messages.doc(dataId).update({'id': dataId});
    print("Document written with ID: ${docReference.id}");
  }
}

//! Message
class Message extends StatelessWidget {
  final message;
  final bool isMe;
  final time;

  const Message({
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final radius = const Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe) const CircleAvatar(radius: 16),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: isMe
              ? BoxDecoration(
                  // shape: BoxShape.rectangle,
                  // shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      Colors.blue,
                      Color(0xFF39d6ce),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                )
              : BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black, fontSize: 18),
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ),
          Text(
            DateFormat('hh:mm a').format(time).toString(),
            style: TextStyle(
                color: isMe ? Colors.grey.shade200 : Colors.grey, fontSize: 11),
            textAlign: TextAlign.end,
          ),
        ],
      );
}
