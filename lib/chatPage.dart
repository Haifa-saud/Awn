import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:grouped_list/grouped_list.dart';
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

    final query = await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestID)
        .collection('chats')
        .where('author', isEqualTo: (id))
        .where('read', isEqualTo: false)
        .get();

    query.docs.forEach((doc) {
      doc.reference.update({'read': true});
    });

    await FirebaseFirestore.instance.collection('users').doc(id).get().then(
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
                      bottom: PreferredSize(
                          preferredSize: Size.fromHeight(1.0),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Container(
                                color: Colors.grey,
                                height: 1.0,
                              ))),
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
                                    // GroupedListView<Object, dynamic>(
                                    //   elements: snapshot.data.docs,
                                    //   groupBy: (element) => (element
                                    //       as Map<String, dynamic>)['createdAt'],
                                    //   groupSeparatorBuilder: (dynamic value) =>
                                    //       Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Text(
                                    //       value,
                                    //       textAlign: TextAlign.center,
                                    //       style: const TextStyle(
                                    //           fontSize: 20,
                                    //           fontWeight: FontWeight.bold),
                                    //     ),
                                    //   ),
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
                                    //   order: GroupedListOrder.ASC,
                                    // );
                                    // StickyGroupedListView(
                                    //   elements: messages,
                                    //   groupSeparatorBuilder:
                                    //       (dynamic groupByValue) => Text(''),
                                    //   groupBy: (element) => element['createdAt'],
                                    //   shrinkWrap: true,
                                    //   physics: const BouncingScrollPhysics(),
                                    //   reverse: true,
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
                                    var isLastItem = false;
                                    if (index == 0) {
                                      //messages.size - 1) {
                                      isLastItem = true;
                                    }
                                    return Column(children: [
                                      Message(
                                        message: message,
                                        isMe: messages.docs[index]['author'] ==
                                            currentUser.uid,
                                        time:
                                            DateTime.fromMillisecondsSinceEpoch(
                                          messages.docs[index]['createdAt'],
                                        ),
                                        lastMessage: isLastItem,
                                        isRead: messages.docs[index]['read'],
                                      ),
                                    ]);
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
                                    // gapPadding: 10,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                _controller.text.trim().isEmpty
                                    ? null
                                    : sendMessage(_controller.text);
                              },
                              child:
                                  const Icon(Icons.send, color: Colors.black),
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
  final lastMessage, isRead;

  const Message(
      {required this.message,
      required this.isMe,
      required this.time,
      required this.lastMessage,
      required this.isRead});

  @override
  Widget build(BuildContext context) {
    final radius = const Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        // if (!isMe)
        //   const CircleAvatar(
        //     backgroundColor:
        //         Color.fromARGB(255, 149, 204, 250), //Color(0xffE6E6E6),
        //     radius: 16,
        //     child: Icon(Icons.person,
        //         size: 10, color: Colors.white //Color(0xffCCCCCC),
        //         ),
        //   ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          margin: const EdgeInsets.all(10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: isMe
              ? BoxDecoration(
                  // shape: BoxShape.rectangle,
                  // shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      Colors.blue,
                      Color(0xFF39d6ce),
                    ],
                  ),
                  borderRadius: borderRadius.subtract(BorderRadius.only(
                      bottomRight:
                          Radius.circular(12))) //BorderRadius.circular(25),
                  )
              : BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: borderRadius.subtract(
                      BorderRadius.only(bottomLeft: Radius.circular(12))),
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
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              DateFormat('hh:mm a').format(time).toString(),
              style: TextStyle(
                  color: isMe ? Colors.grey.shade200 : Colors.grey,
                  fontSize: 11),
              textAlign: TextAlign.end,
            ),
            SizedBox(width: 7),
            Visibility(
                visible: lastMessage && isMe,
                child: Icon(isRead ? Icons.done_all : Icons.done,
                    color: Colors.grey.shade200, size: 14)),
          ])
        ],
      );
}
