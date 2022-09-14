
import 'package:flutter/material.dart';  
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:awn/main.dart'; 

    
    // Create a Form widget.  
    class Register_V extends StatefulWidget {
      const Register_V({super.key}) ;
      @override  
      State<Register_V> createState() =>  MyCustomFormState();
    }  
    // Create a corresponding State class, which holds data related to the form.  
    class MyCustomFormState extends State<Register_V> {  
      CollectionReference posts = FirebaseFirestore.instance.collection('users');
      // Create a global key that uniquely identifies the Form widget  
      // and allows validation of the form.  
      final _formKey = GlobalKey<FormState>();

      String gender = "male";
      String password = "";
      String confirmPassword= "";
      String email = "";
      String confirmEmail= "";
      String disability = "";
      String phoneNumber = "" ;
      String fName  = "";
      String lName  = "";
      String bDay = "";
      String description = "";

      
      bool Check_blind = false;
      bool Check_deaf = false;
      bool Check_wheal = false;
      bool isBlind = true;
      bool isDeaf = true;
      bool isWheelchair = true;

      Future<void> addToDB() async {
   
    await posts.add({
      'Type': 'Volunteer' ,
      'name': fName+" "+ lName ,
      'Email': confirmEmail,
      'password': confirmPassword,
      'phone number': phoneNumber,
      'description': description,
      'gender': gender,  
         
    }).then((value) => print("User Added"));
  }

  GlobalKey<ScaffoldState> _scaffoldStateKey =  GlobalKey();
      @override  
      Widget build(BuildContext context) {  

        
        // Build a Form widget using the _formKey created above.  
        return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: const Text('Discard the changes you made?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ),
        ),
      ),
      body:Form(  
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
                  lName = value.toString(); 
                  if (value == null || value.isEmpty) {
                    return 'Please Your Last Name';
                    }
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
                  bDay = value.toString(); 
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
                  if (value == null || value.isEmpty) {
                    email = value.toString();
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

              Container( // confirm pass
                padding: EdgeInsets.only( left:50, bottom: 0, right: 13 ,top:0 ), //You can use EdgeInsets like above
                margin: const EdgeInsets.all(5),
                child: TextFormField(  
                  obscureText: true,
                  decoration: const InputDecoration(
                  hintText: 'Password',
            ),
                validator: (value) { 
                  confirmPassword = value.toString();
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your Password again ';
                    }
                  if (password != confirmPassword) {
                    return 'password does not match';
                    }

                    return null;
                    },
              ),  
                        ),
            Text("Password must contain an Upper case lettter, a digit and at least 8 characters"),



             Text("please enter your skills: "),
             Container(
              padding: const EdgeInsets.only(left:10, bottom: 0, right: 30 ,top:15),
              child: TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.description),
                hintText: 'enter description here',
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 1, color: Color.fromARGB(255, 120, 119, 119)), //<-- SEE HERE
                ),
                // labelText: 'describtion',
              ),
              
              //keyboardType: TextInputType.datetime,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              onChanged: (value) {
                description = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Provide a description';
                }
              },
            ),
            
            ),
               
              //  ****** Submit button **** 
               Container(  
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                  child: ElevatedButton(
                    onPressed: () {
                     // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate() ) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          addToDB() ;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Welcome to Awn')
                              ),
                          );
                        } },
                      
                            child: const Text('Submit'),
                    ),
                  ), 


            ],  
          ), 
          ), 
        )
        ); 
         
      }  
    }