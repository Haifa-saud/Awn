// import 'dart:js_util';
// import 'dart:js_util';
import 'map.dart';
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


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:readmore/readmore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:workmanager/workmanager.dart';
// import 'services/firebase_options.dart';

class addPost extends StatefulWidget {
  const addPost({Key? key}) : super(key: key);

  @override
  State<addPost> createState() => _MyStatefulWidgetState();
}
String commenter = '';
var now = DateTime.now();
var formatterDate = DateFormat('dd/MM/yy');
var formatterTime = DateFormat('kk:mm');
String actualDate = formatterDate.format(now);
String actualTime = formatterTime.format(now);
TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class _MyStatefulWidgetState extends State<addPost> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();

   var userData;
   var userId = FirebaseAuth.instance.currentUser!.uid;
    Future<Map<String, dynamic>> readUserData() => FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        (DocumentSnapshot doc) {
          print(doc.data() as Map<String, dynamic>);
          return doc.data() as Map<String, dynamic>;
        },
      );
     //userData = snapshot.data as Map<String, dynamic>;
     


  

  var editImg = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: readUserData(),
          builder: ( BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              print( userData['Type'] );
              commenter = userData['name'];

            } else {
              return const Text('');
            }
          }),);



    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Post', textAlign: TextAlign.center),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: const Text('Discard the changes you made?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () {
                    clearForm();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Discard'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: ListView(children: <Widget>[
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
            
            //add image code
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
            //   child: Text(
            //     'Institution Image',
            //   ),
            // ),
            // /*image*/ Column(
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         ElevatedButton(
            //           onPressed: addImage,
            //           style: ElevatedButton.styleFrom(
            //               foregroundColor: Colors.blue,
            //               backgroundColor: Colors.white,
            //               padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            //               textStyle: const TextStyle(
            //                 fontSize: 18,
            //               ),
            //               side: BorderSide(
            //                   color: Colors.grey.shade400, width: 1)),
            //           child: Text(editImg == '' ? 'Add Image' : editImg),
            //         ),
            //       ],
            //     ),
            //     Stack(
            //       children: [
            //         Padding(
            //           padding: EdgeInsets.fromLTRB(8, 8, 0, 4),
            //           child: Text(
            //             imagePath,
            //             style: TextStyle(
            //               fontSize: 15,
            //             ),
            //           ),
            //         ),
            //         Positioned(
            //           right: 5.0,
            //           bottom: 5.0,
            //           child: InkWell(
            //             child: Icon(
            //               Icons.remove_circle,
            //               size: 30,
            //               color: Colors.red,
            //             ),
            //             // This is where the _image value sets to null on tap of the red circle icon
            //             onTap: () {
            //               setState(
            //                 () {
            //                   imagePath = '';
            //                   imageDB = null;
            //                 },
            //               );
            //             },
            //           ),
            //         )
            //       ],
            //     ),
            //   ],
            // ),


            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'comment',
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
                    addToDB();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please fill in the required fields above, and in the specified format (if any).'),
                        backgroundColor: Colors.red.shade400,
                        margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Dismiss',
                          disabledTextColor: Colors.white,
                          textColor: Colors.white,
                          onPressed: () {
                            //Do whatever you want
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Post'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // String imagePath = '';
  // File? imageDB;
  // String strImg = '';

  // Future<void> addImage() async {
  //   await Permission.photos.request();
  //   var permissionStatus = await Permission.photos.status;
  //   if (permissionStatus.isGranted) {
  //     XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     setState(() {
  //       File image = File(img!.path);
  //       print('Image path $image');
  //       imagePath = image.toString();
  //       imageDB = image;
  //       editImg = 'Update Image';
  //     });
  //   }
  // }

  Future<void> addToDB() async {
    CollectionReference posts = FirebaseFirestore.instance.collection('comment');

    //in case the user uploaded an image
    // if (imagePath != '') {
    //   File image = imageDB!;
    //   final storage =
    //       FirebaseStorage.instance.ref().child('postsImage/${image}');
    //   strImg = Path.basename(image.path);
    //   UploadTask uploadTask = storage.putFile(image);
    //   TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    //   imagePath = await (await uploadTask).ref.getDownloadURL();
    // }

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    DocumentReference docReference = await posts.add({
      'date': actualDate,
      'name': commenter,
      'time': actualTime,
      //'img': imagePath,
      'text': descriptionController.text,
      'UserID': userId,
      //'PostID':

    });
    dataId = docReference.id;
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
    descriptionController.clear();
    //imagePath = '';
  }
}
