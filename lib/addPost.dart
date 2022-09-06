import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class addPost extends StatefulWidget {
  const addPost({Key? key}) : super(key: key);

  @override
  State<addPost> createState() => _MyStatefulWidgetState();
}

TextEditingController nameController = TextEditingController();
TextEditingController contactInfoController = TextEditingController();
TextEditingController descriptionController = TextEditingController();

class _MyStatefulWidgetState extends State<addPost> {
  @override
  Widget build(BuildContext context) {
    print("hello");
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منشور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15),
              child: const Text(
                'كن عون',
                style: TextStyle(fontSize: 20),
              )),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              textAlign: TextAlign.right,
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: "الاسم", hintText: "مثال: جامعة الملك سعود"),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              textAlign: TextAlign.right,
              controller: contactInfoController,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
          ),
          ElevatedButton(
            onPressed: addImage,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(width: 3, color: Colors.black),
                ),
              ),
            ),
            child: Text('أضف صورة'),
          ),
          Text(
            strImg ?? '',
          ),
          ElevatedButton(
            onPressed: addToDB,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(width: 3, color: Colors.black),
                ),
              ),
            ),
            child: Text('أضف منشور'),
          )
        ]),
      ),
    );
  }

  late File image;
  String? strImg;
  var imageUrl;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  final storage = FirebaseStorage.instance.ref('postsImage');

  Future<void> addToDB() async {
    // strImg = image.path;s
    if (image != null) {
      UploadTask uploadTask = storage.ref().child(image.path).putFile(image);
      print('uploaded to storage');
      imageUrl = await (await uploadTask).ref.getDownloadURL();
    }
    print("2");
    await posts.add({
      'name': nameController.text,
      'img': imageUrl,
    }).then((value) => print("Post Added"));
  }

  Future<void> addImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      print('109');
      setState(() {
        image = File(img!.path);
        if (image != null) {
          print('not null'); //yes
        }
      });
    }
  }

// // class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({Key? key}) : super(key: key);

//   @override
//   // State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController contactInfoController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(10),
//         child: ListView(
//           children: <Widget>[
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'TutorialKart',
//                   style: TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 30),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'كن عون',
//                   style: TextStyle(fontSize: 20),
//                 )),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//               child: TextField(
//                 obscureText: true,
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Password',
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 //forgot password screen
//               },
//               child: const Text(
//                 'Forgot Password',
//               ),
//             ),
//             Container(
//                 height: 50,
//                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                 child: ElevatedButton(
//                   child: const Text('Login'),
//                   onPressed: () {
//                     print(nameController.text);
//                     print(passwordController.text);
//                   },
//                 )),
//             Column(
//               children: [
//                 RadioListTile(
//                   title: Text("Male"),
//                   value: "male",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 ),
//                 RadioListTile(
//                   title: Text("Female"),
//                   value: "female",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 ),
//                 RadioListTile(
//                   title: Text("Other"),
//                   value: "other",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 )
//               ],
//             )
//           ],
//         ));
//   }
// }
}
