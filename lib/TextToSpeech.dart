import 'package:Awn/addPost.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Tts extends StatefulWidget {
  final String userType;
  const Tts({Key? key, required this.userType}) : super(key: key);

  @override
  _TtsState createState() => _TtsState();
}

class _TtsState extends State<Tts> {
  @override
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool flag = false;
  bool flag1 = false;
  String waitMessage = "";
  bool showRed = false;

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

  final Storage storage = Storage();

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: FutureBuilder(
                    future: storage.downloadURL('logo.png'),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Center(
                          child: Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.blue,
                        ));
                      }
                      return Container();
                    }))
          ],
          automaticallyImplyLeading: false,
          title: const SizedBox(
            child: Text('Text To Speech'),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Container(
                    color: Colors.grey,
                    height: 1.0,
                  ))),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Column(children: [
                Column(children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: const Text("Let us be your voice!",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w900)),
                      )),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: const Text("Start typing so Awn can speak for you"),
                  ),
                ]),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: const Text(
                      "*Please Write in English",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                textArea(),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: flag1
                            ? const Text(
                                'Please enter a text to proceed.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.left,
                              )
                            : const Text(""))),
                Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 5.0)
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                        colors: [
                          Colors.blue,
                          Colors.cyanAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                        style: showRed
                            ? ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(50, 50)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shadowColor:
                                    MaterialStateProperty.all(Colors.red),
                                side: MaterialStateProperty.all(
                                    const BorderSide(color: Colors.red)))
                            : ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(50, 50)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Text(
                            'Play',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            setState(() {
                              if (textEditingController.text.trim().length >
                                  0) {
                                setState(() {
                                  showRed = true;
                                  flag1 = false;
                                });
                              }
                              if (textEditingController.text.isNotEmpty &&
                                  textEditingController.text.length > 120) {
                                flag = true;
                                flag1 = false;
                              }
                              if (textEditingController.text.trim().length ==
                                  0) {
                                flag1 = true;
                              }
                            });
                            speak(textEditingController.text);
                          });
                        })),
                flag ? const CircularProgressIndicator() : const Text(""),
              ])),
        ),
        floatingActionButton: FloatingActionButton(
          child: Container(
            width: 60,
            height: 60,
            child: const Icon(
              Icons.add,
              size: 40,
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [
                  Colors.blue,
                  Color(0xFF39d6ce),
                ],
              ),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    addPost(userType: widget.userType),
                transitionDuration: Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomNavBar(
          onPress: (int value) => setState(() {
            _selectedIndex = value;
          }),
          userType: widget.userType,
          currentI: 1,
        ));
  }

  int _selectedIndex = 1;

  Widget textArea() {
    var textLength = 0;
    var MaxLength = 250;

    return Container(
      height: 350,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
              RegExp('[ A-Za-z0-9\$_@./#&+-]')) //[0-9a-zA-Z ]
        ],
        controller: textEditingController,
        maxLines: 14,
        maxLength: 250,
        buildCounter: (context,
            {required currentLength, required isFocused, maxLength}) {
          return Container(
            transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
            child: Text("$currentLength/$MaxLength",
                style: const TextStyle(
                    color: Color.fromARGB(136, 6, 40, 61),
                    fontSize: 17,
                    fontWeight: FontWeight.normal)),
          );
        },
        decoration: InputDecoration(
          fillColor: Color.fromARGB(236, 255, 255, 255),
          filled: true,
          hintText: "What would you like to say?",
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 3)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade700, width: 2)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || (value.trim()).isEmpty) {
            return 'Please enter a text to proceed.';
          }
          return null;
        },
      ),
    );
  }
}
