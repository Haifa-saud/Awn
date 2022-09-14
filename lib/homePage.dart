import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/postList.dart';
import 'package:awn/viewRequests.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file.dart';
import 'firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  MyHomePage createState() => MyHomePage();
}

class MyHomePage extends State<homePage> {
  // MyHomePage({super.key});
  final Stream<QuerySnapshot> posts = FirebaseFirestore.instance
      .collection('posts')
      .orderBy("category")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    Future<void> _onItemTapped(int index) async {
      if (index == 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addPost()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addRequest()),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => viewRequests()),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const SizedBox(
          width: 700,
          child: Text('Awn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(70),
          ),
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
                        stream: posts,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            print('line 48');
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('line 51');
                            return CircularProgressIndicator();
                          }
                          if (!snapshot.hasData) {
                            return Text('No available posts');
                          } else {
                            final data = snapshot.requireData;
                            print('line 55');
                            return ListView.builder(
                              itemCount: data.size,
                              itemBuilder: (context, index) {
                                bool phone =
                                    data.docs[index]['Phone number'] == ''
                                        ? false
                                        : true;
                                bool website = data.docs[index]['Website'] == ''
                                    ? false
                                    : true;
                                bool description =
                                    data.docs[index]['description'] == ''
                                        ? false
                                        : true;
                                bool loc = data.docs[index]['latitude'] == ''
                                    ? false
                                    : true;
                                bool img = data.docs[index]['img'] == ''
                                    ? false
                                    : true;
                                // Icon icon = data.docs[index]['img'] == '' ? Icon(Icons.navigate_before,
                                //     color: Colors.white);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36.0, vertical: 16),
                                  child: Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 600,
                                          margin: EdgeInsets.only(top: 12),
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 32,
                                                    color: Colors.black45,
                                                    spreadRadius: -8)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                child: Text(
                                                    '${data.docs[index]['name']}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    1, 0, 4, 4),
                                                child: Text(
                                                    '${data.docs[index]['category']}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Image.network(
                                                  data.docs[index]['img'],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return const Text(
                                                        'Image couldnt load');
                                                  },
                                                ),
                                              ),
                                              Visibility(
                                                visible: website ||
                                                    phone ||
                                                    description,
                                                child: ExpansionTile(
                                                  title: Text(
                                                    'View more',
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  children: [
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: phone,
                                                        child: Text(
                                                          '${data.docs[index]['Phone number']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: website,
                                                        child: Text(
                                                          '${data.docs[index]['Website']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    //description
                                                    SizedBox(
                                                      width: 450,
                                                      child: Visibility(
                                                        visible: website,
                                                        child: Text(
                                                          '${data.docs[index]['description']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    158,
                                                                    0,
                                                                    0,
                                                                    0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: phone,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .blue,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            17,
                                                                            16,
                                                                            17,
                                                                            16),
                                                                    textStyle:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        width:
                                                                            1)),
                                                            child: Text(
                                                                'Add Image'),
                                                            onPressed: () {
                                                              double latitude =
                                                                  double.parse(data
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'latitude']);
                                                              double longitude =
                                                                  double.parse(data
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'longitude']);
                                                              (Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => MapsPage(
                                                                        latitude:
                                                                            latitude,
                                                                        longitude:
                                                                            longitude),
                                                                  )));
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      )))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF39d6ce),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Postlist()),
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Add Post'),
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.yellow,
              onPressed: () {
                //Do whatever you want
              },
            ),
          ));
        },
        tooltip: 'Increment',
        elevation: 4.0,
        child: PopupMenuButton<int>(
          offset: Offset(0, -170),
          itemBuilder: (context) => const [
            PopupMenuItem<int>(
                value: 0,
                child: Text(
                  'Item 0',
                )),
            PopupMenuItem<int>(
                value: 1,
                child: Text(
                  'Item 1',
                )),
            PopupMenuItem<int>(
                value: 2,
                child: Text(
                  'Item 2',
                )),
          ],
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            //index 0
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text("Add Post"),
            activeIcon: Text("Add Post"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("Awn Request"),
            activeIcon: Text("Add Request"),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Text("View Awn Request"),
            activeIcon: Text("View Add Request"),
            label: '',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _selectedIndex = 0;
}

class SpendingCategoryModel {
  final String label;
  final int price;
  final Color color;

  const SpendingCategoryModel(this.label, this.price, this.color);
}

abstract class AppColors {
  static const headerTextColor = Color(0xFF466994);
  static const secondaryAccent = Color(0xFF3b67b5);
  static const primaryWhiteColor = Color(0xFFF7F7F7);
  static const categoryColor1 = Color(0xFFffd084);
  static const categoryColor2 = Color(0xFFb2f0fb);
  static const categoryColor3 = Color(0xFFfddddc);

  static const darkModeBackground = Color(0xFF0f153a);
  static const darkModeCardColor = Color(0xFF1b1a4a);
  static const darkModeCategoryColor = Color(0xFF7f6446);
}

// import 'package:flutter/material.dart';
// import 'package:app_colors.dart';
// import 'package:spending_category_model.dart';
// import 'package:minimal_grocery/widgets/custom_icon_button.dart';
// import 'package:minimal_grocery/widgets/price_text.dart';

class SpendingCategory extends StatelessWidget {
  final SpendingCategoryModel data;

  SpendingCategory(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Stack(
        children: [
          Container(
            height: 100,
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.white
                    : AppColors.darkModeCardColor,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 32, color: Colors.black45, spreadRadius: -8)
                ],
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [
                  // CustomIconButton(icon: Icons.file_upload),
                  SizedBox(width: 8),
                  // CustomIconButton(icon: Icons.folder)
                ])
              ],
            ),
          ),
          Container(
            width: 132,
            height: 24,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 16),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Text(
              data.label,
              style: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.white
                      : AppColors.darkModeCategoryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
