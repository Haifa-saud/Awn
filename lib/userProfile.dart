import 'package:awn/addPost.dart';
import 'package:awn/login.dart';
import 'package:awn/requestWidget.dart';
import 'package:awn/services/appWidgets.dart';
import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/placeWidget.dart';
import 'package:awn/services/newRequestNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'chatPage.dart';
import 'services/firebase_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:toggle_switch/toggle_switch.dart';

var userName = '';

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
  initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userName = (doc.data() as Map<String, dynamic>)['name'];
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
          future: readUserData(FirebaseAuth.instance.currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              userData = snapshot.data as Map<String, dynamic>;
              var isVolunteer = userData['Type'] == "Volunteer" ? true : false;

              return Scaffold(
                  appBar: AppBar(
                    actions: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded),
                            iconSize: 25,
                            color: const Color(0xFF39d6ce),
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

//! My Info
  Widget myInfo(var userData) {
    Widget widget = MyInfo(
        user: userData,
        onUpdate: () {
          setState(() {});
        });
    return widget;
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
    var userType = isVolunteer ? 'VolID' : 'userID';

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
                          return ListView.builder(
                              controller: _scrollController,
                              itemCount: data.size,
                              itemBuilder: (context, index) {
                                var reqLoc;
                                var OtherUserID = isVolunteer
                                    ? data.docs[index]['userID']
                                    : data.docs[index]['VolID'];
                                double latitude = double.parse(
                                    '${data.docs[index]['latitude']}');
                                double longitude = double.parse(
                                    '${data.docs[index]['longitude']}');

                                var status = str == 'Previous'
                                    ? getStatus(data.docs[index]['status'],
                                        data.docs[index]['docId'])
                                    : data.docs[index]['status'];

                                var isRequestActive = false;
                                if (data.docs[index]['status'] == 'Approved') {
                                  var duration = data.docs[index]['duration'];
                                  print('total duration: $duration');

                                  var dateTime = data.docs[index]['date_ymd'];
                                  final now = DateTime.now();
                                  var year =
                                      int.parse(dateTime.substring(0, 4));
                                  var month =
                                      int.parse(dateTime.substring(5, 7));
                                  var day =
                                      int.parse(dateTime.substring(8, 10));
                                  var hours =
                                      int.parse(dateTime.substring(11, 13));
                                  var minutes =
                                      int.parse(dateTime.substring(14));

                                  final expirationDate = DateTime(
                                          year, month, day, hours, minutes)
                                      .add(Duration(
                                          hours: int.parse(duration.substring(
                                              0, duration.indexOf(':'))),
                                          minutes: int.parse(duration.substring(
                                              duration.indexOf(':') + 1))));
                                  isRequestActive = expirationDate.isAfter(now);

                                  print(
                                      "expirationDate $expirationDate $isRequestActive");
                                }

                                return FutureBuilder(
                                    future: getLocationAsString(
                                        latitude, longitude),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        var reqLoc = snap.data;
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 5, 10, 5),
                                            child: Stack(children: [
                                              InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              requestPage(
                                                            reqID:
                                                                data.docs[index]
                                                                    ['docId'],
                                                            userType:
                                                                widget.userType,
                                                          ),
                                                        ));
                                                  },
                                                  child: Container(
                                                    width: 600,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5, bottom: 12),
                                                    padding:
                                                        const EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                              blurRadius: 32,
                                                              color: Colors
                                                                  .black45,
                                                              spreadRadius: -8)
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
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
                                                                    8,
                                                                    8,
                                                                    8,
                                                                    10),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            6,
                                                                            10,
                                                                            15,
                                                                            15),
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Align(
                                                                              alignment: Alignment.topLeft,
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
                                                                            visible:
                                                                                !isVolunteer,
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.topRight,
                                                                              margin: const EdgeInsets.only(top: 5),
                                                                              child: Text(status,
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
                                                                          20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.calendar_today,
                                                                                size: 20,
                                                                                color: Colors.red.shade200),
                                                                            Text(' ${data.docs[index]['date_dmy']}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 17,
                                                                                  fontWeight: FontWeight.w400,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 40),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.schedule,
                                                                                size: 20,
                                                                                color: Colors.red.shade200),
                                                                            Text(' ${data.docs[index]['time']}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 17,
                                                                                  fontWeight: FontWeight.w400,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                data.docs[index]
                                                                            [
                                                                            'status'] ==
                                                                        'Approved'
                                                                    ? FutureBuilder(
                                                                        future: readUserData(
                                                                            OtherUserID),
                                                                        builder:
                                                                            (context,
                                                                                snap) {
                                                                          if (snap
                                                                              .hasData) {
                                                                            var userData =
                                                                                snap.data; //the other user from request data
                                                                            return Align(
                                                                              alignment: Alignment.center,
                                                                              child: Container(
                                                                                  height: 50,
                                                                                  padding: const EdgeInsets.all(6),
                                                                                  decoration: BoxDecoration(
                                                                                      color: Colors.blue.shade50,
                                                                                      border: Border.all(
                                                                                        width: 1,
                                                                                        color: Colors.blue.shade50,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.circular(10)),
                                                                                  child: Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: <Widget>[
                                                                                      Text(widget.userType != 'Special Need User' ? 'Special Need User:' : 'Volunteer:',
                                                                                          style: const TextStyle(
                                                                                            fontSize: 17,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            wordSpacing: 0.1,
                                                                                            letterSpacing: 0.1,
                                                                                          )),
                                                                                      const SizedBox(height: 7),
                                                                                      Text(' ${userData!['name']}',
                                                                                          style: const TextStyle(
                                                                                            fontSize: 17,
                                                                                            fontWeight: FontWeight.w400,
                                                                                            wordSpacing: 0.1,
                                                                                            letterSpacing: 0.1,
                                                                                          )),
                                                                                      // SizedBox(width: 5),
                                                                                      Spacer(),
                                                                                      Visibility(
                                                                                          visible: isRequestActive,
                                                                                          child: CircleAvatar(
                                                                                              backgroundColor: Colors.white,
                                                                                              // .shade200,
                                                                                              // const Color(
                                                                                              //     0xFF39d6ce), //Color(0xffE6E6E6),
                                                                                              radius: 22,
                                                                                              child: IconButton(
                                                                                                icon: const Icon(Icons.chat_outlined),
                                                                                                iconSize: 25,
                                                                                                color: Colors.blue,
                                                                                                onPressed: () {
                                                                                                  Navigator.push(
                                                                                                    context,
                                                                                                    PageRouteBuilder(
                                                                                                      pageBuilder: (context, animation1, animation2) => ChatPage(requestID: data.docs[index]['docId']),
                                                                                                      transitionDuration: const Duration(seconds: 1),
                                                                                                      reverseTransitionDuration: Duration.zero,
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              ))),
                                                                                    ],
                                                                                  )),
                                                                            );
                                                                          } else {
                                                                            return const Center(child: CircularProgressIndicator());
                                                                          }
                                                                        })
                                                                    : SizedBox(
                                                                        height:
                                                                            0),
                                                              ],
                                                            ),
                                                          ),
                                                        ]),
                                                  ))
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
                            userId: userId,
                            category: '',
                            status: 'Declined',
                            userName: userData['name'],
                            userType: userData['Type'],
                          ),
                          Place(
                            userId: userId,
                            category: '',
                            status: 'Pending',
                            userName: userData['name'],
                            userType: userData['Type'],
                          ),
                          Place(
                            userId: userId,
                            category: '',
                            status: 'Approved',
                            userName: userData['name'],
                            userType: userData['Type'],
                          ),
                        ])))
              ]);
            }
          },
        ));
  }
}

