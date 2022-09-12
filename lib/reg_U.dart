
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';  
import 'package:file_picker/file_picker.dart';  
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:open_file/open_file.dart';

//import 'package:simple_permissions/simple_permissions.dart';

  Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp( const MyApp()); }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});
  
      @override  
      Widget build(BuildContext context) {  
        const appTitle = 'Sign Up';  
        return MaterialApp(  
          title: appTitle,  
          home: Scaffold(  
            appBar: AppBar(  
              title: const Text(appTitle),  
            ),  
            body: reg_U(),  
          ),  
        );  
      }  
    }  

    class reg_U extends StatefulWidget {
      const reg_U({super.key});
      @override  
      User_register createState() {  
        return User_register();  
      }  
    }  
    // Create a corresponding State class, which holds data related to the form.  
    class User_register extends State<reg_U> {

      Future selectFile() async{
        final result = await FilePicker.platform.pickFiles();
        if(result == null)  return ; 
        final file = result.files.first;
        openfile(file);

        // print('Name: ${file.name}');
        // print('Name: ${file.bytes}');
        // print('Name: ${file.size}');
        // print('Name: ${file.path}');

       // final newFile = await saveFilePermanetly(file);

        // $ git add .


      }
      // Future<File> saveFilePermanetly(PlatformFile file) async {
      //   final appStorage = await getApplicationDocumentsDirectory();
      //   final newFile = File('${appStorage.path}/${file.name}');
      //   return File(file.path!).copy(newFile.path);

      // }
       void openfile(PlatformFile file){
        OpenFile.open( file.path! );

       }
      Future uploadFile() async{
        final path = 'User/${pickedFile!.name}';
        final file = File(pickedFile!.path!);
        final ref = FirebaseStorage.instance.ref().child(path);
        ref.putFile(file);
      }
      CollectionReference posts = FirebaseFirestore.instance.collection('users');
      // Create a global key that uniquely identifies the Form widget  
      // and allows validation of the form. 
      final _formKey = GlobalKey<FormState>();

      String gender = "male";
      String password = "";
      String confirmPassword= "";
      String email = "";
      String disability = "";
      String phoneNumber = "" ;
      String fName  = "";
      String lName  = "";
      String bDay= "";
      PlatformFile? pickedFile;


      bool disability_choosen = false;
      bool Check_blind = false;
      bool Check_deaf = false;
      bool Check_wheal = false;
      bool Check_other = false;

      Future<void> addToDB() async {
   
    await posts.add({
      'Type': 'Spicial need user',
      'name': fName +" "+ lName ,
      'Email': email,
      'password': confirmPassword,
      'phone number': phoneNumber,
      'gender': gender,
      'disability': disability,
      
    }).then((value) => print("User Added"));
  }


      @override  
      Widget build(BuildContext context) {  
        // Build a Form widget using the _formKey created above.  
        return Form(  
          key: _formKey,  
          child: SingleChildScrollView(
          child: Column(  
            crossAxisAlignment: CrossAxisAlignment.start,  
            children: <Widget>[  

              Container( //First name
                          padding: const EdgeInsets.all(10), //You can use EdgeInsets like above
                          margin: const EdgeInsets.all(5),
                          child: TextFormField(  
                 decoration: const InputDecoration(  
                  icon:  Icon(Icons.person_sharp),  
                  hintText: 'Enter your first name',  
                  labelText: 'Firsl Name',  
                ),  
                validator: (value) { 
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your First Name';
                    }
                    else{ fName = value.toString(); }
                    return null;
                    },
              ),  
                        ),
              Container( //Lasr name
                          padding: const EdgeInsets.only(left:50, bottom: 0, right: 13 ,top:0), //You can use EdgeInsets like above
                          //EdgeInsets.only(left:20, bottom: 5, right: 15 ,top:5),
                          margin: const EdgeInsets.all(5),
                          child: 
                          TextFormField(  
                decoration: const InputDecoration(  
                  hintText: 'Enter your last name',  
                  labelText: 'Last Name',  
                ),  
                validator: (value) { 
                  if (value == null || value.isEmpty) {
                    return 'Please Your Last Name';
                    }
                    lName = value.toString(); 
                    return null;
                    },
              ),
                        ),
              
              Container( //First name
                   padding: const EdgeInsets.all(10), //You can use EdgeInsets like above
                   margin: const EdgeInsets.all(5),
                   child: TextFormField(  
                    
                decoration: const InputDecoration(  
                  icon:  Icon(Icons.phone),  
                  hintText: '05xxxxxxxx',  
                  labelText: 'Phone',  
                ),keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                  ],
                validator: (value) {  
                  if (value == null || value.isEmpty) {  
                    return 'Please enter valid phone number';  
                  }  
                  if (value.length != 10) {
                    return 'Please enter a valid phone number';
                    }
                  phoneNumber = value.toString(); 
                  return null;  
                },  
              ),  
                        ),

              Container( //First name
                   padding: EdgeInsets.all(10), //You can use EdgeInsets like above
                   margin: EdgeInsets.all(5),
                   child: TextFormField(  
                decoration: const InputDecoration(  
                icon:  Icon(Icons.calendar_today),  
                hintText: 'DD-MM-YYYY',  
                labelText: 'Date of Birth',  
                ),  
                validator: (value) {  
                  if (value == null || value.isEmpty) {  
                    return 'Please enter valid date';  
                  }  
                  else{ bDay = value.toString(); }
                  return null;  
                },  
               ),  
                        ),

              

        Container( 
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Container(
                    padding: const EdgeInsets.only(left:10, bottom: 0, right: 0 ,top:15),
                    child:const Icon(Icons.person_pin, size: 25, color: Color.fromARGB(255, 167, 161, 161) ),
                    ),
                    
              Container(
                padding: EdgeInsets.only(left:0, bottom: 0, right: 250 ,top:15),
                child:
                 const Text( "Gender: ",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.left, // has impact
                ),
                ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  
                  Row( children: [
                      Radio(value: 'male', groupValue: gender, 
                      onChanged: (value){
                        setState(() {
                          gender = value.toString();
                      });
                    },
                    ),
                  const Text('male',
                style: TextStyle(fontSize: 20))
                ],
              ),
              Row(
                children: [
                  Radio(value: 'female', groupValue: gender,
                  onChanged: (value){
                      setState(() {
                          gender = value.toString();
                      });
                    },),
                  const Text('Female',
                  style: TextStyle(fontSize: 18))
                ],
              ),
            ],
          ),
          ]
        ),  
      ),


      
      Container( //Email
                 padding: const EdgeInsets.all(10), //You can use EdgeInsets like above
                 margin: const EdgeInsets.all(5),
                 child: TextFormField(  
                 decoration: const InputDecoration(  
                  icon: Icon(Icons.email),  
                  hintText: 'Enter your email',  
                  labelText: 'email',  
                ),  
                validator: (value) { 
                  email = value.toString();
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                    }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email';
                    }
                    return null;
                    },
              ),  
                        ),

              Container( //  pass
                 padding: const EdgeInsets.all(10), //You can use EdgeInsets like above
                margin: const EdgeInsets.all(5),
                child: TextFormField(  
                  obscureText: true,
                  decoration: const InputDecoration(
                  icon: const Icon(Icons.lock), 
                  hintText: 'Password',
            ),
                validator: (value) { 
                  password = value.toString();
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your Password  ';
                    }
                    return null;
                    },
              ),  
                        ),



              Container( // confirm pass
                padding: EdgeInsets.only( left:50, bottom: 0, right: 13 ,top:0 ), //You can use EdgeInsets like above
                margin: const EdgeInsets.all(5),
                child: TextFormField(  
                  obscureText: true,
                  decoration: const InputDecoration(
                  hintText: 'Password',
            ),
                validator: (value) { 
                  password = value.toString();
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your Password  ';
                    }
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value) ) {
                    return 'Password must contain an upper case letter';
                    }
                  if (!RegExp(r'(?=.*?[0-9])').hasMatch(value) ) {
                    return 'Password must contain a number';
                    }
                  if (value.length < 7 ) {
                    return 'Password must contain at least 8 characters';
                    }
                    
                    return null;
                    },
              ),  
                        ),
               Text("Password must contain an Upper case lettter, a digit and at least 8 characters"),



          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Container(
                    padding: const EdgeInsets.only(left:15, bottom: 0, right: 5 ,top:15),
                    child:const Icon(Icons.wheelchair_pickup_sharp, size: 25, color: Color.fromARGB(255, 167, 161, 161) ),
                    ),
                    
              Container(
                padding: const EdgeInsets.only(left:0, bottom: 0, right: 150 ,top:15),
                child:
                 const Text( "Type of disability : ",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left, 
                ),
                ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row( children: [
                      Checkbox(
                        value: Check_blind,
                        onChanged: (value) {
                          setState(() {
                            Check_blind = value!;});
                            },
                            ),
                            const Text('Blind',
                            style: TextStyle(fontSize: 18))
                            ],
                             ),
                   Row( children: [
                    Checkbox(
                        value: Check_deaf,
                        onChanged: (value) {
                          setState(() {
                            Check_deaf = value!; });
                            },
                            ),
                            const Text('Deaf',
                            style: TextStyle(fontSize: 18))
                            ],
                            ),
            ]),
              Row(  mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [       
               Row(
                children: [
                  Checkbox(
                        value: Check_wheal,
                        onChanged: (value) {
                          setState(() {
                            Check_wheal = value!; });
                            },
                   ),
                   const Text('wheelchair user',
                   style: TextStyle(fontSize: 18))
                   ],
              ),
              Row(
                children: [
                  Checkbox(
                        value: Check_other,
                        onChanged: (value) {
                          setState(() {
                            Check_other = value!; });
                            },
                   ),
                   const Text('wheelchair user',
                   style: TextStyle(fontSize: 18))
                   ],
              ),

            ],
          ),
          ]
        ),  
      
          
             ElevatedButton(
                onPressed: selectFile ,
                child: const Text("pick a file: ")
                
              ),
              
            
            
               
              //  ****** Submit button **** 
               Container(  
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() ) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          if(Check_blind){
                            disability = disability + ",blind";
                            } 
                            if(Check_deaf){
                            disability = disability + ",deaf";
                            }
                            if(Check_wheal){
                            disability = disability + ",wheel";
                            }
                            if(Check_other){
                            disability = disability + ",other";
                            }
                           if(!Check_blind && !Check_deaf && ! Check_wheal && !Check_other){
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('please choose a disablitiy')
                              ),
                          );
                           } else {
                          addToDB() ;
                          uploadFile() ;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Welcome to Awn')
                              ),
                          ); }

                        } },
                      
                            child: const Text('Submit'),
                    ),
                  ),  
            ],  
          ), 
          ), 
        );  
      }  

        

    
      
    }