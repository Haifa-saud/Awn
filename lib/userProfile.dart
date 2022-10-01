import 'package:awn/addPost.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/userInfo.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';
import 'MyRequestsSNU.dart';
import 'MyRequestsVol.dart';

class userProfile extends StatefulWidget {
  final String userType;
  const userProfile({Key? key, required this.userType}) : super(key: key);
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<userProfile>
    with TickerProviderStateMixin {
  final Storage storage = Storage();

  var userData;
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

  int _selectedIndex = 3;
  var userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);
//! Logout
    Future<void> _signOut() async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Workmanager().cancelAll();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const login()));
        Future.delayed(const Duration(seconds: 1),
            () async => await FirebaseAuth.instance.signOut());
      });
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
          future: readUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              var isVolunteer = userData[Type] == "Volunteer " ? true : false;
              return Scaffold(
                  appBar: AppBar(
                    actions: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded),
                            iconSize: 25,
                            color: const Color(
                                0xFF39d6ce), //Color.fromARGB(255, 149, 204, 250),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                    "Logout",
                                    textAlign: TextAlign.center,
                                  ),
                                  content: const Text(
                                    "Are You Sure You want to log out of your account ?",
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    //log in cancle button
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        child: const Text("Cancel"),
                                      ),
                                    ),
                                    //log in ok button
                                    TextButton(
                                      onPressed: () async {
                                        await _signOut();
                                      },
                                      child: Container(
                                        //color: Color.fromARGB(255, 164, 20, 20),
                                        padding: const EdgeInsets.all(14),
                                        child: const Text("Log out",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 164, 10, 10))),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                    ],
                    centerTitle: false,
                    backgroundColor: Colors.white, //(0xFFfcfffe),
                    foregroundColor: Colors.black,
                    automaticallyImplyLeading: false,
                    scrolledUnderElevation: 1,
                    toolbarHeight: 93,
                    title: Row(children: [
                      Container(
                        height: 55,
                        width: 55,
                        margin: const EdgeInsets.fromLTRB(8, 10, 10, 0),
                        child: const CircleAvatar(
                          backgroundColor: Color.fromARGB(
                              255, 149, 204, 250), //Color(0xffE6E6E6),
                          radius: 30,
                          child: Icon(Icons.person,
                              size: 40, color: Colors.white //Color(0xffCCCCCC),
                              ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData['name']),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      userData['Type'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color.fromARGB(136, 6, 40, 61),
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ])),
                    ]),
                  ),
                  body: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: Column(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelPadding: const EdgeInsets.only(
                                    left: 0.0, right: 0.0),
                                indicator: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 1.0],
                                    colors: [
                                      Colors.blue,
                                      Color(0xFF39d6ce),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                indicatorWeight: 5,
                                indicatorPadding:
                                    const EdgeInsets.only(top: 47),
                                tabs: <Tab>[
                                  new Tab(text: 'My Info'),
                                  new Tab(text: 'My Requests'),
                                ],
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                labelStyle: const TextStyle(fontSize: 17),
                              )
                            ]),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height,
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                  myInfo(userData),
                                  isVolunteer
                                      ? MyRequestsVol()
                                      : MyRequestsSNU(),
                                ]),
                          ),
                        )
                      ])));
            } else {
              return const Text('');
            }
          }),
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => addPost(userType: widget.userType)));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavBar(
        onPress: (int value) => setState(() {
          _selectedIndex = value;
        }),
        userType: widget.userType,
        currentI: widget.userType == 'Volunteer' ? 2 : 3,
      ),
    );
  } // end of class

