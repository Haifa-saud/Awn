import 'package:awn/addPost.dart';
import 'package:awn/login.dart';
import 'package:awn/mapsPage.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/placeWidget.dart';
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
import 'chatPage.dart';
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
                    toolbarHeight: 60,
                    title: Row(children: [
                      Container(
                        height: 45,
                        width: 45,
                        margin: const EdgeInsets.fromLTRB(8, 12, 10, 0),
                        child: const CircleAvatar(
                          backgroundColor: Color.fromARGB(
                              255, 149, 204, 250), //Color(0xffE6E6E6),
                          radius: 30,
                          child: Icon(Icons.person,
                              size: 35, color: Colors.white //Color(0xffCCCCCC),
                              ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData['name'],
                                    style: const TextStyle(fontSize: 20)),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      userData['Type'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color.fromARGB(136, 6, 40, 61),
                                          fontSize: 15,
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
              transitionDuration: const Duration(seconds: 1),
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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        6,
                                                                        10,
                                                                        15,
                                                                        15),
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
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
                                                                      Spacer(),
                                                                      Visibility(
                                                                          visible: status ==
                                                                              'Approved',
                                                                          child:
                                                                              IconButton(
                                                                            icon:
                                                                                const Icon(Icons.chat_outlined),
                                                                            iconSize:
                                                                                25,
                                                                            color:
                                                                                const Color(0xFF39d6ce), //Color.fromARGB(255, 149, 204, 250),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.push(
                                                                                context,
                                                                                PageRouteBuilder(
                                                                                  pageBuilder: (context, animation1, animation2) => ChatPage(requestID: data.docs[index]['docId']),
                                                                                  transitionDuration: const Duration(seconds: 1),
                                                                                  reverseTransitionDuration: Duration.zero,
                                                                                ),
                                                                              );
                                                                            },
                                                                          )),
                                                                      Visibility(
                                                                        visible:
                                                                            !isVolunteer,
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          margin:
                                                                              const EdgeInsets.only(top: 5),
                                                                          // width:
                                                                          //     80,
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

    int tabIndex = 0;
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
                    height: 50,
                    radius: 15,
                    buttonMargin: const EdgeInsets.fromLTRB(4, 8, 4, 1),
                    unselectedDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    unselectedLabelStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                    tabs: <Tab>[
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(width: 2, color: Colors.red.shade300),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          "Declined",
                          style: TextStyle(color: Colors.red.shade300),
                        ),
                      )),
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              width: 2, color: Colors.orange.shade200),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          "Pending",
                          style: TextStyle(color: Colors.orange.shade200),
                        ),
                      )),
                      Tab(
                          child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              width: 2, color: Colors.green.shade300),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          "Approved",
                          style: TextStyle(color: Colors.green.shade300),
                        ),
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
                          Place(
                              userId: userId, category: '', status: 'Declined'),
                          Place(
                              userId: userId, category: '', status: 'Pending'),
                          Place(
                              userId: userId, category: '', status: 'Approved'),
                        ])))
              ]);
            }
          },
        ));
  }
}
