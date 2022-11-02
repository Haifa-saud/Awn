import 'package:Awn/requestWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationsMap1 extends StatefulWidget {
  @override
  _StationsMap1 createState() => _StationsMap1();
}

class _StationsMap1 extends State<StationsMap1> {
  bool mapToggle = false;

  var currentLocation;
  var currentLocation1;
  bool isEnabled = false;

  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    // getMarkerData();
    super.initState();
    _determinePosition();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });
  }

  List<Marker> allMarkers = [];
  Text info = const Text(
    'View This Request',
    style: TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blue,
    ),
  );
  Widget loadMap(type) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            allMarkers.add(Marker(
                markerId: MarkerId(snapshot.data!.docs[i].id),
                position: LatLng(
                    double.parse(snapshot.data!.docs[i]['latitude']),
                    double.parse(snapshot.data!.docs[i]['longitude'])),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: info.data,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => requestPage(
                              reqID: snapshot.data!.docs[i]['docId'],
                              userType: type))),
                )));
          }

          return isEnabled
              ? Stack(children: [
                  GoogleMap(
                    onMapCreated: onMapCreated,
                    myLocationEnabled: true,

                    // initialCameraPosition: CameraPosition(
                    //   target: LatLng(24.72595440733058, 46.62468224955453),
                    //   zoom: 10.0,
                    // ),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          currentLocation.latitude, currentLocation.longitude),
                      zoom: 10.0,
                    ),

                    markers: Set<Marker>.of(allMarkers),
                  ),
                ]
                  //floatingActionButton: floatingActionButton(),
                  )
              : const CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //     home: Scaffold(
        //   body: isEnabled ? loadMap() : CircularProgressIndicator(),
        //   floatingActionButton: floatingActionButton(),

        // )
        home: loadMap('Volunteer'));
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  Widget floatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                // target: LatLng(position.latitude, position.longitude),
                target:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 14)));

        //markers.clear();

        // allMarkers.add(Marker(
        //     markerId: const MarkerId('currentLocation'),
        //     position:
        //         LatLng(currentLocation.latitude, currentLocation.longitude),
        //     icon: BitmapDescriptor.defaultMarkerWithHue(
        //         BitmapDescriptor.hueRed),
        //     infoWindow: const InfoWindow(title: 'Current Location')));

        setState(() {});
      },
      label: const Text("Current Location"),
      icon: const Icon(Icons.location_history),
    );
  }

  void _determinePosition() async {
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
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    var position = await Geolocator.getCurrentPosition();

    currentLocation = position;
    setState(() {
      isEnabled = true;
    });

    //return position;
  }
}
