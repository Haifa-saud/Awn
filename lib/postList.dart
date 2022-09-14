//import 'package:flutter/foundation.dart';
//import 'dart:html';

import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:image_picker/image_picker.dart';
//import 'dart:io';
//import 'package:path/path.dart' as Path;
//import 'package:intl/intl.dart';
import 'main.dart';

class Postlist extends StatefulWidget {
  const Postlist({Key? key}) : super(key: key);
  @override
  State<Postlist> createState() => _MyPostListState();
}

class _MyPostListState extends State<Postlist> {
  final Stream<QuerySnapshot> posts = FirebaseFirestore.instance
      .collection('posts')
      .orderBy("category")
      .snapshots();

  // Widget _cardUi(Post post) {
  //   return Card(
  //     margin: const EdgeInsets.all(16.0),
  //     elevation: 10.0,
  //     child: Container(
  //       padding: EdgeInsets.all(14.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 post.name,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: 16.0,
  //                   color: Colors.grey,
  //                   fontStyle: FontStyle.italic,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           // SizedBox(height: 10.0),
  //           // Image.network(
  //           //   post.img,
  //           //   width: double.infinity,
  //           //   height: 30,
  //           //   fit: BoxFit.cover,
  //           //   errorBuilder: (BuildContext context, Object exception,
  //           //       StackTrace? stackTrace) {
  //           //     return const Text('Image couldnt load');
  //           //   },
  //           // ),
  //           //SizedBox(height: 10.0),
  //           // Column(
  //           //   crossAxisAlignment: CrossAxisAlignment.start,
  //           //   children: [
  //           //     ExpansionTile(
  //           //       title: Text(
  //           //         post.name,
  //           //         style: const TextStyle(
  //           //           fontSize: 20.0,
  //           //           color: Colors.black,
  //           //         ),
  //           //       ),
  //           //       // trailing: Icon(Icon.),
  //           //       children: [
  //           // SizedBox(
  //           //   width: 450,
  //           //   child: Text(
  //           //     "Descriptin: ${post.description}",
  //           //     style: const TextStyle(
  //           //       fontSize: 15.0,
  //           //       color: Color.fromARGB(158, 0, 0, 0),
  //           //     ),
  //           //   ),
  //           // ),
  //           // SizedBox(
  //           //   width: 450,
  //           //   child:
  //           //       //if (post.website != null)
  //           //       Text(
  //           //     'website: ${post.website}',
  //           //     style: const TextStyle(
  //           //       fontSize: 15.0,
  //           //       color: Color.fromARGB(158, 0, 0, 0),
  //           //     ),
  //           //   ),
  //           // ),
  //           // SizedBox(
  //           //   width: 450,
  //           //   child:
  //           //       // if (post.phonenumber != null)
  //           //       Text(
  //           //     "phone number ", //:${post.phonenumber}",
  //           //     style: const TextStyle(
  //           //       fontSize: 15.0,
  //           //       color: Color.fromARGB(158, 0, 0, 0),
  //           //     ),
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //       // ],
  //       // )
  //       // ]
  //       // ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Future<void> _onItemTapped(int index) async {
      if (index == 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addPost()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addRequest()),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => viewRequests()),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const SizedBox(
          width: 700,
          child: Text('Awn',
              textAlign: TextAlign.center,
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
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: posts,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            print('line 48');
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('line 51');
                            return CircularProgressIndicator();
                          }
                          final data = snapshot.requireData;
                          print('line 55');
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              print('line 59');
                              return Card(
                                  child: Column(
                                children: [
                                  //title
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 0, 290, 15),
                                    child: Text(
                                      ' ${data.docs[index]['name']}',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  //category
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                                    child: Text(
                                        ' ${data.docs[index]['category']}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  //website
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        Text('${data.docs[index]['Website']}',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  //phone number
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        Text(
                                            '${data.docs[index]['Phone number']}',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  //description
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                              'Description: ${data.docs[index]['description']}',
                                              //   overflow:
                                              //   TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //location
                                  Padding(
                                      padding: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            double latitude = double.parse(data
                                                .docs[index]['latitude']
                                                .toString());
                                            double longitude = double.parse(data
                                                .docs[index]['longitude']
                                                .toString());

                                            (Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MapsPage(
                                                          latitude: latitude,
                                                          longitude: longitude),
                                                )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.grey.shade500,
                                              backgroundColor: Colors.white,
                                              padding: EdgeInsets.fromLTRB(
                                                  14, 20, 14, 20),
                                              side: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 2)),
                                          child: Text('Location',
                                              style: TextStyle(
                                                  color: Colors.black)))),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 20, color: Colors.red),
                                        Text('location',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                            },
                          );
                        },
                      )))
            ],
          )),

      // Container(
      //     child: StreamBuilder<QuerySnapshot>(
      //   stream: posts,
      //   builder: (
      //     BuildContext context,),
      //     AsyncSnapshot snapshot,),),
      //   ) {
      //     if (snapshot.hasError) {
      //       return Center(child: Text(snapshot.error.toString()));
      //     }
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       print('line 51');
      //       return CircularProgressIndicator();
      //     }
      //     if (snapshot.connectionState == ConnectionState.active) {
      //       QuerySnapshot querySnapshot = snapshot.data;
      //     }
      //     if (!snapshot.hasData) {
      //       return Center(child: CircularProgressIndicator());
      //     } else {
      //       final data = snapshot.data.docs;
      // //       return ListView.builder(
      // //         itemCount: data.size,
      // //         itemBuilder: (context, index) {
      // //           // Map<String, dynamic> postMap = snapshot.data.docs[index].data();
      // //           // Post post = Post(
      // //           //     postMap['img'],
      // //           //     postMap['name'],
      // //           //     postMap['category'],
      // //           //     postMap['description'],
      // //           //     postMap['Website'],
      // //           //     postMap['Phone number'],
      // //           //     postMap['latitude'],
      // //           //     postMap['longitude']);
      // //           return Card(
      // // margin: const EdgeInsets.all(16.0),
      // // elevation: 10.0,
      // // child: Container(
      // //   padding: EdgeInsets.all(14.0),
      // //   child: Column(
      // //     crossAxisAlignment: CrossAxisAlignment.start,
      // //     children: [
      // //       Row(
      // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // //         children: [
      // //           Text(
      // //               ' ${data.docs[index]['name']}',
      // //             textAlign: TextAlign.center,
      // //             style: const TextStyle(
      // //               fontSize: 16.0,
      // //               color: Colors.grey,
      // //               fontStyle: FontStyle.italic,
      // //             ),
      // //           ),
      // //         ],
      // //       ),
      // //       ],
      // //       ),
      // //       ),
      // //       );

      // //       };
      // //       ),
      // //   },
      // // )),
      //     }}),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF39d6ce),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Postlist()),
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Add Post'),
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.yellow,
              onPressed: () {
                //Do whatever you want
              },
            ),
          ));
        },
        tooltip: 'Increment',
        elevation: 4.0,
        child: PopupMenuButton<int>(
          offset: Offset(0, -170),
          itemBuilder: (context) => const [
            PopupMenuItem<int>(
                value: 0,
                child: Text(
                  'Item 0',
                )),
            PopupMenuItem<int>(
                value: 1,
                child: Text(
                  'Item 1',
                )),
            PopupMenuItem<int>(
                value: 2,
                child: Text(
                  'Item 2',
                )),
          ],
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            //index 0
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text("Add Post"),
            activeIcon: Text("Add Post"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Awn Request"),
            activeIcon: Text("Add Request"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("View Awn Request"),
            activeIcon: Text("View Add Request"),
            label: '',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _selectedIndex = 0;
}

class Post {
  String name,
      category,
      img,
      website,
      phoneNum,
      description,
      latitude,
      longitude;

  Post(this.name, this.category, this.img, this.website, this.phoneNum,
      this.description, this.latitude, this.longitude);
}
