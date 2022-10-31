import 'package:Awn/addRequest.dart';
import 'package:Awn/homePage.dart';
import 'package:Awn/map.dart';
import 'package:Awn/services/appWidgets.dart';
import 'package:Awn/services/firebase_storage_services.dart';
import 'package:Awn/services/localNotification.dart';
import 'package:Awn/userProfile.dart';
import 'package:Awn/viewRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'addPost.dart';
import 'login.dart';
import 'services/firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'main.dart';

class editPost extends StatefulWidget {
  final String userType;
  final String name;
  final String number;
  final String description;
  final String website;
  final String category;
  final String docId;
  final String oldImg;
  final String latitude;
  final String longitude;
  const editPost(
      {Key? key,
      required this.userType,
      required this.name,
      required this.number,
      required this.description,
      required this.website,
      required this.category,
      required this.docId,
      required this.oldImg,
      required this.latitude,
      required this.longitude})
      : super(key: key);

  @override
  State<editPost> createState() => _MyStatefulWidgetState();
}

// TextEditingController nameController = TextEditingController();
late TextEditingController nameController;
//late TextEditingController contactInfoController;
late TextEditingController descriptionController;
late TextEditingController numberController;
late TextEditingController websiteController;
late var imagectrl;
var isEdited;
var imgErrorMessage;
var selectedCategory;

var reqLoc = '';

class _MyStatefulWidgetState extends State<editPost> {
  late final NotificationService notificationService;
  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
    numberController = TextEditingController(text: widget.number);
    websiteController = TextEditingController(text: widget.website);
    imagectrl = widget.oldImg;
    isEdited = false;
    imgErrorMessage = false;
    selectedCategory = widget.category;
    // double latitude = double.parse(widget.latitude);
    // double longitude = double.parse(widget.longitude);

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
  final _formKey = GlobalKey<FormState>();

  CollectionReference category =
      FirebaseFirestore.instance.collection('postCategory');

  var selectedCategory2;

  // var editImg = '';
  var editImg = '';
  bool previewImage = false;
  int _selectedIndex = 2;
  final Storage storage = Storage();
  var imagePath, memoryPath;
  var isSedited = false;

