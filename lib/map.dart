import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class maps extends StatefulWidget {
  const maps({Key? key}) : super(key: key);

  @override
  State<maps> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<maps> {
  GoogleMapController? mapController;
  List<Marker> markers = <Marker>[];
  late Position position;

  LatLng _center = const LatLng(24.7136, 46.6753);
  Position? currentLocation;

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

  // void getMarkers(double lat, double long) {
  //   MarkerId markerId = MarkerId(lat.toString() + long.toString());
  //   Marker _marker = Marker(
  //       markerId: markerId,
  //       position: LatLng(lat, long),
  //       icon: BitmapDescriptor.defaultMarker,
  //       infoWindow: InfoWindow(
  //         snippet: 'Address',
  //         title: 'Institution Location ',
  //       ));
  //   setState(() {
  //     markers[markerId] = _marker;
  //   });
  // }

  @override
  void initState() {
    // markers.add(Marker(
    //   //add marker on google map
    //   markerId: MarkerId(_center.toString()),
    //   position: _center, //position of marker
    //   infoWindow: const InfoWindow(
    //     //popup info
    //     title: 'Institution Location ',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    // ));

    //you can add more markers here
    super.initState();
    getCurrentPosition();
  }

  LatLng? selectedLoc = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map in Flutter"),
      ),
      body: GoogleMap(
        onTap: (tapped) async {
          // markers.clear();
          markers.add(Marker(
            markerId: MarkerId(
                tapped.latitude.toString() + tapped.longitude.toString()),
            position: LatLng(tapped.latitude, tapped.longitude),
            infoWindow: const InfoWindow(
              title: 'Institution Location ',
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));
          selectedLoc = LatLng(tapped.latitude, tapped.longitude);
        },
        zoomGesturesEnabled: true,
        // markers: markers,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 10.0,
        ),
        markers: Set<Marker>.of(markers),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text("Cancel"),
            activeIcon: Text("Cancel"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Add Post"),
            activeIcon: Text("Add Post"),
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
      // try {
      Navigator.pop(context, selectedLoc);
      // } catch (Exception) {
      //   print('null var');
      // }
    } else if (index == 0) {
      // backToHomePage();
    } else {}
  }
}
