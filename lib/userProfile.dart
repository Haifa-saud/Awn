import 'package:awn/addPost.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_options.dart';

class userProfile extends StatefulWidget {
  const userProfile({Key? key, required this.userType}) : super(key: key);

  final String userType;

  @override
  UserProfileState createState() => UserProfileState();
}

ScrollController _scrollController = ScrollController();

class UserProfileState extends State<userProfile>
    with TickerProviderStateMixin {
  late final NotificationService notificationService;
  final Storage storage = Storage();
  var userData;
  var userId = FirebaseAuth.instance.currentUser!.uid;

  int _selectedIndex = 3;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);
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
              print(userData['Type']);
              var isVolunteer = userData['Type'] == "Volunteer" ? true : false;
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
                                    textAlign: TextAlign.left,
                                  ),
                                  content: const Text(
                                    "Are You Sure You want to log out of your account ?",
                                    textAlign: TextAlign.left,
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
                                tabs: const <Tab>[
                                  Tab(text: 'My Info'),
                                  Tab(text: 'My Requests'),
                                  Tab(text: 'My Places'),
                                ],
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                labelStyle: const TextStyle(fontSize: 17),
                              )
                            ]),
                        Expanded(
                          // controller: _scrollController,

                          flex: 2,
                          child: Container(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height,
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                  myInfo(userData),
                                  MyRequests(isVolunteer),
                                  MyPlaces(userData['id']),
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

//! My requests
  Widget MyRequests(var isVolunteer) {
    TabController _tabController = TabController(length: 2, vsync: this);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ButtonsTabBar(
                  controller: _tabController,
                  decoration: const BoxDecoration(
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
                  radius: 5,
                  borderColor: Colors.white,
                  buttonMargin: const EdgeInsets.fromLTRB(6, 8, 6, 1),
                  contentPadding: const EdgeInsets.fromLTRB(60, 8, 60, 8),
                  unselectedBackgroundColor: Colors.white,
                  unselectedLabelStyle:
                      const TextStyle(color: Colors.grey, fontSize: 16),
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 16),
                  tabs: const [
                    Tab(text: "Previous"),
                    Tab(text: "Upcoming"),
                  ]),
            ]),
            Expanded(
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height,
                child: TabBarView(controller: _tabController, children: [
                  showList('Previous', isVolunteer),
                  showList('Upcoming', isVolunteer)
                ]),
              ),
            )
          ],
        ));
  }

  Widget showList(String str, var isVolunteer) {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    final user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    final now = DateTime.now();
    var list;
    print(isVolunteer);
    var userType = isVolunteer ? 'VolID' : 'userID';
    print(userType);

    final today = DateFormat('yyyy-MM-dd HH: mm').format(now);
    if (str == 'Upcoming') {
      list = FirebaseFirestore.instance
          .collection('requests')
          .where(userType, isEqualTo: userId)
          .where('date_ymd', isGreaterThan: today)
          .orderBy('date_ymd')
          .snapshots();
    } else if (str == 'Previous') {
      list = FirebaseFirestore.instance
          .collection('requests')
          .where(userType, isEqualTo: userId)
          .where('date_ymd', isLessThanOrEqualTo: today)
          .orderBy('date_ymd')
          .snapshots();
    }
    return Container(
        height: double.infinity,
        child: Column(children: [
          Expanded(
              child: Container(
                  height: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: list,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          print(snapshot.data);
                          return const Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text('There is no requests currently.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 17))));
                        } else {
                          final data = snapshot.requireData;
                          print('data');
                          return ListView.builder(
                              controller: _scrollController,
                              itemCount: data.size,
                              itemBuilder: (context, index) {
                                var reqLoc;
                                double latitude = double.parse(
                                    '${data.docs[index]['latitude']}');
                                double longitude = double.parse(
                                    '${data.docs[index]['longitude']}');

                                var status = str == 'Previous'
                                    ? getStatus(data.docs[index]['status'],
                                        data.docs[index]['docId'])
                                    : data.docs[index]['status'];
                                return FutureBuilder(
                                    future: getLocationAsString(
                                        latitude, longitude),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        var reqLoc = snap.data;
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 16),
                                            child: Stack(children: [
                                              Container(
                                                width: 600,
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          blurRadius: 32,
                                                          color: Colors.black45,
                                                          spreadRadius: -8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                8, 1, 1, 1),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            6,
                                                                            10,
                                                                            15,
                                                                            15),
                                                                child: Stack(
                                                                    children: [
                                                                      Align(
                                                                          alignment:
                                                                              Alignment.topLeft,
                                                                          child: Container(
                                                                              width: 235,
                                                                              child: Align(
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Text(
                                                                                    '${data.docs[index]['title']}',
                                                                                    style: const TextStyle(
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                    textAlign: TextAlign.left,
                                                                                  )))),
                                                                      Visibility(
                                                                        visible:
                                                                            !isVolunteer,
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          margin:
                                                                              const EdgeInsets.only(top: 5),
                                                                          child: Text(
                                                                              status,
                                                                              style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  background: Paint()
                                                                                    ..strokeWidth = 18.0
                                                                                    ..color = getColor(data.docs[index]['status'])
                                                                                    ..style = PaintingStyle.stroke
                                                                                    ..strokeJoin = StrokeJoin.round,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.w500)),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                            // date and time
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      6,
                                                                      20,
                                                                      0,
                                                                      10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            0),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .calendar_today,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.red.shade200),
                                                                        Text(
                                                                            ' ${data.docs[index]['date_dmy']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.w400,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            40),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .schedule,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.red.shade200),
                                                                        Text(
                                                                            ' ${data.docs[index]['time']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.w400,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ExpansionTile(
                                                                title:
                                                                    const Text(
                                                                  'View more',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.0,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                children: [
                                                                  //duration
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            6,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                            'Duration: ${data.docs[index]['duration']}',
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.w400, fontSize: 17)),
                                                                      ],
                                                                    ),
                                                                  ), //description
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            6,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child: Text(
                                                                              'Description: ${data.docs[index]['description']}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ), //location
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            6,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    child: Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.location_pin,
                                                                              size: 20,
                                                                              color: Colors.red.shade200),
                                                                          ElevatedButton(
                                                                              onPressed: () {
                                                                                (Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => MapsPage(latitude: latitude, longitude: longitude),
                                                                                    )));
                                                                              },
                                                                              style: ElevatedButton.styleFrom(
                                                                                foregroundColor: Colors.grey.shade500,
                                                                                backgroundColor: Colors.white,
                                                                                padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                                                                              ),
                                                                              child: Container(width: 285, child: Text(reqLoc!, style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey.shade500))))
                                                                        ]),
                                                                  ),
                                                                ]),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              )
                                            ]));
                                      } else {
                                        return const Center(child: Text(''));
                                      }
                                    });
                              });
                        }
                      })))
        ]));
  }

  Color getColor(String stat) {
    if (stat == 'Approved')
      return Colors.green.shade300;
    else if (stat == 'Pending')
      return Colors.orange.shade300;
    else if (stat == 'Expired')
      return Colors.red.shade300;
    else
      return Colors.white;
  }

  String getStatus(String stat, String docId) {
    if (stat == 'Pending') {
      final user = FirebaseAuth.instance.currentUser!;
      String userId = user.uid;

      final postID =
          FirebaseFirestore.instance.collection('requests').doc(docId);

      postID.update({
        'status': 'Expired',
      });
      return 'Expired';
    }
    return stat;
  }