//! My info
  Widget myInfo(var userData) {
    var userName = userData['name'];
    bool isVolunteer = false;
    bool isSpecial = false;
    String dis = '';
    if (userData['Type'] == "Volunteer") {
      isVolunteer = true;
    } else {
      isSpecial = true;
      dis = userData['Disability'];
      dis = dis.substring(0, (dis.length - 1));
    }
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        buildTextField('Name', userData['name']),
        buildTextField('Date of Birth', userData['DOB']),
        buildTextField('Gender', userData['gender']),
        buildTextField('Email', userData['Email']),
        buildTextField('Phone Number', userData['phone number']),
        Visibility(
          visible: isVolunteer,
          child: buildTextField('Bio', userData['bio']),
        ),
        Visibility(
            visible: isSpecial, child: buildTextField('Disability', dis)),
      ],
    )));
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
      child: TextField(
        enabled: false,
        maxLength: 180,
        minLines: 1,
        maxLines: 6,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06283D)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}
//! My requests Vol
//   bool showPrev = false;
//   bool showUpcoming = false;

//   Widget MyRequestsV() {
//     TabController _tabController = TabController(length: 2, vsync: this);
//     return Container(
//         padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//         child: Column(
//           children: [
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               ButtonsTabBar(
//                   controller: _tabController,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       stops: [0.0, 1.0],
//                       colors: [
//                         Colors.blue,
//                         Color(0xFF39d6ce),
//                       ],
//                     ),
//                   ),
//                   radius: 5,
//                   borderColor: Colors.white,
//                   buttonMargin: const EdgeInsets.fromLTRB(6, 8, 6, 1),
//                   contentPadding: const EdgeInsets.fromLTRB(60, 8, 60, 8),
//                   unselectedBackgroundColor: Colors.white,
//                   unselectedLabelStyle:
//                       const TextStyle(color: Colors.grey, fontSize: 16),
//                   labelStyle:
//                       const TextStyle(color: Colors.white, fontSize: 16),
//                   tabs: const [
//                     Tab(text: "Previous"),
//                     Tab(text: "Upcoming"),
//                   ]),
//             ]),
//             Expanded(
//               child: Container(
//                 width: double.maxFinite,
//                 height: MediaQuery.of(context).size.height,
//                 child: TabBarView(controller: _tabController, children: [
//                   showUpcomingList(getPrevRequests(context, 'VolID'), 'VolID'),
//                   showUpcomingList(
//                       getUpcomingRequests(context, 'VolID'), 'VolID')
//                 ]),
//               ),
//             )
//           ],
//         ));
//   }

//   Widget MyRequestsSN() {
//     TabController _tabController = TabController(length: 2, vsync: this);
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ButtonsTabBar(
//                     controller: _tabController,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         stops: [0.0, 1.0],
//                         colors: [
//                           Colors.blue,
//                           Color(0xFF39d6ce),
//                         ],
//                       ),
//                     ),
//                     radius: 5,
//                     borderColor: Colors.white,
//                     buttonMargin: const EdgeInsets.fromLTRB(6, 8, 6, 1),
//                     contentPadding: const EdgeInsets.fromLTRB(60, 8, 60, 8),
//                     unselectedBackgroundColor: Colors.white,
//                     labelStyle:
//                         const TextStyle(color: Colors.white, fontSize: 15),
//                     tabs: const [
//                       Tab(text: "Previous"),
//                       Tab(text: "Upcoming"),
//                     ]),
//               ]),
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: []),
//           Container(
//             width: double.maxFinite,
//             height: MediaQuery.of(context).size.height,
//             child: TabBarView(controller: _tabController, children: [
//               showPrevList(getPrevRequests(context, 'userID'), 'userID'),
//               showUpcomingList(getUpcomingRequests(context, 'userID'), 'userID')
//             ]),
//           ),
//         ],
//       ),
//     );
//   }

//   Stream<QuerySnapshot> getPrevRequests(
//       BuildContext context, String userType) async* {
//     final user = FirebaseAuth.instance.currentUser!;
//     String userId = user.uid;
//     final now = DateTime.now();
//     final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
//     yield* FirebaseFirestore.instance
//         .collection('requests')
//         .where(userType, isEqualTo: userId)
//         .where('date_ymd', isLessThanOrEqualTo: today)
//         .orderBy('date_ymd')
//         .snapshots();
//   }

//   Stream<QuerySnapshot> getUpcomingRequests(
//       BuildContext context, String userType) async* {
//     final user = FirebaseAuth.instance.currentUser!;
//     String userId = user.uid;
//     final now = DateTime.now();
//     final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
//     yield* FirebaseFirestore.instance
//         .collection('requests')
//         .where(userType, isEqualTo: userId)
//         .where('date_ymd', isGreaterThan: today)
//         .orderBy('date_ymd')
//         .snapshots();
//   }

//   Widget showUpcomingList(Stream<QuerySnapshot> list, String userType) {
//     Future<String> getLocationAsString(var lat, var lng) async {
//       List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
//       return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
//     }

//     final user = FirebaseAuth.instance.currentUser!;
//     String userId = user.uid;
//     final now = DateTime.now();

//     final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
//     final Stream<QuerySnapshot> ulist = FirebaseFirestore.instance
//         .collection('requests')
//         .where(userType, isEqualTo: userId)
//         .where('date_ymd', isGreaterThan: today)
//         .orderBy('date_ymd')
//         .snapshots();

//     return Container(
//         height: double.infinity,
//         child: Column(children: [
//           Expanded(
//               child: Container(
//                   height: double.infinity,
//                   child: StreamBuilder<QuerySnapshot>(
//                       stream: ulist,
//                       builder: (
//                         BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot,
//                       ) {
//                         if (snapshot.hasError) {
//                           return const Text('Something went wrong');
//                         }
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         if (snapshot.data == null ||
//                             snapshot.data!.docs.isEmpty) {
//                           return const Padding(
//                               padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
//                               child: Align(
//                                   alignment: Alignment.topCenter,
//                                   child: Text(
//                                       'There is no upcoming requests currently.',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.normal,
//                                           fontSize: 17))));
//                         } else {
//                           final data = snapshot.requireData;
//                           return ListView.builder(
//                               itemCount: data.size,
//                               itemBuilder: (context, index) {
//                                 var reqLoc;
//                                 double latitude = double.parse(
//                                     '${data.docs[index]['latitude']}');
//                                 double longitude = double.parse(
//                                     '${data.docs[index]['longitude']}');
//                                 return FutureBuilder(
//                                     future: getLocationAsString(
//                                         latitude, longitude),
//                                     builder: (context, snap) {
//                                       if (snap.hasData) {
//                                         var reqLoc = snap.data;
//                                         return Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 36.0, vertical: 16),
//                                             child: Stack(children: [
//                                               Container(
//                                                   width: 600,
//                                                   margin: const EdgeInsets.only(
//                                                       top: 12),
//                                                   padding:
//                                                       const EdgeInsets.all(2),
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       boxShadow: const [
//                                                         BoxShadow(
//                                                             blurRadius: 32,
//                                                             color:
//                                                                 Colors.black45,
//                                                             spreadRadius: -8)
//                                                       ],
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15)),
//                                                   child: Column(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceEvenly,
//                                                       children: [
//                                                         Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .fromLTRB(
//                                                                     10,
//                                                                     10,
//                                                                     15,
//                                                                     15),
//                                                             child: Stack(
//                                                                 children: [
//                                                                   Text(
//                                                                     ' ${data.docs[index]['title']}',
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .left,
//                                                                   ),
//                                                                   Container(
//                                                                     alignment:
//                                                                         Alignment
//                                                                             .topRight,
//                                                                     margin: const EdgeInsets
//                                                                             .only(
//                                                                         top: 5),
//                                                                     child: Text(
//                                                                         '${data.docs[index]['status']}',
//                                                                         style: TextStyle(
//                                                                             color: Colors.white,
//                                                                             background: Paint()
//                                                                               ..strokeWidth = 20.0
//                                                                               ..color = getColor(data.docs[index]['status'])
//                                                                               ..style = PaintingStyle.stroke
//                                                                               ..strokeJoin = StrokeJoin.round,
//                                                                             fontSize: 17,
//                                                                             fontWeight: FontWeight.w500)),
//                                                                   ),
//                                                                   // date and time
//                                                                   Padding(
//                                                                     padding:
//                                                                         const EdgeInsets.fromLTRB(
//                                                                             20,
//                                                                             0,
//                                                                             0,
//                                                                             12),
//                                                                     child: Row(
//                                                                       children: [
//                                                                         const Icon(
//                                                                             Icons
//                                                                                 .calendar_today,
//                                                                             size:
//                                                                                 20,
//                                                                             color:
//                                                                                 Colors.red),
//                                                                         Text(
//                                                                             ' ${data.docs[index]['date_dmy']}',
//                                                                             style:
//                                                                                 const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               const EdgeInsets.only(left: 60),
//                                                                           child:
//                                                                               Row(
//                                                                             children: [
//                                                                               const Icon(Icons.schedule, size: 20, color: Colors.red),
//                                                                               Text(' ${data.docs[index]['time']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                         //duration
//                                                                         Padding(
//                                                                           padding: const EdgeInsets.fromLTRB(
//                                                                               20,
//                                                                               0,
//                                                                               0,
//                                                                               12),
//                                                                           child:
//                                                                               Row(
//                                                                             children: [
//                                                                               // Icon(Icons.schedule,
//                                                                               //     size: 20, color: Colors.red),
//                                                                               Text('Duration: ${data.docs[index]['duration']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                         //description
//                                                                         Padding(
//                                                                           padding: const EdgeInsets.fromLTRB(
//                                                                               20,
//                                                                               0,
//                                                                               0,
//                                                                               5),
//                                                                           child:
//                                                                               Row(
//                                                                             children: [
//                                                                               Flexible(
//                                                                                 child: Text('Description: ${data.docs[index]['description']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                         //location
//                                                                         Padding(
//                                                                             padding: const EdgeInsets.fromLTRB(
//                                                                                 0,
//                                                                                 0,
//                                                                                 0,
//                                                                                 20),
//                                                                             child: ElevatedButton(
//                                                                                 onPressed: () {
//                                                                                   double latitude = double.parse(data.docs[index]['latitude']);
//                                                                                   double longitude = double.parse(data.docs[index]['longitude']);
//                                                                                   (Navigator.push(
//                                                                                       context,
//                                                                                       MaterialPageRoute(
//                                                                                         builder: (context) => MapsPage(latitude: latitude, longitude: longitude),
//                                                                                       )));
//                                                                                 },
//                                                                                 style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2)),
//                                                                                 child: Row(children: [
//                                                                                   const Icon(Icons.location_pin, size: 20, color: Colors.red),
//                                                                                   Flexible(
//                                                                                       child: Text(reqLoc!,
//                                                                                           style: TextStyle(
//                                                                                             color: Colors.grey.shade500,
//                                                                                             fontSize: 17,
//                                                                                           )))
//                                                                                 ])))
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 ])),
//                                                       ]))
//                                             ]));
//                                         //                           return Container(
//                                         //                               margin:
//                                         //                                   const EdgeInsets.fromLTRB(8, 12, 8, 0),
//                                         //                               decoration: BoxDecoration(
//                                         //                                   //color: Colors.white,
//                                         //                                   boxShadow: const [
//                                         //                                     BoxShadow(
//                                         //                                         blurRadius: 39,
//                                         //                                         color: Colors.black45,
//                                         //                                         spreadRadius: -8)
//                                         //                                   ],
//                                         //                                   borderRadius: BorderRadius.circular(15)),
//                                         //                               child: Card(
//                                         //                                   child: Container(
//                                         //                                       // width: 200,
//                                         //                                       // height: 400,
//                                         //                                       child: Row(children: [
//                                         //                                 RotatedBox(
//                                         //                                     quarterTurns: 3,
//                                         //                                     child: Container(
//                                         //                                       // height: double.infinity,
//                                         //                                       child: Text(
//                                         //                                           getStatus(
//                                         //                                               data.docs[index]['status'],
//                                         //                                               data.docs[index]['docId']),
//                                         //                                           style: TextStyle(
//                                         //                                               color: Colors.green.shade300,
//                                         //                                               fontSize: 17,
//                                         //                                               fontWeight: FontWeight.w500,
//                                         //                                               letterSpacing: 5)),
//                                         //                                     )),
//                                         //                                 Expanded(
//                                         //                                     flex: 2,
//                                         //                                     child: Column(
//                                         //                                       children: [
//                                         //                                         //title
//                                         //                                         Padding(
//                                         //                                             padding:
//                                         //                                                 const EdgeInsets.fromLTRB(
//                                         //                                                     10, 10, 15, 15),
//                                         //                                             child: Stack(children: [
//                                         //                                               Text(
//                                         //                                                 ' ${data.docs[index]['title']}',
//                                         //                                                 textAlign: TextAlign.left,
//                                         //                                               ),
//                                         //                                               Container(
//                                         //                                                 alignment:
//                                         //                                                     Alignment.topRight,
//                                         //                                                 margin:
//                                         //                                                     const EdgeInsets.only(
//                                         //                                                         top: 5),
//                                         //                                                 // padding: EdgeInsets.only(right: 0),
//                                         //                                                 child: Text(
//                                         //                                                     '${data.docs[index]['status']}',
//                                         //                                                     //   overflow:
//                                         //                                                     //   TextOverflow.ellipsis,
//                                         //                                                     style: TextStyle(
//                                         //                                                         color: Colors.white,
//                                         //                                                         background: Paint()
//                                         //                                                           ..strokeWidth =
//                                         //                                                               20.0
//                                         //                                                           ..color = getColor(
//                                         //                                                               data.docs[
//                                         //                                                                       index]
//                                         //                                                                   [
//                                         //                                                                   'status'])
//                                         //                                                           ..style =
//                                         //                                                               PaintingStyle
//                                         //                                                                   .stroke
//                                         //                                                           ..strokeJoin =
//                                         //                                                               StrokeJoin
//                                         //                                                                   .round,
//                                         //                                                         fontSize: 17,
//                                         //                                                         fontWeight:
//                                         //                                                             FontWeight
//                                         //                                                                 .w500)),
//                                         //                                               )
//                                         //                                             ])),
//                                         //                                         //date and time
//                                         //                                         Padding(
//                                         //                                           padding:
//                                         //                                               const EdgeInsets.fromLTRB(
//                                         //                                                   20, 0, 0, 12),
//                                         //                                           child: Row(
//                                         //                                             children: [
//                                         //                                               const Icon(
//                                         //                                                   Icons.calendar_today,
//                                         //                                                   size: 20,
//                                         //                                                   color: Colors.red),
//                                         //                                               Text(
//                                         //                                                   ' ${data.docs[index]['date_dmy']}',
//                                         //                                                   style: const TextStyle(
//                                         //                                                       fontSize: 17,
//                                         //                                                       fontWeight:
//                                         //                                                           FontWeight.w500)),
//                                         //                                               Padding(
//                                         //                                                 padding:
//                                         //                                                     const EdgeInsets.only(
//                                         //                                                         left: 60),
//                                         //                                                 child: Row(
//                                         //                                                   children: [
//                                         //                                                     const Icon(
//                                         //                                                         Icons.schedule,
//                                         //                                                         size: 20,
//                                         //                                                         color: Colors.red),
//                                         //                                                     Text(
//                                         //                                                         ' ${data.docs[index]['time']}',
//                                         //                                                         style: const TextStyle(
//                                         //                                                             fontSize: 17,
//                                         //                                                             fontWeight:
//                                         //                                                                 FontWeight
//                                         //                                                                     .w500)),
//                                         //                                                   ],
//                                         //                                                 ),
//                                         //                                               ),
//                                         //                                             ],
//                                         //                                           ),
//                                         //                                         ),
//                                         //                                         //duration
//                                         //                                         Padding(
//                                         //                                           padding:
//                                         //                                               const EdgeInsets.fromLTRB(
//                                         //                                                   20, 0, 0, 12),
//                                         //                                           child: Row(
//                                         //                                             children: [
//                                         //                                               // Icon(Icons.schedule,
//                                         //                                               //     size: 20, color: Colors.red),
//                                         //                                               Text(
//                                         //                                                   'Duration: ${data.docs[index]['duration']}',
//                                         //                                                   style: const TextStyle(
//                                         //                                                       fontSize: 17,
//                                         //                                                       fontWeight:
//                                         //                                                           FontWeight.w500)),
//                                         //                                             ],
//                                         //                                           ),
//                                         //                                         ),
//                                         //                                         //description
//                                         //                                         Padding(
//                                         //                                           padding:
//                                         //                                               const EdgeInsets.fromLTRB(
//                                         //                                                   20, 0, 0, 5),
//                                         //                                           child: Row(
//                                         //                                             children: [
//                                         //                                               Flexible(
//                                         //                                                 child: Text(
//                                         //                                                     'Description: ${data.docs[index]['description']}',
//                                         //                                                     style: const TextStyle(
//                                         //                                                         fontSize: 17,
//                                         //                                                         fontWeight:
//                                         //                                                             FontWeight
//                                         //                                                                 .w500)),
//                                         //                                               ),
//                                         //                                             ],
//                                         //                                           ),
//                                         //                                         ),
//                                         //                                         //location
//                                         //                                         Padding(
//                                         //                                             padding:
//                                         //                                                 const EdgeInsets
//                                         //                                                     .fromLTRB(0, 0, 0, 20),
//                                         //                                             child: ElevatedButton(
//                                         //                                                 onPressed: () {
//                                         //                                                   double latitude =
//                                         //                                                       double.parse(
//                                         //                                                           data.docs[index]
//                                         //                                                               ['latitude']);
//                                         //                                                   double longitude =
//                                         //                                                       double.parse(data
//                                         //                                                               .docs[index]
//                                         //                                                           ['longitude']);

