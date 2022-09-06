import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(addPost());
// }

// class addPost extends StatelessWidget {
//   const addPost({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'أضافة منشور',
//       theme: ThemeData(
//         scaffoldBackgroundColor: Color(0xFFecfbfa),
//         appBarTheme: const AppBarTheme(
//           // iconTheme: IconThemeData(color: Colors.black),
//           color: Color(0xFF39d6ce),
//         ),
//         textTheme: TextTheme(headline2: TextStyle(color: Color(0xFF2a3563))),
//       ),
//       home: const MyStatefulWidget(),
//     );
//   }
// }

class addPost extends StatefulWidget {
  const addPost({Key? key}) : super(key: key);

  @override
  State<addPost> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<addPost> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactInfoController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أضافة منشور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15),
              child: const Text(
                'كن عون',
                style: TextStyle(fontSize: 20),
              )),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              textAlign: TextAlign.right,
              controller: contactInfoController,
              decoration: const InputDecoration(
                  labelText: "الاسم", hintText: "مثال: جامعة الملك سعود"),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              textAlign: TextAlign.right,
              controller: contactInfoController,
              decoration: const InputDecoration(
                  labelText: 'الوصف', hintText: "مثال: جامعة الملك سعود"),
            ),
          ),
        ]),
      ),
    );
  }
}

// // class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({Key? key}) : super(key: key);

//   @override
//   // State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController contactInfoController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(10),
//         child: ListView(
//           children: <Widget>[
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'TutorialKart',
//                   style: TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 30),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'كن عون',
//                   style: TextStyle(fontSize: 20),
//                 )),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               child: TextField(
//                 textDirection: TextDirection.rtl,
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'اسم',
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//               child: TextField(
//                 obscureText: true,
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Password',
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 //forgot password screen
//               },
//               child: const Text(
//                 'Forgot Password',
//               ),
//             ),
//             Container(
//                 height: 50,
//                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                 child: ElevatedButton(
//                   child: const Text('Login'),
//                   onPressed: () {
//                     print(nameController.text);
//                     print(passwordController.text);
//                   },
//                 )),
//             Column(
//               children: [
//                 RadioListTile(
//                   title: Text("Male"),
//                   value: "male",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 ),
//                 RadioListTile(
//                   title: Text("Female"),
//                   value: "female",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 ),
//                 RadioListTile(
//                   title: Text("Other"),
//                   value: "other",
//                   groupValue: gender,
//                   onChanged: (value) {
//                     setState(() {
//                       gender = value.toString();
//                     });
//                   },
//                 )
//               ],
//             )
//           ],
//         ));
//   }
// }
