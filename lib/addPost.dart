// import 'dart:js_util';
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:awn/map.dart';

import 'src/locations.dart' as locations;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'main.dart';

class addPost extends StatefulWidget {
  const addPost({Key? key}) : super(key: key);

  @override
  State<addPost> createState() => _MyStatefulWidgetState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class _MyStatefulWidgetState extends State<addPost> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();

  var categories = [
    'Education',
    'Transportation',
    'Government',
    'Entertainment',
    'Other',
  ];

  var selectedCategory;

  String Lat = '', Lng = '';
  void addLocation() async {
    var selectedLoc = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => maps()),
    );
    print(selectedLoc);
    Lat = selectedLoc.latitude.toString();
    Lng = selectedLoc.longitude.toString();
    print(Lat);
    print(Lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
          child: ListView(children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 4),
              child: Text(
                'Institution Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                'Provide some information about the institution.',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: "Name (required)*",
                      hintText: "E.g. King Saud University"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter The Institution Name';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: DropdownButtonFormField(
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                // items:
                // items: <DropdownMenuItem<String>>[
                items: categories.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // DropdownMenuItem(
                //   value: 'Education',
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(15.0),
                //         topRight: Radius.circular(15.0),
                //       ),
                //     ),
                //   ),
                // ),
                // // DropdownMenuItem(
                // //   child: Container(
                // //     decoration: BoxDecoration(
                // //       color: Colors.green,
                // //     ),
                // //   ),
                // ),
                // DropdownMenuItem(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       borderRadius: BorderRadius.only(
                //         bottomLeft: Radius.circular(15.0),
                //         bottomRight: Radius.circular(15.0),
                //       ),
                //     ),
                //   ),
                // ),
                // ],
                value: selectedCategory,
                hint: const Text('Category (required)*'),
                isExpanded: false,
                // style:
                // alignment: Alignment.Center,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 4),
              child: Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(60, 10, 50, 10),
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
                onPressed: addImage,
                child: const Text('Add Image'),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(60, 10, 50, 10),
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
                    Color(0xFF2a3563),
                    Color(0xFF39d6ce),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: addLocation,
                child: const Text('Add Location'),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(60, 10, 50, 10),
              decoration: BoxDecoration(
                boxShadow: [
                  const BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 5.0)
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0xFF2a3563),
                    Color(0xFF39d6ce),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) addToDB;
                },
                child: const Text('Add Post'),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text("Cancel"),
            activeIcon: Text("Cancel"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Add Post"),
            activeIcon: Text("Add Post"),
            label: '',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    if (index == 1) {
      addToDB();
    } else if (index == 0) {
      backToHomePage();
    }
  }

  late File image;
  String? strImg;
  var imageUrl;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Future<String> loadBackground() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("background.png"); //.child(_file_name[0]);

    //get image url from firebase storage
    var url = await ref.getDownloadURL();
    print('url: ' + url);
    return url;
  }

  void backToHomePage() {
    Navigator.pop(context);
  }

  Future<void> addToDB() async {
    final path = 'postsImage/${image}';
    final storage = FirebaseStorage.instance.ref().child(path);
    strImg = Path.basename(image.path);
    UploadTask uploadTask = storage.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    imageUrl = await (await uploadTask).ref.getDownloadURL();
    print('categoryAdded');
    await posts.add({
      'name': nameController.text,
      'description': descriptionController.text,
      'category': selectedCategory,
      'img': imageUrl,
      'latitude': Lat,
      'longitude': Lng,
    }).then((value) => backToHomePage());
  }

  Future<void> addImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        image = File(img!.path);
        if (image != null) {
          print('Image path $image');
        }
      });
    }
  }
}
