import 'package:Awn/addRequest.dart';
import 'package:Awn/homePage.dart';
import 'package:Awn/map.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/userProfile.dart';
import 'package:Awn/viewRequests.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:justino_icons/justino_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'TextToSpeech.dart';
import 'chatPage.dart';
import 'requestWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

//! DONE !//
class addPost extends StatefulWidget {
  final String userType;
  const addPost({Key? key, required this.userType}) : super(key: key);

  @override
  State<addPost> createState() => _MyStatefulWidgetState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
TextEditingController numberController = TextEditingController();
TextEditingController websiteController = TextEditingController();

class _MyStatefulWidgetState extends State<addPost> {
  NotificationService notificationService = NotificationService();
  var isEdited;
  var imgErrorMessage;

  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    isEdited = false;
    imgErrorMessage = false;

    super.initState();
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        if (payload.contains('-')) {
          if (payload.substring(0, payload.indexOf('-')) ==
              'requestAcceptance') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => requestPage(
                    fromSNUNotification: true,
                    userType: 'Special Need User',
                    reqID: payload.substring(payload.indexOf('-') + 1)),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (payload.substring(0, payload.indexOf('-')) == 'chat') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => ChatPage(
                    requestID: payload.substring(payload.indexOf('-') + 1),
                    fromNotification: true),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      viewRequests(userType: 'Volunteer', reqID: payload)));
        }
      });

  final _formKey = GlobalKey<FormState>();

  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  var selectedCategory;

  var editImg = '';
  int _selectedIndex = 2;
  final Storage storage = Storage();
  bool previewImage = false;
  var imagePath, memoryPath;

  //! bottom bar nav
  final iconSNU = <IconData>[
    Icons.home,
    Icons.volume_up,
    Icons.handshake,
    Icons.person,
  ];

  final iconVol = <IconData>[
    Icons.home,
    Icons.handshake,
    Icons.person,
  ];

  editing(var value) {
    setState(() {
      isEdited = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var iconList = widget.userType == 'Volunteer'
        ? <IconData, String>{
            Icons.home: 'Home',
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          }
        : <IconData, String>{
            Icons.home: "Home",
            JustinoIcons.getByName('speech') as IconData: "Text to Speech",
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          };

    Future<void> _onItemTapped(int index) async {
      if (widget.userType == 'Special Need User') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = Tts(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = addRequest(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 3) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      } else if (widget.userType == 'Volunteer') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = viewRequests(userType: widget.userType, reqID: '');
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Container(
                    color: Colors.blue.shade800,
                    height: 1.0,
                  ))),
          centerTitle: true,
          title: const Text('Add a Place Request'),
          automaticallyImplyLeading: false,
          leading: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: FutureBuilder(
                  future: storage.downloadURL('logo.jpg'),
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
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
                    }
                    return Container();
                  }))),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: ListView(children: <Widget>[
            SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            /*name*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: nameController,
                  maxLength: 25,
                  decoration: const InputDecoration(
                      labelText: "Name", hintText: "E.g. King Saud University"),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        (value.trim()).isEmpty) {
                      return 'Please enter the institution name.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (nameController.text.trim() != '') {
                      editing(true);
                    } else {
                      editing(false);
                    }
                  }),
            ),
            /*category*/ Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: StreamBuilder<QuerySnapshot>(
                    stream: category.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Loading");
                      } else {
                        return DropdownButtonFormField(
                          isDense: true,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                            editing(true);
                          },
                          validator: (value) => value == null
                              ? 'Please select a category.'
                              : null,
                          hint: const Text('Category'),
                          items: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return DropdownMenuItem<String>(
                              value: ((document.data() as Map)['category']),
                              child: Text((document.data() as Map)['category']),
                            );
                          }).toList(),
                          value: selectedCategory,
                          isExpanded: false,
                        );
                      }
                    })),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'Institution Image',
              ),
            ),
            /*image*/ Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    previewImage
                        ? AspectRatio(
                            aspectRatio: 2,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0, color: Colors.blue.shade50),
                                    ),
                                    child: Image.memory(
                                      memoryPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        print('error');
                                        return const Text(
                                            'Image could not be load');
                                      },
                                    ))))
                        : Container(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () async {
                          List img = await PickImage(ImageSource.gallery);
                          setState(() {
                            imagePath = img[0];
                            memoryPath = img[1];
                            previewImage = true;
                          });
                          editing(true);
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 20),
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                            ),
                            side: BorderSide(
                                color: imgErrorMessage
                                    ? Colors.red
                                    : Colors.grey.shade400,
                                width: imgErrorMessage ? 2 : 1)),
                        child: Text(editImg == '' ? 'Add Image' : editImg),
                      ),
                    )
                  ],
                ),
                imgErrorMessage
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                          child: Text('Pleas select an image.',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal)),
                        ))
                    : SizedBox(),
              ],
            ),
            //contact info
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            //website
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
                  validator: (value) {
                    if (value!.isNotEmpty && !validator.url(value)) {
                      return 'Please enter a valid website Url';
                    } else if (value == null ||
                        value.isEmpty ||
                        (value.trim()).isEmpty) {
                      return 'Please enter a website.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (websiteController.text.trim() != '') {
                      editing(true);
                    } else {
                      editing(false);
                    }
                  }),
            ),
            //phone number
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                maxLength: 10,
                textAlign: TextAlign.left,
                controller: numberController,
                decoration: const InputDecoration(
                    labelText: 'Contact Number', hintText: '05XXXXXXXX'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      (value.trim()).isEmpty) {
                    return 'Please enter a phone number.';
                  } else {
                    if (value.length > 10 || value.length < 3) {
                      return 'Please enter a valid phone number.';
                    }
                  }
                },
                onChanged: (value) {
                  if (numberController.text.trim() != '') {
                    editing(true);
                  } else {
                    editing(false);
                  }
                },
              ),
            ),
            //description
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 400,
                textAlign: TextAlign.left,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      (value.trim()).isEmpty) {
                    return 'Please enter a description for the place.';
                  }
                },
                onChanged: (value) {
                  if (descriptionController.text.trim() != '') {
                    editing(true);
                  } else {
                    editing(false);
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(60, 10, 50, 10),
              width: 250,
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
                    Color(0xFF39d6ce),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                  minimumSize: (const Size(250, 50)),
                ),
                onPressed: () {
                  if (!previewImage) {
                    _formKey.currentState!.validate();
                    setState(() {
                      imgErrorMessage = true;
                    });
                  } else if (_formKey.currentState!.validate()) {
                    addToDB();
                  } else {}
                },
                child: const Text('Next'),
              ),
            ),
          ]),
        ),
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
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        splashColor: Colors.blue,
        backgroundColor: Colors.white,
        splashRadius: 1,
        splashSpeedInMilliseconds: 100,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          final size = isActive ? 30.0 : 25.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList.keys.toList()[index],
                size: size,
                color: color,
              ),
              const SizedBox(height: 1),
              Visibility(
                visible: isActive,
                child: Text(
                  iconList.values.toList()[index],
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      letterSpacing: 1,
                      wordSpacing: 1),
                ),
              )
            ],
          );
        },
        activeIndex: -1,
        itemCount: widget.userType == 'Volunteer' ? 3 : 4,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }

  File? imageDB;
  String strImg = '';

  Future<List<dynamic>> PickImage(var imgSource) async {
    List<dynamic> imageList = <dynamic>[];
    Uint8List text = Uint8List(3);
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      var imageChat = await ImagePicker().pickImage(source: imgSource);
      Uint8List imageData = await imageChat!.readAsBytes();
      imageList.add(imageChat);
      imageList.add(imageData);
      editImg = 'Change Image';

      return imageList;
    }
    return text;
  }

  Future<void> addImage(var imageChat) async {
    imagePath = '';
    File? imageDB;
    String strImg = '';

    File imagee = File(imageChat!.path);
    imagePath = imagee.toString();
    imageDB = imagee;
    File image = imageDB;
    final storage = FirebaseStorage.instance.ref().child('postsImage/${image}');
    strImg = Path.basename(image.path);
    UploadTask uploadTask = storage.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    imagePath = await (await uploadTask).ref.getDownloadURL();
  }

  Future<void> addToDB() async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    await addImage(imagePath);
    print(imagePath);
    DateTime _date = DateTime.now();
    String date = DateFormat('yyyy-MM-dd HH: mm').format(_date);

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    DocumentReference docReference = await posts.add({
      'name': nameController.text,
      'searchName': (nameController.text).toLowerCase(),
      'category': selectedCategory,
      'img': imagePath,
      'latitude': '',
      'longitude': '',
      'Website': websiteController.text,
      'Phone number': numberController.text,
      'description': descriptionController.text,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'docId': '',
      'status': 'Pending',
      'date': date
    });
    dataId = docReference.id;
    posts.doc(dataId).update({'docId': dataId});
    print("Document written with ID: ${docReference.id}");

    print('added to db');
    clearForm();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => maps(dataId: dataId, typeOfRequest: 'P'),
        ));
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    numberController.clear();
    websiteController.clear();
    imagePath = '';
    imgErrorMessage = false;
    previewImage = false;
  }

  Future<dynamic> alertDialog(var nav) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          "Discard the changes you made?",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Keep editing"),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => nav,
                  transitionDuration: const Duration(seconds: 1),
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              clearForm();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Discard",
                  style: TextStyle(color: Color.fromARGB(255, 164, 10, 10))),
            ),
          ),
        ],
      ),
    );
  }
}
