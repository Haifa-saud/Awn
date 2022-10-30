// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

class search extends StatefulWidget {
  const search({Key? key}) : super(key: key);

  @override
  searchState createState() => searchState();
}

class searchState extends State<search> {
  TextEditingController _searchController = TextEditingController();
  var list;
  void initState() {
    super.initState();
    list = FirebaseFirestore.instance.collection('posts').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pushNamed(context, '/homePage');
            },
          ),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 2),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (_searchController.text.trim() != '') {
                        setState(() {});
                      } else {
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                  ),
                ),
              ]),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: list,
              builder: (context, snapshots) {
                return (snapshots.connectionState == ConnectionState.waiting)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;

                          if (_searchController.text.isEmpty) {
                            return ListTile(
                              title: Text(
                                data['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                data['category'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              // leading: CircleAvatar(
                              //   backgroundImage: NetworkImage(data['image']),
                              // ),
                            );
                          }
                          if (data['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase())) {
                            return ListTile(
                              title: Text(
                                data['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                data['category'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              // leading: CircleAvatar(
                              //   backgroundImage: NetworkImage(data['image']),
                              // ),
                            );
                          }
                          return Container();
                        });
              },
            ))
          ],
        ));
  }
}
