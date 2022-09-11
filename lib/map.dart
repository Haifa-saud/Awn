import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class maps extends StatefulWidget {
  const maps({Key? key, required String dataId}) : super(key: key);

  @override
  State<maps> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<maps> {
  GoogleMapController? mapController;
  List<Marker> markers = <Marker>[];
  Position? position;

  String dataId = '';

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

  @override
  void initState() {
    markers.add(Marker(
      markerId:
          const MarkerId('1'), //have one id for all markers to avoid duplicate
      position: position == null
          ? LatLng(position!.latitude, position!.longitude)
          : _center,
      infoWindow: const InfoWindow(
        title: 'Institution Location ',
      ),
      icon: BitmapDescriptor.defaultMarker,
      draggable: true, //Icon for Marker
    ));

    super.initState();
    getCurrentPosition();
  }

  LatLng? selectedLoc = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Institution Location"),
      ),
      body: GoogleMap(
        onTap: (tapped) async {
          // if (selectedLoc != null) {
          //   Marker marker = markers.firstWhere(
          //       (marker) => marker.markerId.value == selectedLoc,
          //       orElse: () => null);
          //   setState(() {
          //     markers.remove(marker);
          //   });
          // }
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
      // try {
      if (selectedLoc != position) {
        Navigator.pop(context, selectedLoc);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set a location.')),
        );
      }
      // } catch (Exception) {
      //   print('null var');
      // }
    } else if (index == 0) {
      Navigator.pop(context);
    } else {}
  }
}
