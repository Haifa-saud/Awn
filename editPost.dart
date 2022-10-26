import 'package:awn/addRequest.dart';
import 'package:awn/homePage.dart';
import 'package:awn/map.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'addPost.dart';
import 'login.dart';
import 'services/firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'main.dart';

class editPost extends StatefulWidget {
  final String userType;
  final String name;
  final String number;
  final String description;
  final String website;
  final String category;
  final String docId;
  final String oldImg;
  const editPost(
      {Key? key,
      required this.userType,
      required this.name,
      required this.number,
      required this.description,
      required this.website,
      required this.category,
      required this.docId,
      required this.oldImg})
      : super(key: key);

  @override
  State<editPost> createState() => _MyStatefulWidgetState();
}

// TextEditingController nameController = TextEditingController();
late TextEditingController nameController;
//late TextEditingController contactInfoController;
late TextEditingController descriptionController;
late TextEditingController numberController;
late TextEditingController websiteController;
late var imagectrl;

class _MyStatefulWidgetState extends State<editPost> {
  late final NotificationService notificationService;
  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
    numberController = TextEditingController(text: widget.number);
    websiteController = TextEditingController(text: widget.website);
    imagectrl = widget.oldImg;

    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print(payload);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });
  final _formKey = GlobalKey<FormState>();

  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  var selectedCategory;

  var editImg = '';
  int _selectedIndex = 2;
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  color: Colors.grey,
                  height: 1.0,
                ))),
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
        title: const Text('Edit Place', textAlign: TextAlign.center),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: ListView(children: <Widget>[
            Container(
                child: Text(
              '*indicates required fields',
              style: TextStyle(fontSize: 15),
            )),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Details*',
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
              ),
            ),
            /*category*/ Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: StreamBuilder<QuerySnapshot>(
                    stream: category.snapshots(),
                    builder: (context, snapshot) {
                      selectedCategory = widget.category;
                      if (!snapshot.hasData) {
                        return Text("Loading");
                      } else {
                        return DropdownButtonFormField(
                          isDense: true,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a category.'
                              : null,
                          // hint: const Text('Category'),
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
                'Institution Image*',
              ),
            ),
            /*image*/ Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: addImage,
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          side: BorderSide(
                              color: Colors.grey.shade400, width: 1)),
                      child: Text(editImg == '' ? 'Add Image' : editImg),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 0, 4),
                      child: Text(
                        imagePath,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5.0,
                      bottom: 5.0,
                      child: InkWell(
                        child: Icon(
                          Icons.remove_circle,
                          size: 30,
                          color: Colors.red,
                        ),
                        onTap: () {
                          setState(
                            () {
                              imagePath = '';
                              imageDB = null;
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)
                    // topLeft: Radius.circular(16.0),
                    // topRight: Radius.circular(16.0),
                    ),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Image.network(
                    imagectrl,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Text('Image could not be load');
                    },
                  ),
                )),
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
                  }
                  return null;
                },
              ),
            ),
            //phone number
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                // maxLength: 10,
                textAlign: TextAlign.left,
                controller: numberController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', hintText: '05XXXXXXXX'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    print('empty');
                  } else {
                    // if (value.length != 10) {
                    //   return 'Please enter a phone number of 10 digits';
                    // }
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
                maxLines: 4,
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
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
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
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print(selectedCategory);
                    updateDB(widget.docId);
                  } else {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //         'Please fill in the required fields above, and in the specified format (if any).'),
                    //     backgroundColor: Colors.red.shade400,
                    //     margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
                    //     behavior: SnackBarBehavior.floating,
                    //     action: SnackBarAction(
                    //       label: 'Dismiss',
                    //       disabledTextColor: Colors.white,
                    //       textColor: Colors.white,
                    //       onPressed: () {
                    //         //Do whatever you want
                    //       },
                    //     ),
                    //   ),
                    // );
                  }
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
        currentI: -1,
      ),
    );
  }

  String imagePath = '';
  File? imageDB;
  String strImg = '';

  Future<void> addImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);

      setState(() {
        File image = File(img!.path);
        //  print('Image path $image');
        imagePath = image.toString();
        imageDB = image;
        editImg = 'Update Image';
        imagectrl = imagePath;
      });
    }
  }

  Future<void> updateDB(docId) async {
    final posts = FirebaseFirestore.instance.collection('posts').doc(docId);

    if (imagePath != '') {
      File image = imageDB!;
      final storage =
          FirebaseStorage.instance.ref().child('postsImage/${image}');
      strImg = Path.basename(image.path);
      UploadTask uploadTask = storage.putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      imagePath = await (await uploadTask).ref.getDownloadURL();
    }
    DateTime _date = DateTime.now();
    String date = DateFormat('yyyy-MM-dd HH: mm').format(_date);

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    posts.update({
      'name': nameController.text,
      'category': selectedCategory,
      //  'img': imagePath,
      // 'latitude': '',
      // 'longitude': '',
      'Website': websiteController.text,
      'Phone number': numberController.text,
      'description': descriptionController.text,
      // 'userId': FirebaseAuth.instance.currentUser!.uid,
      // 'docId': '',
      //  'status': 'Pending',
      //'date': date
    });

    // clearForm();

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => maps(dataId: dataId, typeOfRequest: 'P'),
    //     ));
  }
  // Future<void> addToDB() async {
  //   CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  //   if (imagePath != '') {
  //     File image = imageDB!;
  //     final storage =
  //         FirebaseStorage.instance.ref().child('postsImage/${image}');
  //     strImg = Path.basename(image.path);
  //     UploadTask uploadTask = storage.putFile(image);
  //     TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
  //     imagePath = await (await uploadTask).ref.getDownloadURL();
  //   }
  //   DateTime _date = DateTime.now();
  //   String date = DateFormat('yyyy-MM-dd HH: mm').format(_date);

  //   String dataId = '';
  //   print('will be added to db');
  //   //add all value without the location
  //   DocumentReference docReference = await posts.add({
  //     'name': nameController.text,
  //     'category': selectedCategory,
  //     'img': imagePath,
  //     'latitude': '',
  //     'longitude': '',
  //     'Website': websiteController.text,
  //     'Phone number': numberController.text,
  //     'description': descriptionController.text,
  //     'userId': FirebaseAuth.instance.currentUser!.uid,
  //     'docId': '',
  //     'status': 'Pending',
  //     'date': date
  //   });
  //   dataId = docReference.id;
  //   posts.doc(dataId).update({'docId': dataId});
  //   print("Document written with ID: ${docReference.id}");

  //   print('added to db');
  //   clearForm();

  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => maps(dataId: dataId, typeOfRequest: 'P'),
  //       ));
  // }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    numberController.clear();
    websiteController.clear();
    imagePath = '';
  }
}
