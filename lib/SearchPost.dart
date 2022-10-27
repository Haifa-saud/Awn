import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PastTripsView extends StatefulWidget {
  @override
  _PastTripsViewState createState() => _PastTripsViewState();
}

class _PastTripsViewState extends State<PastTripsView> {
  TextEditingController _searchController = TextEditingController();

  late Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //resultsLoaded = getPostsStreamSnapshots();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchController.text.trim() != "") {
      // if search has text
      for (var tripSnapshot in _allResults) {
        //var title = Trip.fromSnapshot(tripSnapshot).title.toLowerCase();
        // if (title.contains(_searchController.text.toLowerCase())) {
        //   showResults.add(tripSnapshot);
        // }
      }
    } else {
      // if search does not have text
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  // getPostsStreamSnapshots() async {
  //   //why ??
  //   var data = (await FirebaseFirestore.instance
  //       .collection('Posts')
  //       .where("title", isLessThanOrEqualTo: DateTime.now())
  //       .orderBy('endDate')
  //       .snapshots());

  //   setState(() {
  //     _allResults = data;
  //   });

  //   searchResultsList();
  //   return "complete";
  // }

  var PlacesPost = FirebaseFirestore.instance.collection("Posts");

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Places Posts", style: TextStyle(fontSize: 20)),
          Padding(
            padding:
                const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            ),
          ),
          //Testing
          StreamBuilder<dynamic>(
              // stream:
              //     PlacesPost.where("title", isLessThanOrEqualTo: DateTime.now())
              //         .orderBy('endDate')
              //         .snapshots(),
              stream: (_searchController != "" && _searchController != null)
                  ? PlacesPost.where("name", arrayContains: _searchController)
                      .snapshots()
                  : PlacesPost.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("No Places");
                } else {
                  final Place_Data = snapshot.data;
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: Place_Data.size,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                            child: Stack(children: [
                              Container(
                                width: 600,
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 32,
                                          color: Colors.black45,
                                          spreadRadius: -8)
                                    ],
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      /*name*/ Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 10, 15, 10),
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              Place_Data.docs[index]['name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16),
                                              textAlign: TextAlign.left,
                                            )),
                                      ),
                                      /*cate*/ Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 5, 6, 5),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                              Place_Data.docs[index]
                                                  ['category'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17)),
                                        ),
                                      ),
                                    ]),
                              )
                            ]));
                      });
                }
              }),

          //Testing
          // Expanded(
          //     child: ListView.builder(
          //   itemCount: _resultsList.length,
          //   itemBuilder: (BuildContext context, int index) =>
          //       PlaceWidget(context, _resultsList[index]),
          // )),
        ],
      ),
    );
  }
}
