import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'main.dart';

class maps extends StatefulWidget {
  final String dataId;
  final String typeOfRequest;
  const maps({Key? key, required this.dataId, required this.typeOfRequest})
      : super(key: key);

  @override
  State<maps> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<maps> {
  GoogleMapController? mapController;
  List<Marker> markers = <Marker>[];
  Position position =
      Position.fromMap({'latitude': 24.7136, 'longitude': 46.6753});

  String DBId = '';
  bool addPost = true;
  String collName = '';

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

    addPost = widget.typeOfRequest == 'P' ? true : false;
    if (addPost) {
      collName = 'posts';
    } else {
      collName = 'requests';
    }
    DBId = widget.dataId;
    super.initState();
  }

  LatLng selectedLoc = LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Location"),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (tapped) async {
              markers.removeAt(0);
              markers.insert(
                  0,
                  Marker(
                    markerId: MarkerId('1'),
                    position: LatLng(tapped.latitude, tapped.longitude),
                    infoWindow: const InfoWindow(
                      title: 'Selected Location ',
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
          Positioned(
            bottom: 60,
            right: 40,
            width: 300,
            child: Row(children: [
              Visibility(
                visible: addPost,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                    onPressed: () {
                      backToHomePage();
                    },
                    child: const Text('Skip'),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                  onPressed: () {
                    updateDB();
                    backToHomePage();
                  },
                  child: const Text('Add Location'),
                ),
              ),
            ]),
          ),
        ],
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

  Future<void> updateDB() async {
    final postID = FirebaseFirestore.instance.collection(collName).doc(DBId);
    postID.update(
        {'latitude': selectedLoc.latitude, 'longitude': selectedLoc.longitude});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post added successfully'),
      ),
    );
  }

  void backToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}
