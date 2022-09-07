import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  var categories = [
    'Education',
    'Transportation',
    'Government',
    'Entertainment',
    'Other',
  ];

  var selectedCategory;

  @override
  Widget build(BuildContext context) {
    print("hello");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(children: <Widget>[
          // Container(
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.all(15),
          //     child: const Text(
          //       'كن عون',
          //       style: TextStyle(fontSize: 20),
          //     )),
          Container(
            padding: const EdgeInsets.all(15),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                textAlign: TextAlign.left,
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Name", hintText: "E.g. King Saud University"),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                textAlign: TextAlign.left,
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: DropdownButton(
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              value: selectedCategory,
              hint: Text('Select the category'),
              isExpanded: false,
              // alignment: Alignment.Center,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(60, 10, 60, 0),
            child: ElevatedButton(
              onPressed: addImage,
              child: Text('Add Image'),
            ),
          ),
          // Text(
          //   strImg ?? '',
          // ),
          Container(
            padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
            child: ElevatedButton(
              onPressed: addToDB,
              child: Text('Add Post'),
            ),
          ),
        ]),
      ),
    );
  }

  late File image;
  String? strImg;
  var imageUrl;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

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
    }).then((value) => backToHomePage()); //print("Post Added"));
  }

  void backToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Future<void> addImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      print('116');
      setState(() {
        image = File(img!.path);
        if (image != null) {
          print('Image path $image'); //yes
        }
      });
    }
  }
}