//                                         //                                                   (Navigator.push(
//                                         //                                                       context,
//                                         //                                                       MaterialPageRoute(
//                                         //                                                         builder: (context) =>
//                                         //                                                             MapsPage(
//                                         //                                                                 latitude:
//                                         //                                                                     latitude,
//                                         //                                                                 longitude:
//                                         //                                                                     longitude),
//                                         //                                                       )));
//                                         //                                                 },
//                                         //                                                 style: ElevatedButton
//                                         //                                                     .styleFrom(
//                                         //                                                         foregroundColor:
//                                         //                                                             Colors.white,
//                                         //                                                         backgroundColor:
//                                         //                                                             Colors.white,
//                                         //                                                         side:
//                                         //                                                             const BorderSide(
//                                         //                                                                 color: Colors
//                                         //                                                                     .white,
//                                         //                                                                 width: 2)),
//                                         //                                                 child: Row(
//                                         //                                                   children: [
//                                         //                                                     const Icon(
//                                         //                                                         Icons.location_pin,
//                                         //                                                         size: 20,
//                                         //                                                         color: Colors.red),
//                                         //                                                     Flexible(
//                                         //                                                         child: Text(reqLoc!,
//                                         //                                                             style:
//                                         //                                                                 TextStyle(
//                                         //                                                               color: Colors
//                                         //                                                                   .grey
//                                         //                                                                   .shade500,
//                                         //                                                               fontSize: 17,
//                                         //                                                             )))
//                                         //                                                   ],
//                                         //                                                 ))),
//                                         //                                       ],
//                                         //                                     ))
//                                         //                               ]))));
//                                         //                         } else {
//                                         //                           return const Center(
//                                         //                               child: CircularProgressIndicator());
//                                         //                         }
//                                         //                       });
//                                         //                 },
//                                         //               );
//                                         //             },
//                                         //           )))
//                                         // ]);
//                                       } else {
//                                         return const Center(child: Text(''));
//                                       }
//                                     });
//                               });
//                         }
//                       })))
//         ]));
//   }

