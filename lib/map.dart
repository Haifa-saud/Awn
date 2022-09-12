import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'main.dart';

class maps extends StatefulWidget {
  final String dataId;
  const maps({Key? key, required this.dataId}) : super(key: key);

  @override
  State<maps> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<maps> {
  GoogleMapController? mapController;
  List<Marker> markers = <Marker>[];
  Position position =
      Position.fromMap({'latitude': 24.7136, 'longitude': 46.6753});

  String DBId = '';

  void getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = currentLocation;
    });
  }

  @override
  void initState() {
    getCurrentPosition();
    markers.add(Marker(
      markerId:
          const MarkerId('1'), //have one id for all markers to avoid duplicate
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: 'Institution Location ',
      ),
      icon: BitmapDescriptor.defaultMarker,
      // draggable: true,
    ));

    DBId = widget.dataId;
    super.initState();
  }

  LatLng selectedLoc = LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Institution Location"),
      ),
      body: GoogleMap(
        // onChanged: print('test'),
        // mapToolbarEnabled: true,
        onTap: (tapped) async {
          markers.removeAt(0);
          markers.insert(
              0,
              Marker(
                markerId: MarkerId('1'),
                position: LatLng(tapped.latitude, tapped.longitude),
                infoWindow: const InfoWindow(
                  title: 'Institution Location ',
                ),
                draggable: true,
                icon: BitmapDescriptor.defaultMarker,
              ));
          selectedLoc = LatLng(tapped.latitude, tapped.longitude);
          List<Placemark> placemark = await placemarkFromCoordinates(
              selectedLoc.latitude, selectedLoc.longitude);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(placemark[0].street.toString() +
                  ', ' +
                  placemark[0].subLocality.toString() +
                  '\n' +
                  placemark[0].administrativeArea.toString() +
                  ', ' +
                  placemark[0].country.toString())));
        },
        // List<Placemark> placemarks = await placemarkFromCoordinates(52.2165157, 6.9437819);

        zoomGesturesEnabled: true,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 10.0,
        ),
        markers: Set<Marker>.of(markers),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text("Skip"),
            activeIcon: Text("Skip"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Add Location"),
            activeIcon: Text("Add Location"),
            label: '',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

      // FloatingSearchBar.builder(
      //         pinned: true,
      //         itemCount: 100,
      //         padding: EdgeInsets.only(top: 10.0),
      //         itemBuilder: (BuildContext context, int index) {
      //           return ListTile(
      //             leading: Text(index.toString()),
      //           );
      //         },
      //         leading: CircleAvatar(
      //           child: Text("RD"),
      //         ),
      //         endDrawer: Drawer(
      //           child: Container(),
      //         ),
      //         onChanged: (String value) {},
      //         onTap: () {},
      //         decoration: InputDecoration.collapsed(
      //           hintText: "Search...",
      //         ),
      //       ),
    );
  }

  int _selectedIndex = 0;
  Future<void> _onItemTapped(int index) async {
    if (index == 1) {
      //there will always be a selected location(either the current or the selected by the user)
      final postID = FirebaseFirestore.instance.collection('posts').doc(DBId);
      postID.update({
        'latitude': selectedLoc.latitude,
        'longitude': selectedLoc.longitude
      });
      backToHomePage();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully'),
        ),
      );
    } else if (index == 0) {
      backToHomePage();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully'),
        ),
      );
    }
  }

  void backToHomePage() {
    // Navigator.popUntil(context, ModalRoute.withName('/homePage'));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}
