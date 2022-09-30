import 'package:awn/addPost.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:flutter/material.dart';
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

  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
    setState(() {
      flag = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const SizedBox(
            child: Text('Text To Speech'),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Container(
                    color: Color.fromARGB(255, 185, 219, 247),
                    height: 1.0,
                  ))),
        ),
        body: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: const Text(
                "Please Write in English",
              ),
            ),
          ),
          textArea(),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: const Text(
                "*Please Write in English",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(50, 20, 50, 0),
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
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(const Size(50, 50)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      'Play',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (textEditingController.text.isNotEmpty &&
                          textEditingController.text.length > 0) {
                        flag = true;
                        flag1 = false;
                      }
                      if (textEditingController.text.trim().length == 0) {
                        flag1 = true;
                      }
                    });
                    speak(textEditingController.text);
                  })),
          flag ? const CircularProgressIndicator() : const Text(""),
          flag1 ? const Text('please enter a text to proceed') : const Text(""),
        ]),
        // Container(
        //     padding: const EdgeInsets.symmetric(vertical: 0),
        //     child: Column(children: [
        //       Expanded(
        //           child: Container(
        //         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        //         alignment: Alignment.center,
        //         margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        //         child: Column(children: [
        //           Align(
        //             alignment: Alignment.centerLeft,
        //             child: Container(
        //               padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        //               child: const Text(
        //                 "Please Write in English",
        //               ),
        //             ),
        //           ),
        //           Container(
        //               padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        //               child: TextFormField(
        //                   controller: textEditingController,
        //                   scrollController: _scrollController,
        //                   maxLines: 10,
        //                   maxLength: 300,
        //                   decoration: InputDecoration(
        //                     hintText: "Start Typing...",
        //                     focusedBorder: OutlineInputBorder(
        //                         borderRadius: BorderRadius.circular(15.0),
        //                         borderSide: BorderSide(color: Colors.blue)),
        //                     enabledBorder: OutlineInputBorder(
        //                         borderRadius: BorderRadius.circular(15.0),
        //                         borderSide:
        //                             BorderSide(color: Colors.grey.shade400)),
        //                   ))),
        //           Align(
        //             alignment: Alignment.centerLeft,
        //             child: Container(
        //               padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        //               child: const Text(
        //                 "*Please Write in English",
        //                 style: TextStyle(
        //                     fontSize: 13, fontWeight: FontWeight.normal),
        //               ),
        //             ),
        //           ),
        //           Container(
        //               margin: const EdgeInsets.fromLTRB(50, 20, 50, 0),
        //               decoration: BoxDecoration(
        //                 boxShadow: const [
        //                   BoxShadow(
        //                       color: Colors.black26,
        //                       offset: Offset(0, 4),
        //                       blurRadius: 5.0)
        //                 ],
        //                 gradient: const LinearGradient(
        //                   begin: Alignment.topLeft,
        //                   end: Alignment.bottomRight,
        //                   stops: [0.0, 1.0],
        //                   colors: [
        //                     Colors.blue,
        //                     Colors.cyanAccent,
        //                   ],
        //                 ),
        //                 borderRadius: BorderRadius.circular(30),
        //               ),
        //               child: ElevatedButton(
        //                   style: ButtonStyle(
        //                     shape: MaterialStateProperty.all<
        //                         RoundedRectangleBorder>(
        //                       RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(30.0),
        //                       ),
        //                     ),
        //                     minimumSize:
        //                         MaterialStateProperty.all(const Size(50, 50)),
        //                     backgroundColor:
        //                         MaterialStateProperty.all(Colors.transparent),
        //                     shadowColor:
        //                         MaterialStateProperty.all(Colors.transparent),
        //                   ),
        //                   child: const Padding(
        //                     padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        //                     child: Text(
        //                       'Play',
        //                       textAlign: TextAlign.center,
        //                     ),
        //                   ),
        //                   onPressed: () {
        //                     setState(() {
        //                       if (textEditingController.text.isNotEmpty &&
        //                           textEditingController.text.length > 0) {
        //                         flag = true;
        //                         flag1 = false;
        //                       }
        //                       if (textEditingController.text.trim().length ==
        //                           0) {
        //                         flag1 = true;
        //                       }
        //                     });
        //                     speak(textEditingController.text);
        //                   })),
        //           flag ? const CircularProgressIndicator() : const Text(""),
        //           flag1
        //               ? const Text('please enter a text to proceed')
        //               : const Text(""),
        //         ]),
        //       ))
        //     ])),
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => addPost(userType: widget.userType)));
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
    var MaxLength = 300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16),
      child: Stack(
        children: [
          Container(
            // width: 600,
            // height: 380,
            // margin: const EdgeInsets.only(top: 12),
            // padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 32, color: Colors.black45, spreadRadius: -8)
                ],
                borderRadius: BorderRadius.circular(15)),
            child: TextFormField(
              controller: textEditingController,
              maxLines: 17,
              maxLength: 10,
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
                counterText: '',
                hintText: "What would you like to say?",
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 185, 219, 247), width: 3)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.white, width: 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