//   Widget showPrevList(Stream<QuerySnapshot> list, String userType) {
//     Future<String> getLocationAsString(var lat, var lng) async {
//       List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
//       return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
//     }

//     final user = FirebaseAuth.instance.currentUser!;
//     String userId = user.uid;
//     final now = DateTime.now();

//     final today = DateFormat('yyyy-MM-dd HH: ss').format(now);
//     final Stream<QuerySnapshot> Plist = FirebaseFirestore.instance
//         .collection('requests')
//         .where('VolID', isEqualTo: userId)
//         .where('date_ymd', isLessThanOrEqualTo: today)
//         .orderBy('date_ymd')
//         .snapshots();
//     ScrollController _controller = new ScrollController();

//     return Column(children: [
//       Expanded(
//           flex: 2,
//           child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: Plist,
//                 builder: (
//                   BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot,
//                 ) {
//                   if (snapshot.hasError) {
//                     return const Text('Something went wrong');
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
//                     return const Padding(
//                         padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
//                         child: Align(
//                             alignment: Alignment.topCenter,
//                             child: Text(
//                                 'There is no previous requests currently.',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.normal,
//                                     fontSize: 17))));
//                   }
//                   final data = snapshot.requireData;
//                   return ListView.builder(
//                     controller: _controller,
//                     itemCount: data.size,
//                     itemBuilder: (context, index) {
//                       var reqLoc;
//                       double latitude =
//                           double.parse('${data.docs[index]['latitude']}');
//                       double longitude =
//                           double.parse('${data.docs[index]['longitude']}');
//                       return FutureBuilder(
//                           future: getLocationAsString(latitude, longitude),
//                           builder: (context, snap) {
//                             if (snap.hasData) {
//                               var reqLoc = snap.data;
//                               return Container(
//                                   margin:
//                                       const EdgeInsets.fromLTRB(5, 12, 5, 0),
//                                   decoration: BoxDecoration(
//                                       //color: Colors.white,
//                                       boxShadow: const [
//                                         BoxShadow(
//                                             blurRadius: 32,
//                                             color: Colors.black45,
//                                             spreadRadius: -8)
//                                       ],
//                                       borderRadius: BorderRadius.circular(15)),
//                                   child: Card(
//                                       child: Column(
//                                     children: [
//                                       //title
//                                       Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               10, 10, 15, 15),
//                                           child: Stack(children: [
//                                             Text(
//                                               ' ${data.docs[index]['title']}',
//                                               textAlign: TextAlign.left,
//                                             ),
//                                             Container(
//                                               alignment: Alignment.topRight,
//                                               margin:
//                                                   const EdgeInsets.only(top: 5),
//                                               child: Text(
//                                                   getStatus(
//                                                       data.docs[index]
//                                                           ['status'],
//                                                       data.docs[index]
//                                                           ['docId']),
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       background: Paint()
//                                                         ..strokeWidth = 20.0
//                                                         ..color = getColor(
//                                                             data.docs[index]
//                                                                 ['status'])
//                                                         ..style =
//                                                             PaintingStyle.stroke
//                                                         ..strokeJoin =
//                                                             StrokeJoin.round,
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w500)),
//                                             )
//                                           ])),
//                                       //date and time
//                                       Padding(
//                                         padding: const EdgeInsets.fromLTRB(
//                                             20, 15, 0, 12),
//                                         child: Row(
//                                           children: [
//                                             const Icon(Icons.calendar_today,
//                                                 size: 20, color: Colors.red),
//                                             Text(
//                                                 ' ${data.docs[index]['date_dmy']}',
//                                                 style: const TextStyle(
//                                                     fontSize: 17,
//                                                     fontWeight:
//                                                         FontWeight.w500)),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 60),
//                                               child: Row(
//                                                 children: [
//                                                   const Icon(Icons.schedule,
//                                                       size: 20,
//                                                       color: Colors.red),
//                                                   Text(
//                                                       ' ${data.docs[index]['time']}',
//                                                       style: const TextStyle(
//                                                           fontSize: 17,
//                                                           fontWeight:
//                                                               FontWeight.w500)),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       //duration
//                                       Padding(
//                                         padding: const EdgeInsets.fromLTRB(
//                                             20, 0, 0, 12),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                                 'Duration: ${data.docs[index]['duration']}',
//                                                 style: const TextStyle(
//                                                     fontSize: 17,
//                                                     fontWeight:
//                                                         FontWeight.w500)),
//                                           ],
//                                         ),
//                                       ),
//                                       //description
//                                       Padding(
//                                         padding: const EdgeInsets.fromLTRB(
//                                             20, 0, 18, 5),
//                                         child: Row(
//                                           children: [
//                                             Flexible(
//                                               child: Text(
//                                                   'Description: ${data.docs[index]['description']}',
//                                                   style: const TextStyle(
//                                                       fontSize: 17,
//                                                       fontWeight:
//                                                           FontWeight.w500)),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       //location
//                                       Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               0, 0, 0, 20),
//                                           child: ElevatedButton(
//                                               onPressed: () {
//                                                 double latitude = double.parse(
//                                                     data.docs[index]
//                                                         ['latitude']);
//                                                 double longitude = double.parse(
//                                                     data.docs[index]
//                                                         ['longitude']);

