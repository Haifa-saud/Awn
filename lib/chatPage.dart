import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
  bool isRecorderReady = false, isPlayerReady = false;
  FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();
  bool isPlaying = false;
  var playerSubscription;
  // Duration duration = Duration.zero, pos = Duration.zero;
  double subscriptionDuration = 0;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  @override
  void initState() {
    initRecorder();
    initPlayer();
    super.initState();
  }

  Future initPlayer() async {
    await audioPlayer.openAudioSession().then((value) {
      isPlayerReady = true;
    });
    playerSubscription =
        audioPlayer.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  String _playerTxt = '00:00:00';

  void _addListeners() {
    initializeDateFormatting();
    playerSubscription = audioPlayer.onProgress!.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
      if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition =
          min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      var date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds,
          isUtc: true);
      var txt = DateFormat('mm:ss:SS').format(date);
      // setState(() {
      _playerTxt = txt.substring(0, 8);
      // });
    });
  }

  void playAudio(var path) {
    assert(
        isPlayerReady); //&& audioRecorder.isStopped && audioPlayer.isStopped);
    audioPlayer.startPlayer(fromURI: path);
    _addListeners();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission denied';
    }
    await audioRecorder.openAudioSession();
    isRecorderReady = true;
    audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    audioRecorder.closeAudioSession();
    audioPlayer.closeAudioSession();

    super.dispose();
  }

  void cancelPlayerSubscriptions() {
    if (playerSubscription != null) {
      playerSubscription!.cancel();
      playerSubscription = null;
    }
  }

  Future<Map<String, dynamic>> getOtherUserID() async {
    var user, volID, userID, id;
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestID)
        .get()
        .then(
      (DocumentSnapshot doc) {
        user = doc.data() as Map<String, dynamic>;
        volID = user['VolID'];
        userID = user['userID'];
      },
    );
    if (volID == FirebaseAuth.instance.currentUser!.uid) {
      id = userID;
    } else {
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
        user = doc.data() as Map<String, dynamic>;
      },
    );
    return user;
  }

  bool showRecording = false;

  @override
  Widget build(BuildContext context) {
    bool isKeyboard = true;
    void hideWidget() {
      setState(() {
        isKeyboard = !isKeyboard;
      });
    }

    var recorderDuration;

    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: getOtherUserID(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                          preferredSize: const Size.fromHeight(1.0),
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  reverse: true,
                                  itemCount: messages.size,
                                  itemBuilder: (context, index) {
                                    return Column(children: [
                                      Message(
                                          messages.docs[index]['text'],
                                          messages.docs[index]['author'] ==
                                              currentUser.uid,
                                          DateTime.fromMillisecondsSinceEpoch(
                                            messages.docs[index]['createdAt'],
                                          ),
                                          messages.docs[index]['read'],
                                          messages.docs[index]['img'],
                                          messages.docs[index]['audio'],
                                          messages.docs[index]
                                              ['audioDuration']),
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
                            // Visibility(
                            //     visible:
                            //         true, //_controller.text.trim().isEmpty,
                            //     child: GestureDetector(
                            //       onTap: () {
                            //         sendImage(ImageSource.gallery);
                            //       },
                            //       child: const Icon(Icons.add,
                            //           color: Colors.black),
                            //     )),
                            // GestureDetector(
                            //   onTap: () {
                            //     sendImage(ImageSource.camera);
                            //   },
                            //   child: const Icon(Icons.camera_alt_outlined,
                            //       color: Colors.black),
                            // ),
                            /*mic icon*/ Visibility(
                                visible: !showRecording,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (!isRecorderReady) {
                                      return;
                                    }
                                    await audioRecorder.startRecorder(
                                        toFile: const Uuid().v4());
                                    setRecording(true);
                                  },
                                  child: const Icon(Icons.mic,
                                      color: Colors.black),
                                )),

                            // AnimatedSwitcher(
                            //   duration: const Duration(milliseconds: 300),
                            //   child:
                            !showRecording
                                ? Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      autocorrect: true,
                                      enableSuggestions: true,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {},
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        labelText: 'Type your message',
                                        border: OutlineInputBorder(
                                          borderSide:
                                              const BorderSide(width: 0),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  )
                                : StreamBuilder<RecordingDisposition>(
                                    stream: audioRecorder.onProgress,
                                    builder: (context, snapshot) {
                                      var duration = snapshot.hasData
                                          ? snapshot.data!.duration
                                          : Duration.zero;
                                      String twoDigits(int n) =>
                                          n.toString().padLeft(0);
                                      var twoDigitMinutes = twoDigits(
                                          duration.inMinutes.remainder(60));
                                      var twoDigitSeconds = twoDigits(
                                          duration.inSeconds.remainder(60));
                                      duration = Duration.zero;
                                      recorderDuration =
                                          '$twoDigitMinutes:$twoDigitSeconds';
                                      return Text(
                                          '$twoDigitMinutes:$twoDigitSeconds');
                                    },
                                  ),
                            // ),

                            const SizedBox(width: 15),
                            /*send icon*/ GestureDetector(
                              onTap: () async {
                                if (audioRecorder.isRecording) {
                                  if (!isRecorderReady) {
                                    print('not ready');
                                    return;
                                  }
                                  final path =
                                      await audioRecorder.stopRecorder();
                                  audioFile = File(path!);
                                  print("Recorded Audio: $audioFile");
                                  sendAudioMessage(recorderDuration);
                                }
                                _controller.text.trim().isEmpty
                                    ? null
                                    : sendMessage(_controller.text, '', '', '');
                                setRecording(true);
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

  // _toggle() {
  //   setState(() {
  //     loading = !loading;
  //   });
  // }
  void setRecording(bool isRecording) {
    setState(() {
      showRecording = isRecording;
    });
  }

//! Widgets
  Widget Message(message, isMe, time, isRead, img, audio, audioDuration) {
    String audioText = _playerTxt;
    var sliderValue = maxDuration, currPosition = sliderCurrentPosition;
    final radius = const Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        // if (!isMe)
        //   const CircleAvatar(
        //     backgroundColor:
        //         Color.fromARGB(255, 183, 217, 245), //Color(0xffE6E6E6),
        //     radius: 16,
        //     child: Icon(Icons.person,
        //         size: 12, color: Colors.white //Color(0xffCCCCCC),
        //         ),
        //   ),
        Container(
          padding: img == ''
              ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
              : const EdgeInsets.all(3),
          margin: const EdgeInsets.all(10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: isMe
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      Colors.blue,
                      Color(0xFF39d6ce),
                    ],
                  ),
                  borderRadius: borderRadius.subtract(const BorderRadius.only(
                      bottomRight: Radius.circular(12))))
              : BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: borderRadius.subtract(
                      const BorderRadius.only(bottomLeft: Radius.circular(12))),
                ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                  visible: img != '',
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Text('Image could not be load');
                        },
                      ))),
              Visibility(
                // key: id;
                visible: audio != '',
                // child: Row(children: [
                child: IconButton(
                    icon: !isPlaying
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.stop),
                    onPressed: () async {
                      if (isPlaying) {
                      } else {
                        playAudio(audio);
                      }
                    }),
                // Slider(
                //   value: min(currPosition, sliderValue),
                //   min: 0.0,
                //   max: sliderValue,
                //   onChanged: (value) async {
                //     await seekToPlayer(value.toInt());
                //   },
                //   // divisions:
                //   //     maxDuration == 0.0 ? 1 : maxDuration.toInt()),
                // ),
                // ]
              ),
              // ),
              Visibility(
                  visible: message != '',
                  child: Text(
                    message,
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 18),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  )),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Visibility(
                  visible: audio != '',
                  child: Text(audioDuration,
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                Visibility(
                    visible: audio != '', child: const SizedBox(width: 15)),
                Text(
                  DateFormat('hh:mm a').format(time).toString(),
                  style: TextStyle(
                      color: isMe ? Colors.grey.shade200 : Colors.grey,
                      fontSize: 11),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(width: 7),
                Visibility(
                    visible: isMe,
                    child: Icon(isRead ? Icons.done_all : Icons.done,
                        color: Colors.grey.shade200, size: 14)),
              ])
            ],
          ),
        ),
      ],
    );
  }

