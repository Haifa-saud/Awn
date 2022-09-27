import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// import 'ViewMyRequistSN.dart';
// import 'ViewMyRequistVol.dart';

class viewRequests extends StatefulWidget {
  final reqID;
  const viewRequests([this.reqID = '']);

  @override
  State<viewRequests> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<viewRequests> {
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;

  @override
  void initState() {
    itemScrollController =
        // ScrollController(initialScrollOffset: 50.0)
        //     as ItemScrollController;
        ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();

    print(widget.reqID);
    // while ( == false) {
    //   // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex(notificationIndex));

    super.initState();
    if (widget.reqID != '' && itemScrollController.isAttached) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToIndex(notificationIndex));
    }
  }

  final requestKey = GlobalKey();
  int notificationIndex = -1;

  // This function will be triggered when the user tap notification
  void _scrollToIndex(int index) {
    itemScrollController.scrollTo(
        index: index,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOutCubic);
  }

  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .where('status', isEqualTo: 'Pending')
      .orderBy("date_ymd")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ViewMyRequistSN(),
                  //     ));
                },
                child: const Text("past req special need"),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                    side: BorderSide(color: Colors.grey.shade400, width: 2)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ViewMyRequistVol(),
                  //     ));
                },
                child: const Text("past req volenteer"),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                    side: BorderSide(color: Colors.grey.shade400, width: 2)),
              ),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: requests,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final data = snapshot.requireData;
                          return ScrollablePositionedList.builder(
                            itemCount: data.size,
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            itemBuilder: (context, index) {
                              if (widget.reqID == data.docs[index]['docId']) {
                                notificationIndex = index;
                              }
                              return Card(
                                  key: ValueKey(
                                      index), //ValueKey(data.docs[index]['docId']),
                                  child: Column(
                                    children: [
                                      //title
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 20, 15),
                                        child: Text(
                                          ' ${data.docs[index]['title']}',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      //date and time
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 18, 12),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 20, color: Colors.red),
                                            Text(
                                                ' ${data.docs[index]['date_dmy']}',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 40),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.schedule,
                                                      size: 20,
                                                      color: Colors.red),
                                                  Text(
                                                      ' ${data.docs[index]['time']}',
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //duration
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 12),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.schedule,
                                            //     size: 20, color: Colors.red),
                                            Text(
                                                'Duration: ${data.docs[index]['duration']}',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      //description
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 18, 12),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.description,
                                            //     size: 20, color: Colors.red),
                                            Flexible(
                                              child: Text(
                                                  'Description: ${data.docs[index]['description']}',
                                                  //   overflow:
                                                  //   TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //location
                                      Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                // String dataId =
                                                //  docReference.id;
                                                double latitude = double.parse(
                                                    data.docs[index]
                                                        ['latitude']);
                                                double longitude = double.parse(
                                                    data.docs[index]
                                                        ['longitude']);

                                                (Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MapsPage(
                                                              latitude:
                                                                  latitude,
                                                              longitude:
                                                                  longitude),
                                                    )));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.grey.shade500,
                                                  backgroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          14, 20, 14, 20),
                                                  side: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 2)),
                                              child: const Text('Location',
                                                  style: TextStyle(
                                                      color: Colors.black)))),

                                      //buttons
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        // width: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              width: 100,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  String docId =
                                                      data.docs[index]['docId'];

                                                  updateDB(docId);
                                                  Confirmation();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.green.shade400,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          17, 13, 17, 13),
                                                  textStyle: const TextStyle(
                                                      fontSize: 17),
                                                ),
                                                child: const Text('Accept'),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: ElevatedButton(
                                                  onPressed: () {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.red.shade300,
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        17, 13, 17, 13),
                                                    textStyle: const TextStyle(
                                                        fontSize: 17),
                                                  ),
                                                  child: const Text('Deny')),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ));
                            },
                          );
                        },
                      )))
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _scrollToIndex(4),
          child: const Icon(Icons.arrow_downward)),
    );
  }

  void Confirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Awn request has been accepted"),
      ),
    );
  }
}

Future<void> updateDB(docId) async {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
//String docId=
  final postID = FirebaseFirestore.instance
      // .collection('userData')
      // .doc(userId)
      .collection('requests')
      .doc(docId);

  postID.update({
    'status': 'Approved',
    'VolID': userId,
  });
}

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
          title: const Text('Awn Request Location'),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white),
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