//                                                 (Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           MapsPage(
//                                                               latitude:
//                                                                   latitude,
//                                                               longitude:
//                                                                   longitude),
//                                                     )));
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                   foregroundColor: Colors.white,
//                                                   backgroundColor: Colors.white,
//                                                   side: const BorderSide(
//                                                       color: Colors.white,
//                                                       width: 2)),
//                                               child: Row(
//                                                 children: [
//                                                   const Icon(Icons.location_pin,
//                                                       size: 20,
//                                                       color: Colors.red),
//                                                   Flexible(
//                                                       child: Text(reqLoc!,
//                                                           style: TextStyle(
//                                                             color: Colors
//                                                                 .grey.shade500,
//                                                             fontSize: 17,
//                                                           )))
//                                                 ],
//                                               ))),
//                                     ],
//                                   )));
//                             } else {
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             }
//                           });
//                     },
//                   );
//                 },
//               )))
//     ]);
//   }

//   String getTime() {
//     final now = DateTime.now();
//     return DateFormat('yyyy-MM-dd HH: ss').format(now);
//   }

//   Color getColor(String stat) {
//     if (stat == 'Approved')
//       return Colors.green.shade300;
//     else if (stat == 'Pending')
//       return Colors.orange.shade300;
//     else if (stat == 'Expired')
//       return Colors.red.shade300;
//     else
//       return Colors.white;
//   }

//   String getStatus(String stat, String docId) {
//     if (stat == 'Pending') {
//       final user = FirebaseAuth.instance.currentUser!;
//       String userId = user.uid;

//       final postID =
//           FirebaseFirestore.instance.collection('requests').doc(docId);

//       postID.update({
//         'status': 'Expired',
//       });
//       return 'Expired';
//     } else
//       return stat;
//   }
// }