//! Firebase
  File? audioFile;

  Future sendAudioMessage(var duration) async {
    final audio = File(audioFile!.path);
    var metadata = SettableMetadata(contentType: 'audio/mpeg');
    final storage = FirebaseStorage.instance.ref().child('chatAudio/${audio}');
    final strAudio = Path.basename(audio.path);
    UploadTask uploadTask = storage.putFile(audio, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print(' Download Link: $urlDownload');
    sendMessage('', '', urlDownload, duration);
  }

  Future<void> sendImage(var imgSource) async {
    String imagePath = '';
    File? imageDB;
    String strImg = '';
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: imgSource);
      File imagee = File(img!.path);
      imagePath = imagee.toString();
      imageDB = imagee;
      File image = imageDB;
      final storage =
          FirebaseStorage.instance.ref().child('postsImage/${image}');
      strImg = Path.basename(image.path);
      UploadTask uploadTask = storage.putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      imagePath = await (await uploadTask).ref.getDownloadURL();
      sendMessage('', imagePath, '', '');
    }
  }

  void sendMessage(
      var message, var imagePath, var audioPath, var audioDuration) async {
    CollectionReference messages = FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestID)
        .collection('chats');

    var docReference = await messages.add({
      'author': currentUser.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'id': '',
      'text': message,
      'img': imagePath,
      'audio': audioPath,
      'audioDuration': audioDuration,
      'read': false,
    });
    _controller.clear();

    var dataId = docReference.id;
    messages.doc(dataId).update({'id': dataId});
    print("Document written with ID: ${docReference.id}");
  }
}
