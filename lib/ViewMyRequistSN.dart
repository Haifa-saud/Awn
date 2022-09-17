import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'mapsPage.dart';

class ViewMyRequistSN extends StatefulWidget {
  @override
  const ViewMyRequistSN({Key? key}) : super(key: key);
  State<ViewMyRequistSN> createState() => _ViewMyRequistState();
}

class _ViewMyRequistState extends State<ViewMyRequistSN> {
  final Stream<QuerySnapshot> requests = FirebaseFirestore.instance
      .collection('requests')
      .orderBy("date_ymd")
      .snapshots();
  /*getMarkerData() async {
    FirebaseFirestore.instance.collection('requests').;
  }*/

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Awn Requests'),
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
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
                            return Text('Something went wring');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading');
                          }
                          final data = snapshot.requireData;
                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              return Card(
                                  child: Column(
                                children: [
                                  //title
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 20, 15),
                                    child: Text(
                                      ' ${data.docs[index]['title']}',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  //date and time
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 20, color: Colors.red),
                                        Text(' ${data.docs[index]['date_dmy']}',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                        Padding(
                                          padding: EdgeInsets.only(left: 40),
                                          child: Row(
                                            children: [
                                              Icon(Icons.schedule,
                                                  size: 20, color: Colors.red),
                                              Text(
                                                  ' ${data.docs[index]['time']}',
                                                  style: TextStyle(
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
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 12),
                                    child: Row(
                                      children: [
                                        // Icon(Icons.schedule,
                                        //     size: 20, color: Colors.red),
                                        Text(
                                            'Duration: ${data.docs[index]['duration']}',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  //description
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                                    child: Row(
                                      children: [
                                        // Icon(Icons.description,
                                        //     size: 20, color: Colors.red),
                                        Flexible(
                                          child: Text(
                                              'Description: ${data.docs[index]['description']}',
                                              //   overflow:
                                              //   TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //location
                                  Padding(
                                      padding: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            // String dataId =
                                            //  docReference.id;
                                            double latitude = double.parse(
                                                data.docs[index]['latitude']);
                                            double longitude = double.parse(
                                                data.docs[index]['longitude']);

                                            (Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MapsPage(
                                                          latitude: latitude,
                                                          longitude: longitude),
                                                )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.grey.shade500,
                                              backgroundColor: Colors.white,
                                              padding: EdgeInsets.fromLTRB(
                                                  14, 20, 14, 20),
                                              side: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 2)),
                                          child: Text('Location',
                                              style: TextStyle(
                                                  color: Colors.black)))),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 18, 12),
                                    child: Row(
                                      children: [
                                        Text('Status: ',
                                            //   overflow:
                                            //   TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                              '${data.docs[index]['status']}',
                                              //   overflow:
                                              //   TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  background: Paint()
                                                    ..strokeWidth = 20.0
                                                    ..color = getColor(data
                                                        .docs[index]['status'])
                                                    ..style =
                                                        PaintingStyle.stroke
                                                    ..strokeJoin =
                                                        StrokeJoin.round,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500)),
                                        )
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
    );
  }
}

Color getColor(String stat) {
  if (stat == 'Approved')
    return Colors.green.shade300;
  else if (stat == 'Pending')
    return Colors.orange.shade300;
  else
    return Colors.white;
}
