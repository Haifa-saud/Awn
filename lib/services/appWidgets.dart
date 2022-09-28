import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awn/TextToSpeech.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/homePage.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/material.dart';
import '../userProfile.dart';

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
  final userType;

  final iconList = <IconData>[
    Icons.home,
    Icons.volume_up,
    Icons.handshake,
    Icons.person,
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Future<void> _onItemTapped(int index) async {
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => homePage(userType: userType)),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Tts(userType: userType)),
        );
      } else if (index == 2) {
        if (userType == 'Special Need User') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => addRequest(userType: userType)),
          );
        } else if (userType == 'Volunteer') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: userType, reqID: '')),
          );
        }
      } else if (index == 3) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => userProfile(userType: userType)));
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
      itemCount: 4,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.smoothEdge,
      onTap: (index) {
        _onItemTapped(index);
      },
    );
  }
}
// Helllooooo !!! , I am here

// class AppBarWidget extends StatelessWidget{

// }