import 'package:awn/services/firebase_storage_services.dart';
import 'package:awn/services/sendNotification.dart';
import 'package:awn/viewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mapsPage.dart';

class place extends StatefulWidget {
  final placeID;
  const place({required this.placeID, super.key});

  @override
  _place createState() => _place();
}

class _place extends State<place> with TickerProviderStateMixin {
  Future<String> getLocationAsString(var lat, var lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    return '${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
  }

  var data, latitude, longitude, isLocSet;
  Future<Map<String, dynamic>> getPlaceData(var id) =>
      FirebaseFirestore.instance.collection('posts').doc(id).get().then(
        (DocumentSnapshot doc) {
          data = doc.data() as Map<String, dynamic>;
          return doc.data() as Map<String, dynamic>;
        },
      );

  late final NotificationService notificationService;
  @override
  void initState() {
    data = getPlaceData(widget.placeID);

    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewRequests(userType: 'Volunteer', reqID: payload)));
      });
  final Storage storage = Storage();
  Future<void> _launchUrl(var _url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getPlaceData(widget.placeID),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data as Map<String, dynamic>;
            latitude = data['latitude'];
            longitude = data['longitude'];
            isLocSet = latitude == '' ? false : true;
            return Scaffold(
                body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  toolbarHeight: 50,
                  leading:
                      const Icon(Icons.navigate_before, color: Colors.black),
                  bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(20),
                      child: Container(
                          child: Text(data['name'],
                              // textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25)),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.0),
                              topRight: Radius.circular(40.0),
                            ),
                          ),
                          width: double.maxFinite,
                          padding: const EdgeInsets.fromLTRB(25, 25, 0, 10))),
                  // backgroundColor: Colors.transparent,
                  pinned: true,
                  expandedHeight: 300,
                  flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                    data['img'],
                    // height: 400,
                    width: double.infinity, //MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )),
                ),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                        child: Column(children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: isLocSet,
                              child: FutureBuilder(
                                  future: getLocationAsString(
                                      double.parse(latitude),
                                      double.parse(longitude)),
                                  builder: (context, snap) {
                                    if (snap.hasData) {
                                      var reqLoc = snap.data;
                                      return Row(
                                        children: [
                                          Icon(Icons.location_pin,
                                              size: 20,
                                              color: Colors.blue.shade200),
                                          ElevatedButton(
                                              onPressed: () {
                                                (Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MapsPage(
                                                              latitude:
                                                                  double.parse(
                                                                      latitude),
                                                              longitude:
                                                                  double.parse(
                                                                      longitude)),
                                                    )));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.grey.shade500,
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                              ),
                                              child: Container(
                                                  width: 350,
                                                  child: Text(reqLoc!,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Colors
                                                              .grey.shade500))))
                                        ],
                                      );
                                    } else {
                                      return const Text('');
                                    }
                                  })),
                          const SizedBox(height: 15),
                          Visibility(
                              visible: data['description'] != '',
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Details:'),
                                      const SizedBox(height: 7),
                                      ReadMoreText(
                                        data['description'],
                                        style: const TextStyle(
                                            wordSpacing: 2,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                        trimLines: 4,
                                        trimMode: TrimMode.Line,
                                        trimCollapsedText: 'View more',
                                        trimExpandedText: 'View less',
                                        moreStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline),
                                        lessStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ],
                                  ))),
                          const SizedBox(height: 15),
                          Visibility(
                            visible: data['Website'] != '',
                            child: InkWell(
                                child: new Text(data['Website']),
                                onTap: () => launchUrl(Uri.parse(data[
                                    'Website'])) //final Uri _url = Uri.parse('https://flutter.dev');

                                ),
                          ),
                          Visibility(
                            visible: data['Website'] != '',
                            child: InkWell(
                                child: new Text(data['Phone number']),
                                onTap: () =>
                                    launchUrl(Uri.parse("tel:+966553014247"))),
                          ),
                          const SizedBox(height: 15),
                          const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor sit amet elit eu sagittis. Maecenas at tellus convallis, scelerisque nibh id, condimentum dolor. Nullam in ligula ut felis facilisis pellentesque quis tincidunt elit. Suspendisse potenti. Sed ante urna, mollis id justo ut, mollis imperdiet nunc. Aliquam placerat interdum mauris non tempor. Integer ac diam velit. Vestibulum nec nibh dolor. Morbi ex leo, facilisis quis feugiat eget, gravida non tortor. Phasellus id consequat lacus, sed semper augue. Mauris tortor leo, iaculis gravida metus sed, tristique rutrum est' +
                              'Pellentesque vehicula purus vitae eros scelerisque pretium. Donec in metus placerat nulla mollis scelerisque a et tellus. Aenean quis blandit turpis. Aliquam ultrices nunc ultrices massa rhoncus, sed rutrum tortor hendrerit. Sed pharetra pellentesque lectus, et posuere ex cursus consectetur. In et est faucibus, cursus mauris vel, tincidunt ex. Aenean a odio at enim sodales consectetur gravida euismod orci. Nunc feugiat urna vel sapien vulputate fringilla. Aliquam erat volutpat. Sed posuere a diam in pretium. Nam nec velit at ante ornare pharetra. Vestibulum turpis ipsum, suscipit at euismod at, malesuada in dui. Etiam nec lacus et justo pharetra malesuada eget eu diam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer tincidunt nulla eget purus tincidunt, in euismod augue iaculis. Duis gravida, lectus eget vestibulum suscipit, velit nunc aliquam nibh, et cursus neque velit eu neque.' +
                              'Donec sit amet lacinia sem, ut facilisis dui. Curabitur nulla diam, maximus et lacus vel, convallis lobortis erat. Maecenas suscipit et nibh eu facilisis. Ut egestas, turpis in porta feugiat, neque nibh dignissim nulla, non molestie quam orci eget massa. Ut scelerisque molestie pulvinar. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis dictum elit quis nibh venenatis auctor. Nullam ut lacus in enim pretium fringilla. Nullam molestie convallis massa at dictum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Integer placerat, erat quis volutpat porttitor, mi felis tincidunt dolor, quis vulputate nulla nibh nec libero. Mauris egestas volutpat mauris iaculis lacinia. Nulla sollicitudin, sem vitae lobortis sagittis, augue felis finibus sapien, a semper dolor sem et mi. Mauris faucibus, ex in pellentesque commodo, nisi nulla viverra est, pellentesque finibus libero odio a turpis.' +
                              'Nullam dapibus urna mauris, a rutrum diam mollis nec. Cras eu pellentesque nulla, et commodo enim. Integer ac quam id metus fermentum lobortis eu vel nulla. Morbi et nulla sollicitudin, ultrices urna suscipit, consequat risus. Etiam et sapien sem. Aliquam volutpat vestibulum luctus. Etiam convallis facilisis urna, vel dapibus ligula facilisis vel. Nunc non placerat dolor. Nulla sit amet placerat nibh. Etiam laoreet, sem in imperdiet commodo, enim mi posuere mi, at vestibulum eros magna vitae quam. Cras a felis sed ante placerat rutrum. Etiam efficitur orci ligula, ut scelerisque ante pharetra eget. Vestibulum non turpis tincidunt, porttitor neque at, dignissim risus. Duis et posuere orci, eu dictum nunc.' +
                              'Vivamus dignissim pulvinar neque a tempus. Praesent sodales, ipsum sit amet placerat egestas, sapien leo posuere lacus, non sagittis elit dolor eget ligula. Proin convallis risus mauris, sit amet hendrerit enim suscipit lacinia. Maecenas vitae pellentesque mi. Vivamus lectus arcu, consequat nec mauris in, lacinia lacinia tortor. Mauris porta egestas ligula sed laoreet. Sed finibus ultricies arcu, at lacinia nulla consequat fe'),
                        ]))),
              ],
            ));

            Stack(
              children: [
                AspectRatio(
                    aspectRatio: 1.5,
                    child: Image.network(
                      data['img'],
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    )),
                Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 250, 0, 0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            );
            Scaffold(
              backgroundColor: Colors.lightBlueAccent,
              body: Column(children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                              decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                  data['img'],
                                ),
                                fit: BoxFit.cover),
                          ))),
                      const Text(
                        'Hello',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ]),
            );
          } else {
            return const Text('');
          }
        });
  }
}
