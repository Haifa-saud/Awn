import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:Awn/TextToSpeech.dart';
import 'package:Awn/addRequest.dart';
import 'package:Awn/homePage.dart';
import 'package:Awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
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
      if (userType == 'Special Need User') {
        if (index == 0) {
          Hive.box("currentPage").put("RequestId", '');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => homePage(),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Hive.box("currentPage").put("RequestId", '');
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
          Hive.box("currentPage").put("RequestId", '');
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
          Hive.box("currentPage").put("RequestId", '');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => userProfile(
                  userType: userType, selectedTab: 0, selectedSubTab: 0),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else if (userType == 'Volunteer') {
        if (index == 0) {
          Hive.box("currentPage").put("RequestId", '');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => homePage(),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Hive.box("currentPage").put("RequestId", '');
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
          Hive.box("currentPage").put("RequestId", '');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => userProfile(
                  userType: userType, selectedTab: 0, selectedSubTab: 0),
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