  editing(var value) {
    setState(() {
      isEdited = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    late GoogleMapController myController;
    Set<Marker> getMarker(lat, lng) {
      return <Marker>{
        Marker(
            markerId: const MarkerId(''),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(title: 'location'))
      };
    }

    Future<String> getLocationAsString(var lat, var lng) async {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return '${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].administrativeArea}, ${placemark[0].country}';
    }

    //reqLoc = getLocationAsString(widget.latitude, widget.longitude);
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  color: Colors.grey,
                  height: 1.0,
                ))),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: FutureBuilder(
                  future: storage.downloadURL('logo.png'),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Center(
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
                    }
                    return Container();
                  }))
        ],
        title: const Text('Edit Place', textAlign: TextAlign.center),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: ListView(children: <Widget>[
            Container(
                child: Text(
              '*indicates required fields',
              style: TextStyle(fontSize: 15),
            )),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 10),
              child: Text(
                'Institution Details*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            /*name*/ Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                textAlign: TextAlign.left,
                controller: nameController,
                maxLength: 25,
                decoration: const InputDecoration(
                    labelText: "Name", hintText: "E.g. King Saud University"),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      (value.trim()).isEmpty) {
                    return 'Please enter the institution name.';
                  }
                  return null;
                },
              ),
            ),
            /*category*/ Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: StreamBuilder<QuerySnapshot>(
                    stream: category.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("Loading");
                      } else {
                        var newValue;
                        return DropdownButtonFormField(
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              print('newValue');
                              print(newValue);
                              //selectedCategory = newValue;
                              selectedCategory2 = newValue;
                              isSedited = true;
                            });
                          },
                          //  onChanged: (String newValue) {
                          //   setState(() {
                          //     selectedCategory = newValue;
                          //   });
                          // },
                          validator: (value) => value == null
                              ? 'Please select a category.'
                              : null,
                          // hint: const Text('Category'),
                          items: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return DropdownMenuItem<String>(
                              value: ((document.data() as Map)['category']),
                              child: Text((document.data() as Map)['category']),
                            );
                          }).toList(),
                          value: selectedCategory,
                          isExpanded: false,
                        );
                      }
                    })),
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'Institution Image*',
              ),
            ),
            /*image fromdb */
            Visibility(
                visible: !previewImage,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)
                        // topLeft: Radius.circular(16.0),
                        // topRight: Radius.circular(16.0),
                        ),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: Image.network(
                        imagectrl,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Text('Image could not be load');
                        },
                      ),
                    ))),
            /*image changed*/ Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    previewImage
                        ? AspectRatio(
                            aspectRatio: 2,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0, color: Colors.blue.shade50),
                                    ),
                                    child: Image.memory(
                                      memoryPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        print('error');
                                        return const Text(
                                            'Image could not be load');
                                      },
                                    ))))
                        : Container(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () async {
                          List img = await PickImage(ImageSource.gallery);
                          setState(() {
                            imagePath = img[0];
                            memoryPath = img[1];
                            previewImage = true;
                            print('imagePath');
                            print(imagePath);
                            print('memoryPath');
                            print(memoryPath);
                          });
                          editing(true);
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 20),
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                            ),
                            side: BorderSide(
                                color: imgErrorMessage
                                    ? Colors.red
                                    : Colors.grey.shade400,
                                width: imgErrorMessage ? 2 : 1)),
                        // child: Text(editImg == '' ? 'Add Image' : editImg),
                        child: Text("Update image"),
                      ),
                    )
                  ],
                ),
                imgErrorMessage
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                          child: Text('Pleas select an image.',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal)),
                        ))
                    : SizedBox(),
              ],
            ),
            // /*image2*/ Column(
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         ElevatedButton(
            //           onPressed: addImage,
            //           style: ElevatedButton.styleFrom(
            //               foregroundColor: Colors.blue,
            //               backgroundColor: Colors.white,
            //               padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            //               textStyle: const TextStyle(
            //                 fontSize: 18,
            //               ),
            //               side: BorderSide(
            //                   color: Colors.grey.shade400, width: 1)),
            //           child: Text(editImg == '' ? 'Add Image' : editImg),
            //         ),
            //       ],
            //     ),
            //     Stack(
            //       children: [
            //         Padding(
            //           padding: EdgeInsets.fromLTRB(8, 8, 0, 4),
            //           child: Text(
            //             imagePath,
            //             style: TextStyle(
            //               fontSize: 15,
            //             ),
            //           ),
            //         ),
            //         Positioned(
            //           right: 5.0,
            //           bottom: 5.0,
            //           child: InkWell(
            //             child: Icon(
            //               Icons.remove_circle,
            //               size: 30,
            //               color: Colors.red,
            //             ),
            //             onTap: () {
            //               setState(
            //                 () {
            //                   imagePath = '';
            //                   imageDB = null;
            //                 },
            //               );
            //             },
            //           ),
            //         )
            //       ],
            //     ),
            //   ],
            // ),

            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            //website
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                textAlign: TextAlign.left,
                controller: websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
                validator: (value) {
                  if (value!.isNotEmpty && !validator.url(value)) {
                    return 'Please enter a valid website Url';
                  }
                  return null;
                },
              ),
            ),
            //phone number
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                // maxLength: 10,
                textAlign: TextAlign.left,
                controller: numberController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', hintText: '05XXXXXXXX'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    print('empty');
                  } else {
                    // if (value.length != 10) {
                    //   return 'Please enter a phone number of 10 digits';
                    // }
                  }
                },
              ),
            ),
            //description
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 35, 6, 10),
              child: Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                maxLength: 400,
                textAlign: TextAlign.left,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            /*location*/
            Container(
              padding: EdgeInsets.fromLTRB(6, 25, 6, 8),
              child: Text('Location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            Container(
                // width: 180,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        child: GoogleMap(
                      gestureRecognizers: Set()
                        ..add(Factory<TapGestureRecognizer>(() => Gesture(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => maps(
                                        dataId: widget.docId,
                                        typeOfRequest: 'EP',
                                        latitude: double.parse(widget.latitude),
                                        longitude:
                                            double.parse(widget.longitude)),
                                  ));
                            }))),
                      markers: getMarker(double.parse(widget.latitude),
                          double.parse(widget.longitude)),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(widget.latitude),
                            double.parse(widget.longitude)),
                        zoom: 12.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        myController = controller;
                      },
                    )))),
            /*location*/ Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => maps(
                                dataId: widget.docId,
                                typeOfRequest: 'EP',
                                latitude: double.parse(widget.latitude),
                                longitude: double.parse(widget.longitude)),
                          ));
                    },
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: getLocationAsString(
                                double.parse(widget.latitude),
                                double.parse(widget.longitude)),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                var reqLoc = snap.data;
                                return
                                    // const Padding(
                                    //     padding:
                                    //         EdgeInsets.fromLTRB(0, 0, 6, 40),
                                    //     child: Icon(
                                    //       Icons.location_on_outlined,
                                    //       size: 25,
                                    //       // color: Colors
                                    //       //     .white
                                    //     )),
                                    Flexible(
                                        //   width: 150,

                                        child: Text(reqLoc!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.1,
                                              wordSpacing: 0.1,
                                              fontSize: 15,
                                              decoration:
                                                  TextDecoration.underline,
                                              // color: Colors
                                              //     .white
                                            )));
                              } else {
                                return const Text('');
                              }
                            }),
                        // Flexible(
                        //     // width: 150,
                        //     child: Text(reqLoc,
                        //         style: TextStyle(
                        //           // color: Colors
                        //           //     .grey.shade500,
                        //           fontWeight: FontWeight.w400,
                        //           letterSpacing: 0.1,
                        //           wordSpacing: 0.1,
                        //           fontSize: 15,
                        //           decoration: TextDecoration.underline,
                        //         )))
                      ],
                    ))),

            // bottons
            Center(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /*button*/ Container(
                  width: 150,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.blue,
                        Color(0xFF39d6ce),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: const Text(
                            "Discard all edits?",
                            textAlign: TextAlign.left,
                          ),
                          actions: <Widget>[
                            // cancle button
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                child: const Text("Cancel"),
                              ),
                            ),
                            //ok button
                            TextButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => userProfile(
                                          userType: widget.userType,
                                          selectedTab: 1,
                                          selectedSubTab: 1),
                                    ));
                              },
                              child: Container(
                                //color: Color.fromARGB(255, 164, 20, 20),
                                padding: const EdgeInsets.all(14),
                                child: const Text("Discard",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 164, 10, 10))),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  width: 150,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5.0)
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.blue,
                        Color(0xFF39d6ce),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('selectedCategory');
                        print(selectedCategory);
                        print('selectedCategory2');
                        print(selectedCategory2);
                        updateDB(widget.docId);
                        setState(() {
                          isSedited = false;
                        });
                        print('end of');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Please fill the required fields above'),
                            backgroundColor: Colors.red.shade400,
                            margin: EdgeInsets.fromLTRB(8, 0, 20, 0),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'Dismiss',
                              disabledTextColor: Colors.white,
                              textColor: Colors.white,
                              onPressed: () {
                                //Do whatever you want
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ))
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Container(
          width: 60,
          height: 60,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              colors: [
                Colors.blue,
                Color(0xFF39d6ce),
              ],
            ),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  addPost(userType: widget.userType),
              transitionDuration: Duration(seconds: 1),
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavBar(
        onPress: (int value) => setState(() {
          _selectedIndex = value;
        }),
        userType: widget.userType,
        currentI: -1,
      ),
    );
  }

  void Confermation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Place has been updated"),
      ),
    );
    Navigator.of(context).pop();
  }

  // String imagePath = '';
  // String imagePath = '';
  File? imageDB;
  String strImg = '';
  Future<List<dynamic>> PickImage(var imgSource) async {
    List<dynamic> imageList = <dynamic>[];
    Uint8List text = Uint8List(3);
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      var imageChat = await ImagePicker().pickImage(source: imgSource);
      Uint8List imageData = await imageChat!.readAsBytes();
      imageList.add(imageChat);
      imageList.add(imageData);
      editImg = 'Change Image';

      return imageList;
    }
    return text;
  }

  Future<void> addImage(var imageChat) async {
    imagePath = '';
    File? imageDB;
    String strImg = '';

    File imagee = File(imageChat!.path);
    imagePath = imagee.toString();
    imageDB = imagee;
    File image = imageDB;
    final storage = FirebaseStorage.instance.ref().child('postsImage/${image}');
    strImg = Path.basename(image.path);
    UploadTask uploadTask = storage.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    imagePath = await (await uploadTask).ref.getDownloadURL();
  }

  // Future<void> addImage() async {
  //   await Permission.photos.request();
  //   var permissionStatus = await Permission.photos.status;
  //   if (permissionStatus.isGranted) {
  //     XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);

  //     setState(() async {
  //       File image = File(img!.path);
  //       print('Image path $image');
  //       imagePath = image.toString();
  //       print('Image path $imagePath');
  //       imageDB = image;
  //       editImg = 'Update Image';
  //       //imagectrl = imagePath;
  //       // File image = imageDB!;
  //     });
  //   }
  // }

  Future<void> updateDB(docId) async {
    final posts = FirebaseFirestore.instance.collection('posts').doc(docId);
    print('inside update');

    DateTime _date = DateTime.now();
    String date = DateFormat('yyyy-MM-dd HH: mm').format(_date);

    String dataId = '';
    print('will be added to db');
    //add all value without the location
    var s3 = isSedited ? selectedCategory2 : selectedCategory;
    selectedCategory = s3;
    print('s3');
    print(s3);

    var newImg;
    if (previewImage) {
      await addImage(imagePath);
      newImg = imagePath;
    } else
      newImg = imagectrl;

    posts.update({
      'name': nameController.text,
      'category': s3,
      'img': newImg,
      // 'latitude': '',
      // 'longitude': '',
      'Website': websiteController.text,
      'Phone number': numberController.text,
      'description': descriptionController.text,
      // 'userId': FirebaseAuth.instance.currentUser!.uid,
      // 'docId': '',
      //  'status': 'Pending',
      //'date': date
    });
    Confermation();
    // clearForm();

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => maps(dataId: dataId, typeOfRequest: 'P'),
    //     ));
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    numberController.clear();
    websiteController.clear();
    imagePath = '';
  }
}

class Gesture extends TapGestureRecognizer {
  Function _test;

  Gesture(this._test);

  @override
  void resolve(GestureDisposition disposition) {
    super.resolve(disposition);
    this._test();
  }

  @override
  // TODO: implement debugDescription
  String get debugDescription => throw UnimplementedError();

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    // TODO: implement isFlingGesture
    throw UnimplementedError();
  }
}
