import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatPage extends StatefulWidget {
  final requestID;
  const ChatPage({required this.requestID, Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  User currentUser = FirebaseAuth.instance.currentUser!;
  final FlutterTts flutterTts = FlutterTts();
  //*audio recorder section
  var audioRecorder;
  bool isRecorderReady = false;
  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
    // setState(() {
    //   flag = false;
    // });
    await flutterTts.awaitSpeakCompletion(true);
    setState(() {
      showRed = false;
    });
  }

  Future initRecorder() async {
    audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission denied';
    }
    await audioRecorder.openAudioSession();
    isRecorderReady = true;
    audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  //* audio player section
  var audioPlayer = FlutterSoundPlayer();
  var isPlaying;
  var playSubscription;
  var isPlayerReady = false;

  Future initPlayer() async {
    audioPlayer = FlutterSoundPlayer();
    isPlaying = false;
    await audioPlayer.openAudioSession().then((value) {
      isPlayerReady = true;
    });
    playSubscription =
        audioPlayer.setSubscriptionDuration(const Duration(milliseconds: 500));

    // audioPlayer.onProgress!.listen((e) {
    //   var maxDuration = e.duration.inMilliseconds.toDouble();
    //   if (maxDuration <= 0) maxDuration = 0.0;
    // });
  }

  @override
  void initState() {
    initRecorder();
    isPlayerReady = false;
    initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioRecorder.closeAudioSession();
    audioPlayer.closeAudioSession();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    var upcomingMessageDate = '00/00/0000';
    var unreadMessages = false;
    var showOnce = true;

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
                                    // unreadMessages = false;
                                    showOnce = true;
                                    if (messages.docs[index]['author'] !=
                                            currentUser.uid &&
                                        !messages.docs[index]['read'] &&
                                        showOnce) {
                                      unreadMessages = true;
                                      showOnce = false;
                                    }
                                    if (index != messages.size - 1) {
                                      upcomingMessageDate = DateFormat('d/M/y')
                                          .format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  messages.docs[index + 1]
                                                      ['createdAt']))
                                          .toString();
                                    }
                                    var currentDate = DateFormat('d/M/y')
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                messages.docs[index]
                                                    ['createdAt']))
                                        .toString();
                                    return Column(children: [
                                      Center(
                                        child: unreadMessages && !showOnce
                                            ? Container(
                                                margin: EdgeInsets.all(10),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 6, 8, 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  border: Border.all(
                                                    width: 0,
                                                    color: Colors.grey.shade100,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text('UNREAD MESSAGES',
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              )
                                            : const SizedBox(height: 0),
                                      ),
                                      Center(
                                        child: upcomingMessageDate !=
                                                currentDate
                                            ? Container(
                                                margin: EdgeInsets.all(10),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 6, 8, 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  border: Border.all(
                                                    width: 0,
                                                    color: Colors.grey.shade100,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                    DateFormat('d MMM y')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                messages.docs[
                                                                        index][
                                                                    'createdAt'])),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              )
                                            : const SizedBox(height: 0),
                                      ),
                                      Center(
                                          child: index == messages.size - 1
                                              ? Container(
                                                  margin: EdgeInsets.all(10),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 6, 8, 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    border: Border.all(
                                                      width: 0,
                                                      color:
                                                          Colors.grey.shade100,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                      DateFormat('d MMM y')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  messages.docs[
                                                                          index][
                                                                      'createdAt'])),
                                                      style:
                                                          TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Colors.grey
                                                                  .shade600)),
                                                )
                                              : const SizedBox(height: 0)),
                                      CupertinoContextMenu(
                                        actions: [
                                          CupertinoContextMenuAction(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              speak(
                                                  messages.docs[index]['text']);
                                            },
                                            trailingIcon: CupertinoIcons.play,
                                            child: const Text(
                                              "Play",
                                            ),
                                          ),
                                        ],
                                        // put actual message here as a child
                                        child: Chat(
                                          message: messages.docs[index]['text'],
                                          isMe: messages.docs[index]
                                                  ['author'] ==
                                              currentUser.uid,
                                          time: DateTime
                                              .fromMillisecondsSinceEpoch(
                                            messages.docs[index]['createdAt'],
                                          ),
                                          isRead: messages.docs[index]['read'],
                                          img: messages.docs[index]['img'],
                                          audio: messages.docs[index]['audio'],
                                          audioDuration: messages.docs[index]
                                              ['audioDuration'],
                                          isPlayerReady: isPlayerReady,
                                          isPlaying: isPlaying,
                                          audioPlayer: audioPlayer,
                                          audioRecorder: audioRecorder,
                                        ),
                                      )
                                    ]);
                                  },
                                );
                              }
                          }
                        },
                      )),
                      ChatField(
                        requestID: widget.requestID,
                        audioRecorder: audioRecorder,
                        audioPlayer: audioPlayer,
                        isRecorderReady: isRecorderReady,
                      ),
                    ])));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

