// import 'dart:js_util';
import 'package:awn/map.dart';
import 'package:flutter/services.dart';
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
TextEditingController numberController = TextEditingController();
TextEditingController websiteController = TextEditingController();

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
  String locMsg = '', imageMsg = '';
  void addLocation() async {
    var selectedLoc = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const maps()),
    );
    print(selectedLoc);
    locMsg = selectedLoc.toString();

    if (selectedLoc != null) {
      Lat = selectedLoc.latitude.toString();
      Lng = selectedLoc.longitude.toString();
    }
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
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
            //   child: Text(
            //     'Provide some information about the institution.',
            //     style: TextStyle(fontWeight: FontWeight.normal),
            //   ),
            // ),
            /*name*/ Container(
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
                      return 'Please enter the institution name.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            /*category*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: DropdownButtonFormField(
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category.' : null,
                items: categories.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                value: selectedCategory,
                hint: const Text('Category (required)*'),
                isExpanded: false,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            /*location*/ Column(
              children: [
                ElevatedButton(
                  onPressed: addLocation,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey.shade500,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(14, 20, 14, 20),
                      side: BorderSide(color: Colors.grey.shade400, width: 1)),
                  child: const Text('Add Location (required)*'),
                ),
                // ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 4),
                  child: Text(
                    locMsg,
                    style: TextStyle(
                        fontSize: 15,
                        color: imageMsg == 'Please add a location.'
                            ? Colors.red
                            : Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            /*image*/ Column(
              children: [
                ElevatedButton(
                  onPressed: addImage,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey.shade500,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(14, 20, 14, 20),
                      side: BorderSide(color: Colors.grey.shade400, width: 1)),
                  child: const Text('Add Image (required)*'),
                ),
                // ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 4),
                  child: Text(
                    imageMsg,
                    style: TextStyle(
                        fontSize: 15,
                        color: imageMsg == 'Please add an image.'
                            ? Colors.red
                            : Colors.grey.shade500),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
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
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                textAlign: TextAlign.left,
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
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
                maxLength: 150,
                textAlign: TextAlign.left,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
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
                onPressed:
                    // if (_formKey.currentState!.validate())
                    addToDB,
                child: const Text('Add Post'),
              ),
            ),
          ]),
        ),
      ),
      //   bottomNavigationBar: BottomNavigationBarTheme(
      //     data: BottomNavigationBarThemeData(
      //       backgroundColor: Colors.blue.shade100,
      //       unselectedItemColor:  Color(0xFFF434A50),
      //       elevation: 3.0,
      //       unselectedIconTheme:
      //           const IconThemeData(color: Colors.yellow, size: 30, opacity: 0.5),
      //       // enableFeedback: true,
      //       // unselectedIconTheme: Size(15, 14),
      //       // type: BottomNavigationBarType.,
      //     ),
      //     child: BottomNavigationBar(
      //       items: const <BottomNavigationBarItem>[
      //         BottomNavigationBarItem(
      //           icon: Text("Cancel"),
      //           activeIcon: Text("Cancel"),
      //           label: '',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Text("Add Post"),
      //           activeIcon: Text("Add Post"),
      //           label: '',
      //         )
      //       ],
      //       currentIndex: _selectedIndex,
      //       onTap: _onItemTapped,
      //     ),
      //   ),
    );
  }

  // int _selectedIndex = 0;
  // void _onItemTapped(int index) {
  //   if (index == 1) {
  //     addToDB();
  //   } else if (index == 0) {
  //     backToHomePage();
  //   }
  // }

  late File image;
  String? strImg;
  var imageUrl;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  void backToHomePage() {
    Navigator.pop(context);
  }

  Future<void> addToDB() async {
    try {
      print('test');
      final path = 'postsImage/${image}';
      final storage = FirebaseStorage.instance.ref().child(path);
      strImg = Path.basename(image.path);
      UploadTask uploadTask = storage.putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      if (locMsg != '' && imageMsg != '') {
        print('will be added to db');
        await posts.add({
          'name': nameController.text,
          'description': descriptionController.text,
          'category': selectedCategory,
          'img': imageUrl,
          'latitude': Lat,
          'longitude': Lng,
        }).then((value) {
          nameController.clear();
          descriptionController.clear();
          numberController.clear();
          websiteController.clear();
          locMsg = '';
          imageMsg = '';
          backToHomePage();
        });
      } else if (locMsg == '') {
        locMsg = 'Please add a location.';
        print(locMsg);
        if (imageMsg == '') {
          imageMsg = 'Please add an image.';
          print(imageMsg);
        }
      } else {
        imageMsg = 'Please add an image.';
        print(imageMsg);
      }
    } catch (e) {
      imageMsg = 'Please add an image.';
      print(imageMsg);
    }
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
          imageMsg = image.toString();
        }
      });
    }
  }
}
