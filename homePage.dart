import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';

import 'package:awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'login.dart';
import 'myGlobal.dart' as globals;

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  MyHomePage createState() => MyHomePage();
}

final user = FirebaseAuth.instance.currentUser!;
String userId = user.uid;
//final String userType = session.getUserType();

class MyHomePage extends State<homePage> {
  final Stream<QuerySnapshot> posts = FirebaseFirestore.instance
      .collection('posts')
      .orderBy("category")
      .snapshots();
  List userProfileList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _onItemTapped(int index) async {
      // if (userType == 'Volunteer') {
      //   if (index == 0) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const addPost()),
      //     );
      //   } /*else if (index == 1) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => addRequest()),
      //     );
      //   }*/
      //   else if (index == 1) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const viewRequests()),
      //     );
      //   } else if (index == 2) {
      //     FirebaseAuth.instance.signOut();
      //   }
      // } else {
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const addPost()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const addRequest()),
        );
      } /* else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => viewRequests()),
          );
        } */
      else if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const login()));

        FirebaseAuth.instance.signOut();
      }
    }

    final users;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: SizedBox(
          child: Text('homePage',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
      body: Container(
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
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('line 51');
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData) {
                            return const Text('No available posts');
                          } else {
                            final data = snapshot.requireData;
                            print('line 55');
                            // print(document["Type"]);
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
                                          margin:
                                              const EdgeInsets.only(top: 12),
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: const [
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                                child: Text(
                                                    '${data.docs[index]['name']}',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        fontSize: 18)),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        1, 0, 4, 4),
                                                child: Text(
                                                    '${data.docs[index]['category']}',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
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
                                                  title: const Text(
                                                    'View more',
                                                    style: TextStyle(
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
                                                            const EdgeInsets
                                                                .all(10),
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
                                                            child: const Text(
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

      //if(_selectedIndex ==0){

      bottomNavigationBar:
          Container(child: LayoutBuilder(builder: (context, constraints) {
        // getUsersList();
        // if (userType == 'Volunteer') {
        //   return BottomNavigationBar(
        //     items: <BottomNavigationBarItem>[
        //       BottomNavigationBarItem(
        //         //index 0
        //         icon: Icon(Icons.add, color: Colors.grey.shade700),
        //         activeIcon: Icon(Icons.add, color: Colors.grey.shade700),
        //         label: 'Add Post',
        //       ),
        //       /*BottomNavigationBarItem(
        //         //index 1
        //         icon: Icon(Icons.handshake, color: Colors.grey.shade700),
        //         activeIcon: Icon(Icons.handshake, color: Colors.grey.shade700),
        //         label: 'Request Awn',
        //       ),*/
        //       BottomNavigationBarItem(
        //         //index 2
        //         icon: Icon(Icons.handshake, color: Colors.grey.shade700),
        //         activeIcon: Icon(Icons.handshake, color: Colors.grey.shade700),
        //         label: 'View Requests',
        //       ),
        //       BottomNavigationBarItem(
        //         //index 3
        //         icon: Icon(Icons.logout, color: Colors.grey.shade700),
        //         activeIcon: Icon(Icons.logout, color: Colors.grey.shade700),
        //         label: 'Logout',
        //       )
        //     ],
        //     currentIndex: _selectedIndex,
        //     onTap: _onItemTapped,
        //   );
        // } else {
        return BottomNavigationBar(
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
          onTap: _onItemTapped,
        );
      })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _selectedIndex = 0;

  static final userCollection = FirebaseFirestore.instance.collection('users');

  /*static getUsersList() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      DocumentSnapshot ds;
      do {
        ds = await userCollection.doc(firebaseUser!.uid).get();
      } while (userId != ds.reference.id);
      userType = ds.get('Type');
      return userType;
    } catch (e) {
      print(e.toString());
      return "null";
    }
  }*/

  static getUsersList0() {
    final users = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get()
        .then((value) => value)
        .then((value) => value.data());

    return FutureBuilder(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final convertUserDataToMap = Map<String, dynamic>.from(
                snapshot.data as Map<dynamic, dynamic>);
            final List userDataList = convertUserDataToMap.values.toList();
            final userId = userDataList[0];
            final userLong = userDataList[1];
          }
          return Text("");
        });
  }

  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }
}
