import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/homePage.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
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