//! My Places
  Widget MyPlaces(String userId) {
    CollectionReference category =
        FirebaseFirestore.instance.collection('postCategory');
    int tabLength = 6;

    TabController _tabController = TabController(length: 3, vsync: this);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: StreamBuilder<QuerySnapshot>(
          stream: category.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading");
            } else {
              return Column(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ButtonsTabBar(
                    controller: _tabController,
                    backgroundColor: Color(0xFFfcfffe),
                    radius: 5,
                    // borderColor: Colors.transparent,
                    buttonMargin: const EdgeInsets.fromLTRB(4, 8, 4, 1),
                    unselectedDecoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(5),
                      // border:
                      //     Border.all(width: 0, color: Colors.blue.shade50),
                      color: Colors.transparent,
                    ),
                    unselectedLabelStyle:
                        const TextStyle(color: Colors.grey, fontSize: 16),
                    labelStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    tabs: <Tab>[
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                        alignment: Alignment.center,
                        // color: Colors.red.shade300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border:
                              Border.all(width: 0, color: Colors.blue.shade50),
                          color: Colors.red.shade300,
                        ),
                        child: Text(
                          "Declined",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )),
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                        alignment: Alignment.center,
                        color: Colors.orange.shade300,
                        child: Text("Pending"),
                      )),
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                        alignment: Alignment.center,
                        color: Colors.green.shade300,
                        child: Text("Approved"),
                      )),
                    ],
                  ),
                ]),
                Expanded(
                    child: Container(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height,
                        child:
                            TabBarView(controller: _tabController, children: [
                          placesList('Declined', userId),
                          placesList('Pending', userId),
                          placesList('Approved', userId),
                        ])))
              ]);
            }
          },
        ));
  }

  Widget placesList(String status, String userID) {
    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    Stream<QuerySnapshot> list = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: status)
        .where('userId', isEqualTo: userID)
        .snapshots();

    return Container(
        height: double.infinity,
        child: Column(
          children: [
            //! places list
            Expanded(
                child: Container(
                    height: double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: list,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: Text('No available posts'));
                          }
                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text('No Data');
                            // const Center(
                            //     child: Text('There is no places currently',
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.normal,
                            //             fontSize: 17)));
                          } else {
                            final data = snapshot.requireData;
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  if (data.docs[index]['latitude'] != '') {
                                    double latitude = double.parse(
                                        '${data.docs[index]['latitude']}');
                                    double longitude = double.parse(
                                        '${data.docs[index]['longitude']}');

                                    return FutureBuilder(
                                      future: getLocationAsString(
                                          latitude, longitude),
                                      builder: (context, snap) {
                                        if (snap.hasData) {
                                          var reqLoc = snap.data;

                                          String category =
                                              data.docs[index]['category'];
                                          var icon;

                                          if (category == 'Education')
                                            icon = const Icon(Icons.school);
                                          else if (category == 'Transportation')
                                            icon = const Icon(
                                                Icons.directions_car);
                                          else
                                            icon = const Icon(Icons.school);

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24,
                                                right: 24,
                                                top: 8,
                                                bottom: 16),
                                            child: InkWell(
                                              onTap: () => showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) =>
                                                      buildPlace(
                                                          data.docs[index]
                                                              ['docId'])),
                                              //     Navigator.pushReplacement(
                                              //   context,
                                              //   PageRouteBuilder(
                                              //     pageBuilder: (context,
                                              //             animation1,
                                              //             animation2) =>
                                              //         place(
                                              //       placeID: data.docs[index]
                                              //           ['docId'],
                                              //     ),
                                              //     transitionDuration:
                                              //         const Duration(
                                              //             seconds: 1),
                                              //     reverseTransitionDuration:
                                              //         Duration.zero,
                                              //   ),
                                              // ),
                                              splashColor: Colors.transparent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          blurRadius: 32,
                                                          color: Colors.black45,
                                                          spreadRadius: -8)
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      16.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      16.0),
                                                            ),
                                                            child: AspectRatio(
                                                              aspectRatio: 2,
                                                              child:
                                                                  Image.network(
                                                                data.docs[index]
                                                                    ['img'],
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (BuildContext
                                                                        context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                                  return const Text(
                                                                      'Image could not be load');
                                                                },
                                                              ),
                                                            )),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Container(
                                                                    child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          13,
                                                                          8,
                                                                          0,
                                                                          8),
                                                                  child: Text(
                                                                    data.docs[
                                                                            index]
                                                                        [
                                                                        'name'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        13,
                                                                        0,
                                                                        0,
                                                                        15),
                                                                child: Text(
                                                                  data.docs[
                                                                          index]
                                                                      [
                                                                      'category'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.8)),
                                                                )),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const Center(child: Text(''));
                                        }
                                      },
                                    );
                                  } else {
                                    return const Center(child: Text(''));
                                  }
                                });
                          }
                        })))
          ],
        ));
  }

  Widget buildPlace(placeID) {
    late GoogleMapController myController;
    Set<Marker> getMarker(lat, lng) {
      return <Marker>{
        Marker(
            markerId: const MarkerId(''),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'location'))
      };
    }

    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    var data, latitude, longitude, isLocSet;
    Future<Map<String, dynamic>> getPlaceData(var id) =>
        FirebaseFirestore.instance.collection('posts').doc(id).get().then(
          (DocumentSnapshot doc) {
            data = doc.data() as Map<String, dynamic>;
            return doc.data() as Map<String, dynamic>;
          },
        );

    return FutureBuilder<Map<String, dynamic>>(
        future: getPlaceData(placeID),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data as Map<String, dynamic>;
            latitude = data['latitude'];
            longitude = data['longitude'];
            isLocSet = latitude == '' ? false : true;
            return DraggableScrollableSheet(
                maxChildSize: 1,
                minChildSize: 0.9,
                initialChildSize: 1,
                builder: (_, controller) =>
                    //  Scaffold(
                    //     backgroundColor: const Color(0xFFfcfffe),
                    //     body:
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        child: Stack(children: [
                          const Positioned(
                              width: 50,
                              height: 50,
                              top: 10,
                              left: 10,
                              child: Icon(Icons.navigate_before_outlined,
                                  size: 60)),
                          CustomScrollView(
                            controller: controller,
                            slivers: [
                              SliverAppBar(
                                toolbarHeight: 50,
                                automaticallyImplyLeading: false,
                                // leading: const Icon(Icons.navigate_before,
                                //     color: Colors.black),
                                bottom: PreferredSize(
                                    preferredSize: const Size.fromHeight(20),
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40.0),
                                            topRight: Radius.circular(40.0),
                                          ),
                                        ),
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 25, 0, 0),
                                        child: Text(data['name'],
                                            style: const TextStyle(
                                                fontSize: 25)))),
                                pinned: true,
                                expandedHeight: 300,
                                flexibleSpace: FlexibleSpaceBar(
                                    background: Image.network(
                                  data['img'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )),
                              ),
                              SliverToBoxAdapter(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 5, 15, 5),
                                      child: Column(children: [
                                        /*category*/ Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data['category'],
                                              style: const TextStyle(
                                                  wordSpacing: 2,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400),
                                            )),
                                        const SizedBox(height: 20),
                                        /*description*/ Visibility(
                                            visible: data['description'] != '',
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('About'),
                                                    const SizedBox(height: 7),
                                                    ReadMoreText(
                                                      data['description'],
                                                      style: const TextStyle(
                                                          wordSpacing: 2,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      trimLines: 4,
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          'View more',
                                                      trimExpandedText:
                                                          'View less',
                                                      moreStyle: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                      lessStyle: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ],
                                                ))),
                                        const SizedBox(height: 35),
                                        /*phone number, website, location*/ Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              border: Border.all(
                                                color: Colors.blue.shade50,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: Row(children: [
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    /*location*/ Visibility(
                                                        visible: isLocSet,
                                                        child: FutureBuilder(
                                                            future: getLocationAsString(
                                                                double.parse(
                                                                    latitude),
                                                                double.parse(
                                                                    longitude)),
                                                            builder: (context,
                                                                snap) {
                                                              if (snap
                                                                  .hasData) {
                                                                var reqLoc =
                                                                    snap.data;
                                                                return Row(
                                                                  children: [
                                                                    const Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            6,
                                                                            40),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .location_on_outlined,
                                                                          size:
                                                                              25,
                                                                          // color: Colors
                                                                          //     .white
                                                                        )),
                                                                    SizedBox(
                                                                        width:
                                                                            150,
                                                                        child: Text(
                                                                            reqLoc!,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              // color: Colors
                                                                              //     .white
                                                                            )))
                                                                  ],
                                                                );
                                                              } else {
                                                                return const Text(
                                                                    '');
                                                              }
                                                            })),
                                                    const SizedBox(height: 30),
                                                    /*website*/ Visibility(
                                                      visible:
                                                          data['Website'] != '',
                                                      child: InkWell(
                                                          child: Row(
                                                              children: const [
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            8,
                                                                            0),
                                                                    child: FaIcon(
                                                                        FontAwesomeIcons
                                                                            .globe,
                                                                        // color: Colors.white,
                                                                        size:
                                                                            22)),
                                                                Text('Website',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                      // color: Colors.white
                                                                    )),
                                                              ]),
                                                          onTap: () => launchUrl(
                                                              Uri.parse(data[
                                                                  'Website']))),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    /*phone number*/ Visibility(
                                                      visible: data[
                                                              'Phone number'] !=
                                                          '',
                                                      child: InkWell(
                                                          child: Row(children: [
                                                            const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            6,
                                                                            0),
                                                                child: Icon(
                                                                  Icons
                                                                      .call_outlined,
                                                                  // color: Colors.white
                                                                )),
                                                            Text(
                                                                data[
                                                                    'Phone number'],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Colors.white
                                                                )),
                                                          ]),
                                                          onTap: () => launchUrl(
                                                              Uri.parse(
                                                                  "tel:+9 66553014247"))),
                                                    ),
                                                    const SizedBox(height: 50),
                                                  ]),
                                              Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 0, 0, 0),
                                                  width: 180,
                                                  height: 250,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 5)
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0,
                                                                color: Colors
                                                                    .blue
                                                                    .shade50),
                                                          ),
                                                          child: GoogleMap(
                                                            markers: getMarker(
                                                                double.parse(
                                                                    latitude),
                                                                double.parse(
                                                                    longitude)),
                                                            mapType:
                                                                MapType.normal,
                                                            initialCameraPosition:
                                                                CameraPosition(
                                                              target: LatLng(
                                                                  double.parse(
                                                                      latitude),
                                                                  double.parse(
                                                                      longitude)),
                                                              zoom: 12.0,
                                                            ),
                                                            onMapCreated:
                                                                (GoogleMapController
                                                                    controller) {
                                                              myController =
                                                                  controller;
                                                            },
                                                          )))),
                                            ])),
                                        const SizedBox(height: 35),
                                        /*comment*/ Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  'Comments',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                              ],
                                            )),
                                        const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor sit amet elit eu sagittis. Maecenas at tellus convallis, scelerisque nibh id, condimentum dolor. Nullam in ligula ut felis facilisis pellentesque quis tincidunt elit. Suspendisse potenti. Sed ante urna, mollis id justo ut, mollis imperdiet nunc. Aliquam placerat interdum mauris non tempor. Integer ac diam velit. Vestibulum nec nibh dolor. Morbi ex leo, facilisis quis feugiat eget, gravida non tortor. Phasellus id consequat lacus, sed semper augue. Mauris tortor leo, iaculis gravida metus sed, tristique rutrum est' +
                                            'Pellentesque vehicula purus vitae eros scelerisque pretium. Donec in metus placerat nulla mollis scelerisque a et tellus. Aenean quis blandit turpis. Aliquam ultrices nunc ultrices massa rhoncus, sed rutrum tortor hendrerit. Sed pharetra pellentesque lectus, et posuere ex cursus consectetur. In et est faucibus, cursus mauris vel, tincidunt ex. Aenean a odio at enim sodales consectetur gravida euismod orci. Nunc feugiat urna vel sapien vulputate fringilla. Aliquam erat volutpat. Sed posuere a diam in pretium. Nam nec velit at ante ornare pharetra. Vestibulum turpis ipsum, suscipit at euismod at, malesuada in dui. Etiam nec lacus et justo pharetra malesuada eget eu diam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer tincidunt nulla eget purus tincidunt, in euismod augue iaculis. Duis gravida, lectus eget vestibulum suscipit, velit nunc aliquam nibh, et cursus neque velit eu neque.' +
                                            'Donec sit amet lacinia sem, ut facilisis dui. Curabitur nulla diam, maximus et lacus vel, convallis lobortis erat. Maecenas suscipit et nibh eu facilisis. Ut egestas, turpis in porta feugiat, neque nibh dignissim nulla, non molestie quam orci eget massa. Ut scelerisque molestie pulvinar. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis dictum elit quis nibh venenatis auctor. Nullam ut lacus in enim pretium fringilla. Nullam molestie convallis massa at dictum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Integer placerat, erat quis volutpat porttitor, mi felis tincidunt dolor, quis vulputate nulla nibh nec libero. Mauris egestas volutpat mauris iaculis lacinia. Nulla sollicitudin, sem vitae lobortis sagittis, augue felis finibus sapien, a semper dolor sem et mi. Mauris faucibus, ex in pellentesque commodo, nisi nulla viverra est, pellentesque finibus libero odio a turpis.' +
                                            'Nullam dapibus urna mauris, a rutrum diam mollis nec. Cras eu pellentesque nulla, et commodo enim. Integer ac quam id metus fermentum lobortis eu vel nulla. Morbi et nulla sollicitudin, ultrices urna suscipit, consequat risus. Etiam et sapien sem. Aliquam volutpat vestibulum luctus. Etiam convallis facilisis urna, vel dapibus ligula facilisis vel. Nunc non placerat dolor. Nulla sit amet placerat nibh. Etiam laoreet, sem in imperdiet commodo, enim mi posuere mi, at vestibulum eros magna vitae quam. Cras a felis sed ante placerat rutrum. Etiam efficitur orci ligula, ut scelerisque ante pharetra eget. Vestibulum non turpis tincidunt, porttitor neque at, dignissim risus. Duis et posuere orci, eu dictum nunc.' +
                                            'Vivamus dignissim pulvinar neque a tempus. Praesent sodales, ipsum sit amet placerat egestas, sapien leo posuere lacus, non sagittis elit dolor eget ligula. Proin convallis risus mauris, sit amet hendrerit enim suscipit lacinia. Maecenas vitae pellentesque mi. Vivamus lectus arcu, consequat nec mauris in, lacinia lacinia tortor. Mauris porta egestas ligula sed laoreet. Sed finibus ultricies arcu, at lacinia nulla consequat fe'),
                                      ]))),
                            ],
                          )
                        ])));
          } else {
            return const Text('');
          }
        });
  }
}
