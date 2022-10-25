import 'package:Awn/editRequest.dart';
import 'package:Awn/services/newRequestNotification.dart';
import 'package:Awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:workmanager/workmanager.dart';

import 'homePage.dart';
import 'main.dart';

class maps extends StatefulWidget {
  final String dataId;
  final String typeOfRequest;
  final double? latitude;
  final double? longitude;
  const maps(
      {Key? key,
      required this.dataId,
      required this.typeOfRequest,
      this.latitude,
      this.longitude})
      : super(key: key);

  @override
  State<maps> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<maps> {
  GoogleMapController? mapController;
  List<Marker> markers = <Marker>[];
  List<Marker> _markers = <Marker>[];

  Position position =
      Position.fromMap({'latitude': 24.7136, 'longitude': 46.6753});

  String DBId = ' ';
  bool addPost = true;
  bool editRequest = false;
  String collName = ' ', sucessMsg = '', title = '';
  BorderRadius border = BorderRadius.circular(0);

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

    markers.add(Marker(
      markerId: MarkerId(
          position.latitude.toString() + position.longitude.toString()),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: 'Institution Location ',
      ),
      icon: BitmapDescriptor.defaultMarker,
      draggable: true,
    ));
  }

  late final NotificationService notificationService;
  @override
  void initState() {
    if (widget.typeOfRequest == 'E') {
      setState(() {
        position = Position.fromMap(
            {'latitude': widget.latitude, 'longitude': widget.longitude});
        markers.add(Marker(
          markerId: MarkerId(
              position.latitude.toString() + position.longitude.toString()),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(
            title: 'Institution Location ',
          ),
          icon: BitmapDescriptor.defaultMarker,
          draggable: true,
        ));
      });
    } else {
      getCurrentPosition();
    }

    addPost = widget.typeOfRequest == 'P' ? true : false;
    editRequest = widget.typeOfRequest == 'E' ? true : false;
    if (addPost) {
      title = "Add Location";
      collName = 'posts';
      border = const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      );
      sucessMsg = 'Place is added successfully';
    } else if (editRequest) {
      title = "Update Location";
      collName = 'requests';
      border = BorderRadius.circular(30);
      sucessMsg = 'Request location is updated successfully';
    } else {
      title = "Add Location";
      collName = 'requests';
      border = BorderRadius.circular(30);
      sucessMsg = 'Request is sent successfully';
    }
    DBId = widget.dataId;
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print(payload);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });
  LatLng selectedLoc = LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // leading: Visibility(
          //     visible: editRequest,
          //     child: IconButton(
          //         icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          //         onPressed: () => Navigator.of(context).pop())),
          title: Text(title),
          leading: Visibility(
              visible: editRequest,
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop())),
          automaticallyImplyLeading: false),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: markers.toSet(),
            onTap: (tapped) async {
              markers.removeAt(0);
              markers.insert(
                  0,
                  Marker(
                    markerId: MarkerId(tapped.latitude.toString() +
                        tapped.longitude.toString()),
                    position: LatLng(tapped.latitude, tapped.longitude),
                    infoWindow: const InfoWindow(
                      title: 'Selected Location ',
                    ),
                    draggable: true,
                    icon: BitmapDescriptor.defaultMarker,
                  ));
              setState(() {
                _markers = markers;
                print("items ready and set state");
              });

              print(markers);
              selectedLoc = LatLng(tapped.latitude, tapped.longitude);
              List<Placemark> placemark = await placemarkFromCoordinates(
                  selectedLoc.latitude, selectedLoc.longitude);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(placemark[0].street.toString() +
                        ', ' +
                        placemark[0].subLocality.toString() +
                        '\n' +
                        placemark[0].administrativeArea.toString() +
                        ', ' +
                        placemark[0].country.toString()),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      disabledTextColor: Colors.white,
                      textColor: Colors.white,
                      onPressed: () {},
                    )),
              );
            },
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
          ),
          Positioned.fill(
            bottom: 15,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: addPost,
                      child: Container(
                        width: 120,

                        // margin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 5.0)
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 1.0],
                            colors: [
                              Colors.blue,
                              Color(0xFF39d6ce),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            backToHomePage();
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontSize: 18,
                            ),
                            // side: BorderSide.only(
                            //     color: Colors.grey.shade400, width: 1),
                          ),
                          child: const Text('Skip'),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      // margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 5.0)
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          stops: [0.0, 1.0],
                          colors: [
                            Colors.blue,
                            Color(0xFF39d6ce),
                          ],
                        ),
                        // borderRadius: BorderRadius.circular(30),
                        borderRadius: border,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          updateDB();
                          if (editRequest) {
                            backToEditPage();
                          } else
                            backToHomePage();
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        child: Text(title),
                      ),
                    ),
                  ]),
            ),
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
    print(position.latitude.toString() + position.longitude.toString());
    print("Maps Id: $DBId");
    print(DBId);
    print(collName);
    final postID = FirebaseFirestore.instance.collection(collName).doc(DBId);
    print(postID);
    if (collName == "requests") {
      postID.update({
        'latitude': selectedLoc.latitude.toString(),
        'longitude': selectedLoc.longitude.toString(),
        'notificationStatus': 'pending',
      });
    } else if (collName == "posts") {
      postID.update({
        'latitude': selectedLoc.latitude.toString(),
        'longitude': selectedLoc.longitude.toString()
      });
    }
    if (collName == 'requests') {
      var time = DateTime.now().second.toString();
    }
  }

  void backToHomePage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sucessMsg),
      ),
    );
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => homePage(),
        transitionDuration: Duration(seconds: 1),
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void backToEditPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sucessMsg),
      ),
    );
    Navigator.of(context).pop();
  }
}