//! specific chat widget
class Chat extends StatefulWidget {
  final message,
      isMe,
      isRead,
      time,
      audio,
      img,
      audioDuration,
      isPlayerReady,
      audioPlayer,
      audioRecorder;
  var isPlaying;

  Chat(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.time,
      required this.isRead,
      required this.img,
      required this.audio,
      required this.audioDuration,
      required this.isPlayerReady,
      required this.isPlaying,
      required this.audioPlayer,
      required this.audioRecorder})
      : super(key: key);

  @override
  State<Chat> createState() => ChatState();
}

class ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  StreamSubscription? _mPlayerSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
  }

  Future<void> playAudio(var path) async {
    //! when playing new audio, must wait for the previous to stop
    assert(widget.isPlayerReady);
    // && audioRecorder.isStopped );
    if (widget.audioPlayer.isPlaying) {
      // widget.audioPlayer.stopPlayer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
                'Please stop the played audio currently, or wait until it is stopped.'),
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.white,
              onPressed: () {},
            )),
      );
    } else if (widget.audioRecorder.isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please wait until the recorder is stopped.'),
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.white,
              onPressed: () {},
            )),
      );
    } else {
      widget.audioPlayer.startPlayer(
          fromURI: path,
          whenFinished: () {
            setState(() {
              widget.isPlaying = false;
            });
            cancelPlayerSubscriptions();
          });
      setState(() {
        widget.isPlaying = true;
      });
      _mPlayerSubscription = widget.audioPlayer.onProgress.listen((e) {
        setState(() {
          duration = e.duration;
          position = e.position;
        });
      });
    }
  }

  void cancelPlayerSubscriptions() {
    if (_mPlayerSubscription != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  Future<void> stopPlayer() async {
    await widget.audioPlayer.stopPlayer();
    setState(() {
      widget.isPlaying = false;
    });
  }

  // Future<void> seek(double d) async {
  //   await widget.audioPlayer.seekToPlayer(Duration(milliseconds: d.floor()));
  //   await setPos(d);
  //   if (d > duration.toDouble()) {
  //     d = duration;
  //   }
  //   setState(() {
  //     position = d;
  //   });

  // }
  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(12);
    const borderRadius = BorderRadius.all(radius);
    return Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: widget.isMe
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
                    borderRadius: borderRadius.subtract(const BorderRadius.only(
                        bottomLeft: Radius.circular(12))),
                  ),
            child: Column(
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: widget.img == ''
                          ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
                          : const EdgeInsets.all(3),
                      child: Column(
                          crossAxisAlignment: widget.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            /*img*/ Visibility(
                                visible: widget.img != '',
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      widget.img,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const Text(
                                            'Image could not be load');
                                      },
                                    ))),
                            /*audio*/ Visibility(
                                visible: widget.audio != '',
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      widget.isPlaying
                                          ? IconButton(
                                              icon: (widget.isMe
                                                  ? const Icon(Icons.stop,
                                                      color: Colors.white,
                                                      size: 35)
                                                  : const Icon(Icons.stop,
                                                      size: 35)),
                                              onPressed: () async {
                                                stopPlayer();
                                              })
                                          : IconButton(
                                              icon: (widget.isMe
                                                  ? const Icon(Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 35)
                                                  : const Icon(Icons.play_arrow,
                                                      size: 35)),
                                              onPressed: () async {
                                                playAudio(widget.audio);
                                              }),
                                      Slider(
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.grey.shade300,
                                          thumbColor: Colors.white,
                                          value: position.inSeconds.toDouble(),
                                          min: 0,
                                          max: duration.inSeconds.toDouble(),
                                          onChanged: (double value) async {
                                            final position = Duration(
                                                seconds: value.toInt());
                                            await widget.audioPlayer
                                                .seekToPlayer(position);
                                          }),
                                    ])),
                            /*text*/ Visibility(
                                visible: widget.message != '',
                                child: Text(
                                  widget.message,
                                  style: TextStyle(
                                      color: widget.isMe
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18),
                                  textAlign: widget.isMe
                                      ? TextAlign.end
                                      : TextAlign.start,
                                )),
                            widget.audio != ''
                                ? widget.isPlaying
                                    ? Text(
                                        '${position.inMinutes.remainder(60)}:${position.inSeconds.remainder(60)}',
                                        style: TextStyle(
                                            color: widget.isMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14))
                                    : Text(widget.audioDuration,
                                        style: TextStyle(
                                            color: widget.isMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14))
                                : SizedBox(),
                          ])),
                  Padding(
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        /*time*/ Text(
                          DateFormat('hh:mm a').format(widget.time).toString(),
                          style: TextStyle(
                              color: widget.isMe
                                  ? Colors.grey.shade200
                                  : Colors.grey,
                              fontSize: 11,
                              wordSpacing: 1),
                        ),
                        const SizedBox(width: 2),
                        /*read/unread*/ Visibility(
                            visible: widget.isMe,
                            child: Icon(
                                widget.isRead ? Icons.done_all : Icons.done,
                                color: Colors.grey.shade200,
                                size: 14)),
                      ]))
                ]),
          )
        ]);
  }
}

