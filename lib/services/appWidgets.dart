import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/homePage.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../userProfile.dart';
import 'package:justino_icons/justino_icons.dart';

//! Bottom Navigation Bar
class BottomNavBar extends StatelessWidget {
  BottomNavBar({
    Key? key,
    required this.userType,
    required this.onPress,
    required this.currentI,
  }) : super(key: key);
  final Function(int) onPress;
  final int currentI;
  var userType = 'Volunteer';

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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var iconList = userType == 'Volunteer'
        ? <IconData>[
            Icons.home,
            Icons.handshake,
            Icons.person,
          ]
        : <IconData>[
            Icons.home,
            JustinoIcons.getByName('speech') as IconData,
            Icons.handshake,
            Icons.person,
          ];

    Future<void> _onItemTapped(int index) async {
      if (userType == 'Special Need User') {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => homePage(),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  Tts(userType: userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  addRequest(userType: userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  userProfile(userType: userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else if (userType == 'Volunteer') {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => homePage(),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  viewRequests(userType: userType, reqID: ''),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  userProfile(userType: userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    }

    return AnimatedBottomNavigationBar.builder(
      splashColor: Colors.blue,
      backgroundColor: Colors.white,
      splashRadius: 1,
      splashSpeedInMilliseconds: 100,
      tabBuilder: (int index, bool isActive) {
        final color = isActive ? Colors.blue : Colors.grey;
        final size = isActive ? 35.0 : 26.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconList[index],
              size: size,
              color: color,
            ),
          ],
        );
      },
      activeIndex: currentI,
      itemCount: userType == 'Volunteer' ? 3 : 4,
      gapLocation: GapLocation.end,
      notchSmoothness: NotchSmoothness.smoothEdge,
      onTap: (index) {
        _onItemTapped(index);
      },
    );
  }
}

// class PlacesList extends StatelessWidget {
//   PlacesList({
//     Key? key,
//     required this.cate,
//   }) : super(key: key);
//   var cate;
//   Stream<QuerySnapshot> list =
//       FirebaseFirestore.instance.collection('posts').snapshots();

//         Future<String> getLocationAsString(var lat, var lng) async {
//     List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
//     return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
//   }

//   @override
//   Widget build(BuildContext context) {
//         TabController _tabController = TabController(length: 6, vsync: this);

//     if (cate != 'All') {
//       list = FirebaseFirestore.instance
//           .collection('posts')
//           .where('category', isEqualTo: 'cate')
//           .snapshots();
//     }
//     return Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                     child: StreamBuilder<QuerySnapshot>(
//                       stream: category.snapshots(),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return const Text("Loading");
//                         } else {
//                           return Column(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   ButtonsTabBar(
//                                     controller: _tabController,
//                                     decoration: const BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                         stops: [0.0, 1.0],
//                                         colors: [
//                                           Colors.blue,
//                                           Color(0xFF39d6ce),
//                                         ],
//                                       ),
//                                     ),
//                                     unselectedDecoration: BoxDecoration(
//                                       color: Colors.white,
//                                       border: Border.all(
//                                           color: Colors.blue, width: 5),
//                                     ),
//                                     radius: 30,
//                                     buttonMargin:
//                                         const EdgeInsets.fromLTRB(6, 4, 6, 4),
//                                     contentPadding: const EdgeInsets.fromLTRB(
//                                         15, 10, 15, 10),
//                                     labelStyle: const TextStyle(
//                                         color: Colors.white, fontSize: 15),
//                                     tabs: snapshot.data!.docs
//                                         .map((DocumentSnapshot document) {
//                                       String cate = ((document.data()
//                                           as Map)['category']);
//                                       return Tab(text: cate);
//                                     }).toList(),
//                                   ),
//                                 ]),
//                             Expanded(
//                                 child: Container(
//                                     width: double.maxFinite,
//                                     height: MediaQuery.of(context).size.height,
//                                     child: TabBarView(
//                                       controller: _tabController,
//                                       children: snapshot.data!.docs
//                                           .map((DocumentSnapshot document) {
//                                         String cate = ((document.data()
//                                             as Map)['category']);
//                                         return placesList(cate);
//                                       }).toList(),
//                                     )))
//                           ]);
//                         }
//                       },
//                     )),
               
    
//     Container(
//         height: double.infinity,
//         child: Column(
//           children: [
//             //! places list
//             Expanded(
//                 child: Container(
//                     height: double.infinity,
//                     child: StreamBuilder<QuerySnapshot>(
//                         stream: list,
//                         builder: (BuildContext context,
//                             AsyncSnapshot<QuerySnapshot> snapshot) {
//                           if (snapshot.hasError) {
//                             return const Text('Something went wrong');
//                           }
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }
//                           if (!snapshot.hasData) {
//                             return const Center(
//                                 child: Text('No available posts'));
//                           }
//                           if (snapshot.data == null ||
//                               snapshot.data!.docs.isEmpty) {
//                             return const Center(
//                                 child: Text('There is no places currently',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.normal,
//                                         fontSize: 17)));
//                           } else {
//                             final data = snapshot.requireData;
//                             return ListView.builder(
//                                 shrinkWrap: true,
//                                 itemCount: data.size,
//                                 itemBuilder: (context, index) {
//                                   if (data.docs[index]['latitude'] != '') {
//                                     double latitude = double.parse(
//                                         '${data.docs[index]['latitude']}');
//                                     double longitude = double.parse(
//                                         '${data.docs[index]['longitude']}');

//                                     return FutureBuilder(
//                                       future: getLocationAsString(
//                                           latitude, longitude),
//                                       builder: (context, snap) {
//                                         if (snap.hasData) {
//                                           var reqLoc = snap.data;

//                                           String category =
//                                               data.docs[index]['category'];
//                                           var icon;

//                                           if (category == 'Education')
//                                             icon = const Icon(Icons.school);
//                                           else if (category == 'Transportation')
//                                             icon = const Icon(
//                                                 Icons.directions_car);
//                                           else
//                                             icon = const Icon(Icons.school);

//                                           return Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 24,
//                                                 right: 24,
//                                                 top: 8,
//                                                 bottom: 16),
//                                             child: InkWell(
//                                               onTap: () => showModalBottomSheet(
//                                                   isScrollControlled: true,
//                                                   backgroundColor:
//                                                       Colors.transparent,
//                                                   context: context,
//                                                   builder: (context) =>
//                                                       buildPlace(
//                                                           data.docs[index]
//                                                               ['docId'])),
//                                               splashColor: Colors.transparent,
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     boxShadow: const [
//                                                       BoxShadow(
//                                                           blurRadius: 32,
//                                                           color: Colors.black45,
//                                                           spreadRadius: -8)
//                                                     ],
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15)),
//                                                 child: Stack(
//                                                   children: <Widget>[
//                                                     Column(
//                                                       children: <Widget>[
//                                                         ClipRRect(
//                                                             borderRadius:
//                                                                 const BorderRadius
//                                                                     .only(
//                                                               topLeft: Radius
//                                                                   .circular(
//                                                                       16.0),
//                                                               topRight: Radius
//                                                                   .circular(
//                                                                       16.0),
//                                                             ),
//                                                             child: AspectRatio(
//                                                               aspectRatio: 2,
//                                                               child:
//                                                                   Image.network(
//                                                                 data.docs[index]
//                                                                     ['img'],
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                                 errorBuilder: (BuildContext
//                                                                         context,
//                                                                     Object
//                                                                         exception,
//                                                                     StackTrace?
//                                                                         stackTrace) {
//                                                                   return const Text(
//                                                                       'Image could not be load');
//                                                                 },
//                                                               ),
//                                                             )),
//                                                         Container(
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: <Widget>[
//                                                               Expanded(
//                                                                 child: Container(
//                                                                     child: Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                               .fromLTRB(
//                                                                           13,
//                                                                           8,
//                                                                           0,
//                                                                           8),
//                                                                   child: Text(
//                                                                     data.docs[
//                                                                             index]
//                                                                         [
//                                                                         'name'],
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .left,
//                                                                     style:
//                                                                         const TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600,
//                                                                       fontSize:
//                                                                           20,
//                                                                     ),
//                                                                   ),
//                                                                 )),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Row(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .center,
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .start,
//                                                           children: <Widget>[
//                                                             Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .fromLTRB(
//                                                                         13,
//                                                                         0,
//                                                                         0,
//                                                                         15),
//                                                                 child: Text(
//                                                                   data.docs[
//                                                                           index]
//                                                                       [
//                                                                       'category'],
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           14,
//                                                                       color: Colors
//                                                                           .grey
//                                                                           .withOpacity(
//                                                                               0.8)),
//                                                                 )),
//                                                             const SizedBox(
//                                                               width: 4,
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         } else {
//                                           return const Center(child: Text(''));
//                                         }
//                                       },
//                                     );
//                                   } else {
//                                     return const Center(child: Text(''));
//                                   }
//                                 });
//                           }
//                         })))
//           ],
//         ));
//   }
// }
