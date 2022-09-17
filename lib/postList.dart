import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import 'firebase_options.dart';
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
                          if (!snapshot.hasData) {
                            return Text('No available posts');
                          } else {
                            final data = snapshot.requireData;
                            print('line 55');
                            return ListView.builder(
                              itemCount: data.size,
                              itemBuilder: (context, index) {
                                bool phone =
                                    data.docs[index]['Phone number'] == ''
                                        ? false
                                        : true;
                                bool website = data.docs[index]['Website'] == ''
                                    ? false
                                    : true;
                                bool description =
                                    data.docs[index]['description'] == ''
                                        ? false
                                        : true;
                                bool loc = data.docs[index]['latitude'] == ''
                                    ? false
                                    : true;
                                bool img = data.docs[index]['img'] == ''
                                    ? false
                                    : true;
                                // Icon icon = data.docs[index]['img'] == '' ? Icon(Icons.navigate_before,
                                //     color: Colors.white);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36.0, vertical: 16),
                                  child: Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 600,
                                          margin: EdgeInsets.only(top: 12),
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 32,
                                                    color: Colors.black45,
                                                    spreadRadius: -8)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                child: Text(
                                                    '${data.docs[index]['name']}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    1, 0, 4, 4),
                                                child: Text(
                                                    '${data.docs[index]['category']}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Image.network(
                                                  data.docs[index]['img'],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return const Text(
                                                        'Image couldnt load');
                                                  },
                                                ),
                                              ),
                                              Visibility(
                                                visible: website ||
                                                    phone ||
                                                    description,
                                                child: ExpansionTile(
                                                  title: Text(
                                                    'View more',
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  children: [
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: phone,
                                                        child: Text(
                                                          '${data.docs[index]['Phone number']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: website,
                                                        child: Text(
                                                          '${data.docs[index]['Website']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    //description
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: website,
                                                        child: Text(
                                                          '${data.docs[index]['description']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: phone,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .blue,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            17,
                                                                            16,
                                                                            17,
                                                                            16),
                                                                    textStyle:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        width:
                                                                            1)),
                                                            child: Text(
                                                                'Add Image'),
                                                            onPressed: () {
                                                              double latitude =
                                                                  double.parse(data
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'latitude']);
                                                              double longitude =
                                                                  double.parse(data
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'longitude']);
                                                              (Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => MapsPage(
                                                                        latitude:
                                                                            latitude,
                                                                        longitude:
                                                                            longitude),
                                                                  )));
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      )))
            ],
          )),
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

class MapsPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  @override
  const MapsPage({Key? key, required this.latitude, required this.longitude})
      : super(key: key);
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController myController;
  /*getMarkerData() async {
    FirebaseFirestore.instance.collection('requests').;
  }*/

  Widget build(BuildContext context) {
    Set<Marker> getMarker() {
      return <Marker>[
        Marker(
            markerId: MarkerId(''),
            position: LatLng(widget.latitude, widget.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: 'Special need location'))
      ].toSet();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Awn Request Location'),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GoogleMap(
          markers: getMarker(),
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            myController = controller;
          },
        ));
  }
}
