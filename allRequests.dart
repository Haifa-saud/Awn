import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationsMap extends StatefulWidget {
  @override
  _StationsMap createState() => _StationsMap();
}

class _StationsMap extends State<StationsMap> {
  bool mapToggle = false;

  var currentLocation;

  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  getMarkerData() async {
    FirebaseFirestore.instance.collection('requests').get().then((myMarkers) {
      if (myMarkers.docs.isNotEmpty) {
        print('empty');
      } else if (myMarkers.docs.isNotEmpty) {
        for (int i = 0; i < myMarkers.docs.length; i++) {
          initMarker(myMarkers.docs[i].data, myMarkers.docs[i].id);
        }
      }
    });
  }

  void initMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(specify['latitude'], specify['longitude']),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  void initState() {
    getMarkerData();
    super.initState();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height - 80.0,
                width: double.infinity,
                child: mapToggle
                    ? GoogleMap(
                        onMapCreated: onMapCreated,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation.latitude,
                              currentLocation.longitude),
                          zoom: 10.0,
                        ),
                        markers: Set<Marker>.of(markers.values),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ))
          ],
        ),
      ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
