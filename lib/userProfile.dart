import 'package:Awn/addPost.dart';
import 'package:Awn/login.dart';
import 'package:Awn/requestWidget.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/placeWidget.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/viewRequests.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:justino_icons/justino_icons.dart';
import 'package:workmanager/workmanager.dart';
import 'TextToSpeech.dart';
import 'addRequest.dart';
import 'chatPage.dart';
import 'homePage.dart';
import 'services/firebase_options.dart';
import 'package:email_validator/email_validator.dart';
import 'package:toggle_switch/toggle_switch.dart';

var userName = '';

class userProfile extends StatefulWidget {
  const userProfile(
      {Key? key,
      required this.userType,
      required this.selectedTab,
      required this.selectedSubTab})
      : super(key: key);

  final String userType;
  final int selectedTab;
  final int selectedSubTab;

  @override
  UserProfileState createState() => UserProfileState();
}

ScrollController _scrollController = ScrollController();

class UserProfileState extends State<userProfile>
    with TickerProviderStateMixin {
  NotificationService notificationService = NotificationService();
  final Storage storage = Storage();
  var userData;
  var userId = FirebaseAuth.instance.currentUser!.uid;

  int _selectedIndex = 3;
  late TabController _mainTabController;
  late TabController _requestsTabController;
  late TabController _placesTabController;

  @override
  initState() {
    notificationService = NotificationService();
    listenToNotificationStream();

    notificationService.initializePlatformNotifications();
    _mainTabController =
        TabController(length: 3, vsync: this, initialIndex: widget.selectedTab);
    _requestsTabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedSubTab);
    _placesTabController = TabController(
        length: 3, vsync: this, initialIndex: widget.selectedSubTab);

    super.initState();
  }

  //! tapping local notification
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        if (payload.contains('-')) {
          if (payload.substring(0, payload.indexOf('-')) ==
              'requestAcceptance') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => requestPage(
                    fromSNUNotification: true,
                    userType: 'Special Need User',
                    reqID: payload.substring(payload.indexOf('-') + 1)),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (payload.substring(0, payload.indexOf('-')) == 'chat') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => ChatPage(
                    requestID: payload.substring(payload.indexOf('-') + 1),
                    fromNotification: true),
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      viewRequests(userType: 'Volunteer', reqID: payload)));
        }
      });

  Future<Map<String, dynamic>> readUserData(var id) =>
      FirebaseFirestore.instance.collection('users').doc(id).get().then(
        (DocumentSnapshot doc) {
          userName = (doc.data() as Map<String, dynamic>)['name'];
          return doc.data() as Map<String, dynamic>;
        },
      );

  Future<dynamic> alertDialog(var nav) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          "Discard the changes you made?",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Keep editing"),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => nav,
                  transitionDuration: const Duration(seconds: 1),
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              clearForm();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Discard",
                  style: TextStyle(color: Color.fromARGB(255, 164, 10, 10))),
            ),
          ),
        ],
      ),
    );
  }

  //! bottom bar nav
  final iconSNU = <IconData>[
    Icons.home,
    Icons.volume_up,
    Icons.handshake,
    Icons.person,
  ];

  final iconVol = <IconData>[
    Icons.home,
    Icons.handshake,
    Icons.person,
  ];
  @override
  Widget build(BuildContext context) {
    var iconList = widget.userType == 'Volunteer'
        ? <IconData, String>{
            Icons.home: 'Home',
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          }
        : <IconData, String>{
            Icons.home: "Home",
            JustinoIcons.getByName('speech') as IconData: "Text to Speech",
            Icons.handshake: "Awn Request",
            Icons.person: "Profile",
          };

    Future<void> _onItemTapped(int index) async {
      if (widget.userType == 'Special Need User') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = Tts(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = addRequest(userType: widget.userType);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 3) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      } else if (widget.userType == 'Volunteer') {
        if (index == 0) {
          var nav = const homePage();
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 1) {
          var nav = viewRequests(userType: widget.userType, reqID: '');
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        } else if (index == 2) {
          var nav = userProfile(
              userType: widget.userType, selectedTab: 0, selectedSubTab: 0);
          if (isEdited) {
            alertDialog(nav);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nav,
                transitionDuration: const Duration(seconds: 1),
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      }
    }

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
                                    "Are You Sure You want to log out of your account?",
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
                                        await FirebaseMessaging.instance
                                            .deleteToken();
                                        // await FirebaseFirestore.instance
                                        //     .collection('users')
                                        //     .doc(FirebaseAuth
                                        //         .instance.currentUser!.uid)
                                        //     .set({'token': ''},
                                        //         SetOptions(merge: true));
                                        Navigator.pushNamed(context, '/login');
                                        await _signOut();
                                      },
                                      child: Container(
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
                    backgroundColor: Colors.white,
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
                                controller: _mainTabController,
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
                                controller: _mainTabController,
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
                  addPost(userType: userData['Type']),
              transitionDuration: const Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        splashColor: Colors.blue,
        backgroundColor: Colors.white,
        splashRadius: 1,
        splashSpeedInMilliseconds: 100,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          final size = isActive ? 30.0 : 25.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList.keys.toList()[index],
                size: size,
                color: color,
              ),
              const SizedBox(height: 1),
              Visibility(
                visible: isActive,
                child: Text(
                  iconList.values.toList()[index],
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      letterSpacing: 1,
                      wordSpacing: 1),
                ),
              )
            ],
          );
        },
        activeIndex: widget.userType == 'Volunteer' ? 2 : 3,
        itemCount: widget.userType == 'Volunteer' ? 3 : 4,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }

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
                          return Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text('There is no requests currently.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 17,
                                          color: Colors.blue.shade800))));
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
                                  var endDateTime = DateTime.parse(
                                      data.docs[index]['endDateTime']);
                                  // print('total duration: $duration');

                                  var dateTime = data.docs[index]['date_ymd'];
                                  final now = DateTime.now();

                                  isRequestActive = endDateTime.isAfter(now);

                                  print(
                                      "expirationDate $endDateTime $isRequestActive");
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
                    controller: _placesTabController,
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
                          "Denied",
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
                        child: TabBarView(
                            controller: _placesTabController,
                            children: [
                              Place(
                                userId: userId,
                                category: '',
                                status: 'Denied',
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

var isEdited;

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

class MyInfoState extends State<MyInfo> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController disabilityController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  editing(var value) {
    setState(() {
      isEdited = value;
    });
  }

  bool isEditing = false;
  bool blind = false;
  bool mute = false;
  bool deaf = false;
  bool physical = false;
  bool other = false;
  bool blindDB = false,
      muteDB = false,
      deafDB = false,
      physicalDB = false,
      otherDB = false;

  var DisabilityType;

  String gender_edit = '', Dis_edit = '';

  String typeId = "";
  bool getPassword = false;
  bool invalidEmail = false;

  var _formKey;
  var userData;
  var gender_index = 1;
  var isSpecial;
  String emailErrorMessage = '';

  void clearBool() {
    // blindDB = false;
    // muteDB = false;
    // deafDB = false;
    // physicalDB = false;
    // otherDB = false;

    // blind = false;
    // mute = false;
    // deaf = false;
    // physical = false;
    // other = false;
    typeId = "";
    Dis_edit = '';
    getPassword = false;
    passwordController.text = '';
    isEditing = false;
  }

  Future<void> user_disablitiy(String dis) async {
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

  var user;
  @override
  initState() {
    user = FirebaseAuth.instance.currentUser!;

    userData = widget.user;
    nameController.text = userData['name'];
    emailController.text = userData['Email'];
    genderController.text = userData['gender'];
    phoneController.text = userData['phone number'];
    bioController.text = userData['bio'];
    dateController.text = userData['DOB'];
    disabilityController.text = userData['Disability'];

    isEdited = false;
    user_disablitiy(disabilityController.text);

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

  Future<void> setBool() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .collection('UserDisabilityType')
        .snapshots()
        .map((snapshot) {
      snapshot.docs.map((DocumentSnapshot document) {
        switch ((document.data() as Map)['Type']) {
          case 'Visually Impaired':
            blind = (document.data() as Map)['Checked'];
            break;
          case 'Vocally Impaired':
            mute = (document.data() as Map)['Checked'];
            break;
          case 'Hearing Impaired':
            deaf = (document.data() as Map)['Checked'];
            break;
          case 'Physically Impaired':
            physical = (document.data() as Map)['Checked'];
            break;
          case 'Other':
            other = (document.data() as Map)['Checked'];
            break;
        }
      });
    });
  }

  isEditingfun() async {
    setState(() {
      isEditing = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .collection('UserDisabilityType')
        .snapshots()
        .map((snapshot) {
      snapshot.docs.map((DocumentSnapshot document) {
        switch ((document.data() as Map)['Type']) {
          case 'Visually Impaired':
            blindDB = (document.data() as Map)['Checked'];
            break;
          case 'Vocally Impaired':
            muteDB = (document.data() as Map)['Checked'];
            break;
          case 'Hearing Impaired':
            deafDB = (document.data() as Map)['Checked'];
            break;
          case 'Physically Impaired':
            physicalDB = (document.data() as Map)['Checked'];
            break;
          case 'Other':
            otherDB = (document.data() as Map)['Checked'];
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      onChanged: (value) {
                        if (nameController.text.trim() != userData['name']) {
                          editing(true);
                        } else {
                          editing(false);
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
                            editing(true);
                          });
                        } else if (userData['Email'] == value) {
                          setState(() {
                            getPassword = false;
                            editing(false);
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
                      readOnly: true,
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
                            iniDOB = newDate;
                          });
                          if (dateController.text != userData['DOB']) {
                            editing(true);
                          } else {
                            editing(false);
                          }
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
                                minWidth: 170.0,
                                minHeight: 45.0,
                                borderWidth: 1,
                                borderColor: [
                                  Colors.blue.shade200,
                                  Colors.pink.shade200,
                                ],
                                customTextStyles: const [
                                  TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                  TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  )
                                ],
                                initialLabelIndex: gender_index,
                                cornerRadius: 10.0,
                                activeFgColor: Colors.black,
                                inactiveBgColor: Colors.white,
                                inactiveFgColor: Colors.black,
                                totalSwitches: 2,
                                labels: const ['Male', 'Female'],
                                activeBgColors: [
                                  [Colors.blue.shade200],
                                  [Colors.pink.shade200],
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
                                  if (genderController.text !=
                                      userData['gender']) {
                                    editing(true);
                                  } else {
                                    editing(false);
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
                      onChanged: (value) {
                        if (phoneController.text.trim() !=
                            userData['phone number']) {
                          editing(true);
                        } else {
                          editing(false);
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
                                          // switch ((document.data()
                                          //     as Map)['Type']) {
                                          //   case 'Visually Impaired':
                                          //     blindDB = (document.data()
                                          //         as Map)['Checked'];
                                          //     break;
                                          //   case 'Vocally Impaired':
                                          //     muteDB = (document.data()
                                          //         as Map)['Checked'];
                                          //     break;
                                          //   case 'Hearing Impaired':
                                          //     deafDB = (document.data()
                                          //         as Map)['Checked'];
                                          //     break;
                                          //   case 'Physically Impaired':
                                          //     physicalDB = (document.data()
                                          //         as Map)['Checked'];
                                          //     break;
                                          //   case 'Other':
                                          //     otherDB = (document.data()
                                          //         as Map)['Checked'];
                                          //     break;
                                          // }
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
                                                // setState(() {
                                                blind = newValue!;
                                                // });
                                                print('blind: $blind');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Vocally Impaired') {
                                                // setState(() {
                                                mute = newValue!;
                                                // });
                                                print('mute: $mute');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Hearing Impaired') {
                                                // setState(() {
                                                deaf = newValue!;
                                                // });
                                                print('deaf: $deaf');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Physically Impaired') {
                                                // setState(() {
                                                physical = newValue!;
                                                // });
                                                print('physical: $physical');
                                              }
                                              if ((document.data()
                                                      as Map)['Type'] ==
                                                  'Other') {
                                                // setState(() {
                                                other = newValue!;
                                                // });
                                                print('other: $other');
                                              }
                                              print('physical: $physicalDB');
                                              print('deaf: $deafDB');

                                              print('other: $otherDB');
                                              print('mute: $muteDB');
                                              print('blind: $blindDB');

                                              if (blindDB == blind &&
                                                  otherDB == other &&
                                                  physical == physicalDB &&
                                                  deafDB == deaf &&
                                                  muteDB == mute) {
                                                editing(false);
                                              } else {
                                                editing(true);
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
                          onChanged: (value) {
                            if (bioController.text != userData['bio']) {
                              editing(true);
                            } else {
                              editing(false);
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                (value.trim()).isEmpty) {
                              return "Please enter a bio";
                            }
                          },
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
                              width: MediaQuery.of(context).size.width * 0.35,
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
                                  isEditingfun();
                                  FocusScope.of(context).unfocus();
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              width: MediaQuery.of(context).size.width * 0.35,
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
                                      content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              "Are You Sure You want to delete your account?",
                                              textAlign: TextAlign.left,
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "\n*This action can't be undone",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  textAlign: TextAlign.left,
                                                ))
                                          ]),
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

                                            /*SNU request*/ await FirebaseFirestore
                                                .instance
                                                .collection('requests')
                                                .get()
                                                .then((snapshot) async {
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
                                                await FirebaseFirestore.instance
                                                    .collection('requests')
                                                    .doc(ds['docId'])
                                                    .collection('chats')
                                                    .get()
                                                    .then((snapshot) {
                                                  for (DocumentSnapshot ds
                                                      in snapshot.docs) {
                                                    ds.reference.delete();
                                                  }
                                                });

                                                ds.reference.delete().then((_) {
                                                  print("snu request deleted");
                                                });
                                              }
                                            });
                                            /*Volunteer request*/ await FirebaseFirestore
                                                .instance
                                                .collection('requests')
                                                .get()
                                                .then((snapshot) async {
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
                                                await FirebaseFirestore.instance
                                                    .collection('requests')
                                                    .doc(ds['docId'])
                                                    .collection('chats')
                                                    .get()
                                                    .then((snapshot) {
                                                  List<DocumentSnapshot>
                                                      allDocs = snapshot.docs;
                                                  List<DocumentSnapshot>
                                                      filteredDocs = allDocs
                                                          .where((document) =>
                                                              (document.data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                  'text'] !=
                                                              'This chat offers Text to Speech service, please long press on the chat to try it.')
                                                          .toList();
                                                  for (DocumentSnapshot ds
                                                      in filteredDocs) {
                                                    ds.reference
                                                        .delete()
                                                        .then((_) {
                                                      print("chat deleted");
                                                    });
                                                  }
                                                });
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

                                            await FirebaseFirestore.instance
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

                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(userData['id'])
                                                .collection(
                                                    "UserDisabilityType")
                                                .get()
                                                .then((snapshot) {
                                              for (DocumentSnapshot ds
                                                  in snapshot.docs) {
                                                ds.reference.delete();
                                              }
                                            });

                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(userData['id'])
                                                .delete()
                                                .then((_) {
                                              print("success!, user deleted");
                                            });
                                            FirebaseAuth.instance.currentUser!
                                                .delete()
                                                .then((value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Your account has been deleted successfully.'),
                                              ));
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
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 5.0)
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.0, 1.0],
                                  colors: [
                                    isEdited ? Colors.blue : Colors.grey,
                                    isEdited ? Color(0xFF39d6ce) : Colors.grey,
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
                                  if (isEdited) {
                                    if (blind == false &&
                                        mute == false &&
                                        deaf == false &&
                                        other == false &&
                                        physical == false &&
                                        userData['Type'] != "Volunteer") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please choose a disability'),
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
                                                              255,
                                                              194,
                                                              98,
                                                              98))),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  UpdateDB();
                                                  isEdited = false;
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
                                  } else {}
                                },
                                child: const Text('Save'),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            // Cancel changes
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.35,
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
                                  if (isEdited) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Are You Sure?"),
                                        content: const Text(
                                          "Are You Sure You want to cancel your changes?",
                                          textAlign: TextAlign.left,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
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
                                              // await FirebaseFirestore.instance
                                              //     .collection('users')
                                              //     .doc(widget.user['id'])
                                              //     .collection('UserDisabilityType')
                                              //     .doc('Hearing Impaired')
                                              //     .update({
                                              //   'Checked': deafDB,
                                              // });
                                              // await FirebaseFirestore.instance
                                              //     .collection('users')
                                              //     .doc(widget.user['id'])
                                              //     .collection('UserDisabilityType')
                                              //     .doc('Physically Impaired')
                                              //     .update({
                                              //   'Checked': physicalDB,
                                              // });
                                              // await FirebaseFirestore.instance
                                              //     .collection('users')
                                              //     .doc(widget.user['id'])
                                              //     .collection('UserDisabilityType')
                                              //     .doc('Vocally Impaired')
                                              //     .update({
                                              //   'Checked': muteDB,
                                              // });
                                              // await FirebaseFirestore.instance
                                              //     .collection('users')
                                              //     .doc(widget.user['id'])
                                              //     .collection('UserDisabilityType').doc('Other').update({
                                              //   'Checked': otherDB,
                                              // });
                                              // await FirebaseFirestore.instance
                                              //     .collection('users')
                                              //     .doc(widget.user['id'])
                                              //     .collection('UserDisabilityType')
                                              //     .doc('Visually Impaired')
                                              //     .update({
                                              //   'Checked': blindDB,
                                              // });
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
                                  } else {
                                    setState(() {
                                      isEditing = false;
                                      userData = widget.user;
                                      getPassword = false;
                                      nameController.text = userData['name'];
                                      emailController.text = userData['Email'];
                                      genderController.text =
                                          userData['gender'];
                                      phoneController.text =
                                          userData['phone number'];
                                      bioController.text = userData['bio'];
                                      dateController.text = userData['DOB'];
                                      disabilityController.text =
                                          userData['Disability'];
                                      invalidEmail = false;
                                      passwordController.text = '';
                                    });
                                  }
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
    await setBool();
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
    print(Dis_edit);

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
      passwordController.text = '';
      await Edit_info.update({
        'name': nameController.text,
        'gender': genderController.text,
        'phone number': phoneController.text,
        'Email': emailController.text,
        'bio': bioController.text,
        'DOB': dateController.text,
        'Disability': disabilityController.text
      });

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
  }
}
