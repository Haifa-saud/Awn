import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  @override
  const MapsPage({Key? key, required this.latitude, required this.longitude})
      : super(key: key);
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController myController;
  late final NotificationService notificationService;
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    Set<Marker> getMarker() {
      return <Marker>{
        Marker(
            markerId: const MarkerId(''),
            position: LatLng(widget.latitude, widget.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'Special need location'))
      };
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Selected Location'),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GoogleMap(
          markers: getMarker(),
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            myController = controller;
          },
        ));
  }
}