//! Mu Info
class MyInfo extends StatefulWidget {
  // final String userId;
  final Function() onUpdate;
  final user;
  const MyInfo({required this.user, required this.onUpdate, super.key});
  @override
  MyInfoState createState() => MyInfoState();
}

var outDate;

bool isEditing = false;

class MyInfoState extends State<MyInfo> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController disabilityController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var DisabilityType;

  String gender_edit = '', Dis_edit = '';
  bool blind = false;
  bool mute = false;
  bool deaf = false;
  bool physical = false;
  bool other = false;
  String typeId = "";
  bool getPassword = false;
  bool invalidEmail = false;

  var _formKey;
  var userData;
  var gender_index = 1;
  var isSpecial, dis;
  String emailErrorMessage = '';

  void clearBool() {
    blind = false;
    mute = false;
    deaf = false;
    physical = false;
    other = false;
    typeId = "";
    Dis_edit = '';
    dis = "";
    getPassword = false;
    passwordController.text = '';
  }

  void user_disablitiy(String dis) {
    if (dis.contains('Vocally')) {
      mute = true;
    } else {
      mute = false;
    }
    if (dis.contains('Visually')) {
      blind = true;
    } else {
      blind = false;
    }
    if (dis.contains('Hearing')) {
      deaf = true;
    } else {
      deaf = false;
    }
    if (dis.contains('Physically')) {
      physical = true;
    } else {
      physical = false;
    }
    if (dis.contains('Other')) {
      other = true;
    } else {
      other = false;
    }
  }

  @override
  initState() {
    userData = widget.user;
    nameController.text = userData['name'];
    emailController.text = userData['Email'];
    genderController.text = userData['gender'];
    phoneController.text = userData['phone number'];
    bioController.text = userData['bio'];
    dateController.text = userData['DOB'];
    disabilityController.text = userData['Disability'];

    DisabilityType = FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .collection('UserDisabilityType');

    isSpecial = false;
    isEditing = false;
    emailErrorMessage = 'no error';

    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  void genderIndex(int n) {
    if (n == 1) {
      gender_edit = 'Female';
      gender_index = 1;
    } else {
      gender_edit = 'Male';
      gender_index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    DisabilityType = FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .collection('UserDisabilityType');

    user_disablitiy(disabilityController.text);

    print(dis);
    var isF = genderController.text == "Female" ? 1 : 0;
    genderIndex(isF);
    DateTime iniDOB = DateTime.parse(userData['DOB']);

    return Scaffold(
        body: SingleChildScrollView(
            child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Form(
          const SizedBox(
            height: 15,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(30, 12, 30, 22),
              child: Column(
                children: [
                  Column(children: [
                    //name field
                    TextFormField(
                      enabled: isEditing,
                      readOnly: !isEditing,
                      controller: nameController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF06283D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: 'Name',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if ((value != null && value.length < 2) ||
                            value == null ||
                            value.isEmpty ||
                            (value.trim()).isEmpty) {
                          return "Enter a valid name";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    //Email field
                    TextFormField(
                      readOnly: !isEditing,
                      enabled: isEditing,
                      controller: emailController,
                      onChanged: (value) {
                        if (userData['Email'] != value) {
                          setState(() {
                            getPassword = true;
                          });
                        } else if (userData['Email'] == value) {
                          setState(() {
                            getPassword = false;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF06283D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email != null &&
                            !EmailValidator.validate(email) &&
                            email.trim() == '') {
                          return "Enter a valid email";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    //Password
                    Visibility(
                        visible: getPassword && isEditing,
                        child: TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF06283D)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: 'Password',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) {
                            if (email != null &&
                                !EmailValidator.validate(email) &&
                                email.trim() == '') {
                              return "Please fill the field";
                            } else {
                              return null;
                            }
                          },
                        )),
                    Visibility(
                      visible: getPassword && isEditing,
                      child: const SizedBox(height: 15),
                    ),
                    Visibility(
                        visible: getPassword && isEditing && !invalidEmail,
                        child: const Text(
                            'Enter your password to update your email. Please note that you will be logged out automatically after a successful email update',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.normal))),
                    Visibility(
                        visible: getPassword && isEditing && invalidEmail,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(emailErrorMessage,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal)),
                        )),
                    Visibility(
                      visible: getPassword && isEditing,
                      child: const SizedBox(height: 30),
                    ),

                    //DOB field
                    TextFormField(
                      enabled: isEditing,
                      controller: dateController,
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(dateController.text),
                          firstDate: DateTime(1922),
                          lastDate: DateTime.now(),
                        );
                        if (newDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(newDate);
                            print(newDate);
                            iniDOB = newDate;
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF06283D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: 'Date of Birth',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    //Gender fields
                    !isEditing
                        ? TextFormField(
                            readOnly: false,
                            enabled: false,
                            controller: genderController,
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF06283D)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 2.0)),
                              focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 2.0)),
                              contentPadding: EdgeInsets.only(bottom: 3),
                              labelText: 'Gender',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              ToggleSwitch(
                                minWidth: 175.0,
                                minHeight: 50.0,
                                fontSize: 17,
                                initialLabelIndex: gender_index,
                                cornerRadius: 10.0,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey.shade300,
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                labels: ['Male', 'Female'],
                                activeBgColors: [
                                  [const Color.fromARGB(255, 111, 174, 225)],
                                  [const Color.fromARGB(255, 232, 116, 155)]
                                ],
                                onToggle: (index) {
                                  if (index == 0) {
                                    gender_index = 0;
                                    gender_edit = 'Male';
                                    genderController.text = 'Male';
                                    print('switched to: male');
                                  } else {
                                    gender_index = 1;
                                    gender_edit = 'Female';
                                    genderController.text = 'Female';
                                    print('switched to: female');
                                  }
                                },
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 30,
                    ),

                    //phone number field
                    TextFormField(
                      enabled: isEditing,
                      readOnly: !isEditing,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 10,
                      controller: phoneController,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF06283D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        focusedErrorBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0)),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: 'Phone Number',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
                          return "Please enter a phone number";
                        } else if (value.length != 10) {
                          return "Please enter a valid phone number";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),

                    //disability
                    Visibility(
                      visible: userData['Type'] != "Volunteer" && !isEditing,
                      child: TextFormField(
                        enabled: false,
                        controller: disabilityController,
                        maxLines: null,
                        decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF06283D)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: 'Type of Disability',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    Visibility(
                        visible: userData['Type'] != "Volunteer" && isEditing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'Type of Disability',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userData['id'])
                                      .collection('UserDisabilityType')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Container(
                                              child: CheckboxListTile(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                0, 0, 50, 0),
                                            value: (document.data()
                                                as Map)['Checked'],
                                            onChanged: (bool? newValue) {
                                              typeId = (document.data()
                                                      as Map)['Type']
                                                  .replaceAll(' ', '');
                                              DisabilityType.doc(typeId).update(
                                                  {'Checked': newValue});
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Visually Impaired') {
                                                blind = !blind;
                                                print('blind: $blind');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Vocally Impaired') {
                                                mute = !mute;
                                                print('mute: $mute');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Hearing Impaired') {
                                                deaf = !deaf;
                                                print('deaf: $deaf');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Physically Impaired') {
                                                physical = !physical;
                                                print('physical: $physical');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Other') {
                                                other = !other;
                                                print('other: $other');
                                              }
                                            },
                                            title: Text(
                                                (document.data()
                                                    as Map)['Type'],
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                          ));
                                        }).toList(),
                                      );
                                    }
                                  }),
                            ),
                          ],
                        )),
                    Visibility(
                        visible: userData['Type'] != 'Volunteer',
                        child: const SizedBox(
                          height: 30,
                        )),

                    //bio field
                    Visibility(
                        visible: userData['Type'] == 'Volunteer',
                        child: TextFormField(
                          enabled: isEditing,
                          controller: bioController,
                          maxLength: 180,
                          minLines: 1,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF06283D)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 3),
                            labelText: 'Bio',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        )),
                    Visibility(
                        visible: userData['Type'] == 'Volunteer',
                        child: const SizedBox(
                          height: 30,
                        )),
                  ]),
                  //Edit, delete buttons :
                  !isEditing
                      ? /*Edit and Delete buttons*/ Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              width: 150,
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
                                  setState(() {
                                    isEditing = true;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              width: 150,
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 5.0)
                                ],
                                // gradient: const LinearGradient(
                                //   begin: Alignment.topLeft,
                                //   end: Alignment.bottomRight,
                                //   stops: [0.0, 1.0],
                                //   colors: [
                                //     Colors.blue,
                                //     Color(0xFF39d6ce),
                                //   ],
                                // ),
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Delete Account?"),
                                      content: const Text(
                                        "Are You Sure You want to delete your Account? , This action can't be undone",
                                        textAlign: TextAlign.left,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("Cancel"),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(ctx).pop();
                                            /*SNU request*/ FirebaseFirestore
                                                .instance
                                                .collection('requests')
                                                .get()
                                                .then((snapshot) {
                                              List<DocumentSnapshot> allDocs =
                                                  snapshot.docs;
                                              List<DocumentSnapshot>
                                                  filteredDocs = allDocs
                                                      .where((document) =>
                                                          (document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'userID'] ==
                                                          userData['id'])
                                                      .toList();
                                              for (DocumentSnapshot ds
                                                  in filteredDocs) {
                                                ds.reference.delete().then((_) {
                                                  print("request deleted");
                                                });
                                              }
                                            });
                                            /*Volunteer request*/ FirebaseFirestore
                                                .instance
                                                .collection('requests')
                                                .get()
                                                .then((snapshot) {
                                              List<DocumentSnapshot> allDocs =
                                                  snapshot.docs;
                                              List<DocumentSnapshot>
                                                  filteredDocs = allDocs
                                                      .where((document) =>
                                                          (document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'VolID'] ==
                                                          userData['id'])
                                                      .toList();
                                              for (DocumentSnapshot ds
                                                  in filteredDocs) {
                                                var dateTime = ds['date_ymd'];
                                                final now = DateTime.now();
                                                var year = int.parse(
                                                    dateTime.substring(0, 4));
                                                var month = int.parse(
                                                    dateTime.substring(5, 7));
                                                var day = int.parse(
                                                    dateTime.substring(8, 10));
                                                var hours = int.parse(
                                                    dateTime.substring(11, 13));
                                                var minutes = int.parse(
                                                    dateTime.substring(14));

                                                final expirationDate = DateTime(
                                                    year,
                                                    month,
                                                    day,
                                                    hours,
                                                    minutes);
                                                var isRequestActive =
                                                    expirationDate.isAfter(now);

                                                print(
                                                    "expirationDate $expirationDate $isRequestActive");
                                                if (isRequestActive) {
                                                  ds.reference.update({
                                                    'status': 'Pending',
                                                    'VolID': '',
                                                  }).then((_) {
                                                    print(
                                                        "vol request updated");
                                                  });
                                                  // ds.reference.collection(chat)
                                                } else {
                                                  ds.reference.update({
                                                    'status': 'Expired',
                                                    'VolID': ''
                                                  }).then((_) {
                                                    print(
                                                        "vol request updated");
                                                  });
                                                }
                                              }
                                            });
                                            FirebaseFirestore.instance
                                                .collection('Comments')
                                                .get()
                                                .then((snapshot) {
                                              List<DocumentSnapshot> allDocs =
                                                  snapshot.docs;
                                              List<DocumentSnapshot>
                                                  filteredDocs = allDocs
                                                      .where((document) =>
                                                          (document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'UserID'] ==
                                                          userData['id'])
                                                      .toList();
                                              for (DocumentSnapshot ds
                                                  in filteredDocs) {
                                                ds.reference.delete().then((_) {
                                                  print("comments deleted");
                                                });
                                              }
                                            });
                                            // await Navigator.pushNamed(
                                            //     context, '/login');

                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(userData['id'])
                                                .delete()
                                                .then((_) {
                                              print("success!, user deleted");
                                            });
                                            FirebaseAuth.instance.currentUser!
                                                .delete()
                                                .then((value) {
                                              Navigator.pushNamed(
                                                  context, '/login');
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 194, 98, 98))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Delete Account'),
                              ),
                            ),
                          ],
                        )
                      : /*Save and Cancel buttons*/ Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 150,
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
                                onPressed: () async {
                                  if (blind == false &&
                                      mute == false &&
                                      deaf == false &&
                                      other == false &&
                                      physical == false &&
                                      userData['Type'] != "Volunteer") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please choose a disability'),
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                    );
                                  } else {
                                    if (_formKey.currentState!.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Save?"),
                                          content: const Text(
                                            "Are You Sure You want to save changes?",
                                            textAlign: TextAlign.left,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: const Text("Cancel",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 194, 98, 98))),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                UpdateDB();
                                                Navigator.of(context).pop();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: const Text(
                                                  "Save",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // Cancel changes
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 150,
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
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Are You Sure ?"),
                                      content: const Text(
                                        "Are You Sure You want to Cancel changes ?",
                                        textAlign: TextAlign.left,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isEditing = false;
                                              userData = widget.user;
                                              getPassword = false;
                                              nameController.text =
                                                  userData['name'];
                                              emailController.text =
                                                  userData['Email'];
                                              genderController.text =
                                                  userData['gender'];
                                              phoneController.text =
                                                  userData['phone number'];
                                              bioController.text =
                                                  userData['bio'];
                                              dateController.text =
                                                  userData['DOB'];
                                              disabilityController.text =
                                                  userData['Disability'];
                                              invalidEmail = false;
                                              passwordController.text = '';
                                            });
                                            Navigator.of(ctx).pop();
                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text("Yes",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 194, 98, 98))),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            child: const Text(
                                              "No",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                ],
              )),
        ],
      ),
    )));
  }

  Future<void> UpdateDB() async {
    Dis_edit = '';
    print('blind: $blind');
    print('mute: $mute');
    print('deaf: $deaf');
    print('physical: $physical');
    print('other: $other');
    if (blind == true) Dis_edit += "Visually Impaired, ";
    if (mute == true) Dis_edit += "Vocally Impaired, ";
    if (deaf == true) Dis_edit += "Hearing Impaired, ";
    if (physical == true) Dis_edit += "Physically Impaired, ";
    if (other == true) Dis_edit += "Other, ";
    print('in update');
    disabilityController.text = Dis_edit;

    var Edit_info =
        FirebaseFirestore.instance.collection('users').doc(widget.user['id']);
    var errorMessage = '';
    emailErrorMessage = '';
    invalidEmail = false;

    if (emailController.text != userData['Email']) {
      var result = await user
          .reauthenticateWithCredential(EmailAuthProvider.credential(
        email: userData['Email'],
        password: passwordController.text,
      ))
          .catchError((error) {
        invalidEmail = true;
        errorMessage = error.message;
        setState(() {
          invalidEmail = true;
          emailErrorMessage =
              'Invalid password, the authentication failed. Please try again.';
        });
        print('update catch error: $error');
        print('update catch errorMessage: $errorMessage');
      });
      await result.user!.updateEmail(emailController.text).catchError((error) {
        errorMessage = error.message;
        setState(() {
          emailErrorMessage = error.message;
          invalidEmail = true;
        });
        invalidEmail = true;
        print('update catch error: $error');
        print('update catch errorMessage: $emailErrorMessage');
      });

      print('errorMessage outside: $errorMessage $invalidEmail');

      if (!invalidEmail) {
        passwordController.text = '';

        Edit_info.update({
          'name': nameController.text,
          'gender': genderController.text,
          'phone number': phoneController.text,
          'Email': emailController.text,
          'bio': bioController.text,
          'DOB': dateController.text,
          'Disability': disabilityController.text
        });
        await Navigator.pushNamed(context, '/login');

        setState(() {
          userName = nameController.text;
        });
        widget.onUpdate();
        invalidEmail = false;
        print('profile edited');
        clearBool();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes has been Saved!')),
        );
        setState(() {
          isEditing = false;
        });
      }
    } else {
      // if (emailErrorMessage == '') {
      passwordController.text = '';
      Edit_info.update({
        'name': nameController.text,
        'gender': genderController.text,
        'phone number': phoneController.text,
        'Email': emailController.text,
        'bio': bioController.text,
        'DOB': dateController.text,
        'Disability': disabilityController.text
      });
      //  Navigator.pushNamed(context, '/login');
      // await FirebaseAuth.instance.signOut();

      setState(() {
        userName = nameController.text;
      });
      widget.onUpdate();
      invalidEmail = false;
      print('profile edited');
      clearBool();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes has been Saved!')),
      );
      setState(() {
        isEditing = false;
      });
      if (emailController.text != userData['Email']) {
        await FirebaseAuth.instance.signOut();
      }
    }
    // else {
    //   isEditing = true;
    // }
  }
}