//! chat text field
class ChatField extends StatefulWidget {
  final requestID, audioRecorder, audioPlayer, isRecorderReady;
  const ChatField(
      {required this.requestID,
      required this.audioPlayer,
      required this.audioRecorder,
      required this.isRecorderReady,
      Key? key})
      : super(key: key);

  @override
  State<ChatField> createState() => ChatFieldState();
}

class ChatFieldState extends State<ChatField>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  User currentUser = FirebaseAuth.instance.currentUser!;
  bool showRecording = false, showIcons = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var recorderDuration;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          !showRecording
              ? Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    onChanged: (text) {
                      if (_controller.text.trim() != "") {
                        setIcons(false);
                      } else {
                        setIcons(true);
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: showIcons
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.mic),
                                  focusColor: const Color(0xFF39d6ce),
                                  onPressed: () async {
                                    if (!widget.isRecorderReady) {
                                      return;
                                    } else if (widget.audioPlayer.isPlaying) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'To start recording, please stop the audio currently playing or wait until it is stopped.'),
                                            action: SnackBarAction(
                                              label: 'Dismiss',
                                              disabledTextColor: Colors.white,
                                              textColor: Colors.white,
                                              onPressed: () {},
                                            )),
                                      );
                                    } else {
                                      await widget.audioRecorder.startRecorder(
                                          toFile: const Uuid().v4());
                                      setRecording(true);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  onPressed: () {
                                    sendImage(ImageSource.camera);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.insert_photo_outlined),
                                  onPressed: () {
                                    sendImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    color: const Color(0xFF39d6ce),
                                    iconSize: 30,
                                    onPressed: () {
                                      _controller.text.trim().isEmpty
                                          ? null
                                          : sendMessage(
                                              _controller.text, '', '', '');
                                      setIcons(true);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                ]),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      labelText: 'Message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: const BorderSide(
                              color: const Color(0xFF39d6ce), width: 2)),
                      floatingLabelStyle: const TextStyle(
                          fontSize: 22, color: Color(0xFF39d6ce)),
                      helperStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
              : Expanded(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const Divider(height: 5, color: Colors.grey, thickness: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      color: Colors.red,
                      iconSize: 33,
                      onPressed: () {
                        widget.audioRecorder.stopRecorder();
                        setRecording(false);
                      },
                    ),
                    const Spacer(),
                    StreamBuilder<RecordingDisposition>(
                      stream: widget.audioRecorder.onProgress,
                      builder: (context, snapshot) {
                        var duration = snapshot.hasData
                            ? snapshot.data!.duration
                            : Duration.zero;
                        String twoDigits(int n) => n.toString().padLeft(0);
                        var twoDigitMinutes =
                            twoDigits(duration.inMinutes.remainder(60));
                        var twoDigitSeconds =
                            twoDigits(duration.inSeconds.remainder(60));
                        duration = Duration.zero;
                        recorderDuration = '$twoDigitMinutes:$twoDigitSeconds';
                        return Text('$twoDigitMinutes:$twoDigitSeconds');
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: const Color(0xFF39d6ce),
                      iconSize: 33,
                      onPressed: () async {
                        if (widget.audioRecorder.isRecording) {
                          if (!widget.isRecorderReady) {
                            return;
                          }
                          final path =
                              await widget.audioRecorder.stopRecorder();
                          audioFile = File(path!);
                          print("Recorded Audio: $audioFile");
                          sendAudioMessage(recorderDuration);
                        }
                        setRecording(false);
                      },
                    ),
                  ],
                ))
        ],
      ),
    );
  }

  void setRecording(bool isRecording) {
    setState(() {
      showRecording = isRecording;
    });
  }

  void setIcons(bool isTyping) {
    setState(() {
      showIcons = isTyping;
    });
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

  void sendMessage(var message, var imagePath, var audio, var duration) async {
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
      'audio': audio,
      'audioDuration': duration,
      'read': false,
    });
    _controller.clear();

    var dataId = docReference.id;
    messages.doc(dataId).update({'id': dataId});
    print("Document written with ID: ${docReference.id}");
  }
}
