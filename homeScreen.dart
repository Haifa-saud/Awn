import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_9/mapScreen.dart';

import 'allRequests.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            height: 10,
            width: 10,
            child: ListView(children: [
              ElevatedButton(
                  child: Text('current location'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CurrentLocationScreen()),
                    );
                  }),
              ElevatedButton(
                  child: Text('all requests'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StationsMap()),
                    );
                  })
            ])));
  }
}
