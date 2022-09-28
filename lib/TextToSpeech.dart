import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:get/get_state_manager/get_state_manager.dart';

class Tts extends StatefulWidget {
  const Tts({Key? key}) : super(key: key);

  @override
  _TtsState createState() => _TtsState();
}

class _TtsState extends State<Tts> {
  @override
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool flag = false;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const SizedBox(
          child: Text('Awn',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(70),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(30, 50, 30, 0),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 50, 0),
                    child: const Text(
                      "*please write in english",
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: TextFormField(
                        controller: textEditingController,
                        scrollController: _scrollController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "start typing...",
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400)),
                        ))),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          minimumSize:
                              MaterialStateProperty.all(const Size(50, 50)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        icon: const Icon(
                          Icons.speaker_phone,
                        ),
                        label: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(
                            'Text to speech',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (textEditingController.text.isNotEmpty &&
                                textEditingController.text.length > 500) {
                              flag = true;
                            }
                          });
                          speak(textEditingController.text);
                        })),
                flag ? const CircularProgressIndicator() : const Text(""),
              ]),
            ))
          ])),
      bottomNavigationBar:
          Container(child: LayoutBuilder(builder: (context, constraints) {
        return BottomNavigationBar(
          unselectedLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 37, 37, 37), fontSize: 14),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              //index 0
              icon: Icon(Icons.add, color: Colors.grey.shade700),
              activeIcon: Icon(Icons.add, color: Colors.grey.shade700),
              label: 'Add Post',
            ),
            BottomNavigationBarItem(
              //index 1
              icon: Icon(Icons.handshake, color: Colors.grey.shade700),
              activeIcon: Icon(Icons.handshake, color: Colors.grey.shade700),
              label: 'Request Awn',
            ),
            BottomNavigationBarItem(
              //index 1

              icon: Icon(Icons.speaker_phone, color: Colors.grey.shade700),
              activeIcon:
                  Icon(Icons.speaker_phone, color: Colors.grey.shade700),
              label: 'Tts',
            ),
            /*BottomNavigationBarItem(
                //index 2
                icon: Icon(Icons.handshake, color: Colors.grey.shade700),
                activeIcon: Icon(Icons.handshake, color: Colors.grey.shade700),
                label: 'View Requests',
              ),*/
            BottomNavigationBarItem(
              //index 3
              icon: Icon(Icons.logout, color: Colors.grey.shade700),
              activeIcon: Icon(Icons.logout, color: Colors.grey.shade700),
              label: 'Logout',
            )
          ],
          currentIndex: _selectedIndex,
          //onTap: _onItemTapped,
        );
      })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _selectedIndex = 0;
}
