import 'package:awn/addPost.dart';
import 'package:awn/addRequest.dart';
import 'package:awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file.dart';
import 'firebase_options.dart';
import 'package:awn/map.dart';
import 'package:path/path.dart' as Path;

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homepage> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      routes: {
        '/homePage': (context) => MyHomePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfcfffe),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Color(0xFF39d6ce), // Colors.transparent,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headline6: TextStyle(
              fontSize: 22.0, color: Colors.black), //header at the app bar
          bodyText2: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold), //the body text
          subtitle1: TextStyle(fontSize: 19.0), //the text field label
          subtitle2: TextStyle(fontSize: 120.0), //the text field

          button: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.underline), //the button text
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          contentPadding: EdgeInsets.fromLTRB(20, 12, 20, 12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.red, width: 2.0)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: BorderSide(color: Colors.red, width: 2.0)),
          floatingLabelStyle: TextStyle(fontSize: 22, color: Colors.blue),
          helperStyle: TextStyle(fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              // textStyle: TextStyle(fontSize: 15),
              backgroundColor: Colors.transparent, // background (button) color
              foregroundColor: Color(0xFFfcfffe),
              shadowColor: Colors.transparent,
              padding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF39d6ce),
          actionTextColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 1,
          contentTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  static const categoryModels = [
    SpendingCategoryModel(
      'GROCERIES',
      // 'assets/image1.png',
      28,
      AppColors.categoryColor1,
    ),
    SpendingCategoryModel(
      'FOOD',
      // 'assets/image2.png',
      28,
      AppColors.categoryColor2,
    ),
    SpendingCategoryModel(
      'BEAUTY',
      // 'assets/image3.png',
      28,
      AppColors.categoryColor3,
    ),
  ];
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
      body:
          //  ListView(
          //   children: <Widget>[
          //     Container(
          //       padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
          //       child: ElevatedButton(
          //         onPressed: () {},
          //         child: Text('Add Post'),
          //       ),
          //     ),
          //   ],
          // ),
          Expanded(
        child: ListView(children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              child: Icon(
                Icons.arrow_back_ios_new,
              ),
              onTap: () {
                //action code when clicked
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
          for (var model in categoryModels)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16),
              child: Container(
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
                                blurRadius: 32,
                                color: Colors.black45,
                                spreadRadius: -8)
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
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Text(
                        'data.label',
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
              ),
            )
        ]),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => addFile()),
      //     );
      //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //       content: Text('Add Post'),
      //       action: SnackBarAction(
      //         label: 'Dismiss',
      //         disabledTextColor: Colors.white,
      //         textColor: Colors.yellow,
      //         onPressed: () {
      //           //Do whatever you want
      //         },
      //       ),
      //     ));
      //   },
      //   tooltip: 'Add Post',
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF39d6ce),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addFile()),
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
