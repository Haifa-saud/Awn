
import 'package:flutter/material.dart';  
import 'package:file_picker/file_picker.dart';  


    void main() => runApp(const MyApp());  
      
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
            body: MyCustomForm(),  
          ),  
        );  
      }  
    }  
    // Create a Form widget.  
    class MyCustomForm extends StatefulWidget {  
      @override  
      MyCustomFormState createState() {  
        return MyCustomFormState();  
      }  
    }  
    // Create a corresponding State class, which holds data related to the form.  
    class MyCustomFormState extends State<MyCustomForm> {  
      // Create a global key that uniquely identifies the Form widget  
      // and allows validation of the form.  
      final _formKey = GlobalKey<FormState>();
      String gender = "male";
      String password = "";
      String confirmPassword= "";
      String email = "";
      String confirmEmail= "";
      String disability = "";
      bool isBlind = true;
      bool isDeaf = true;
      bool isWheelchair = true;
      bool Check_blind = false;
      bool Check_deaf = false;
      bool Check_wheal = false;

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
                    return null;
                    },
              ),  
                        ),
              Container( //Lasr name
                          padding: EdgeInsets.only(left:50, bottom: 0, right: 13 ,top:0), //You can use EdgeInsets like above
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
                  hintText: 'Enter a phone number',  
                  labelText: 'Phone',  
                ),  
                validator: (value) {  
                  if (value == null || value.isEmpty) {  
                    return 'Please enter valid phone number';  
                  }  
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
                    padding: EdgeInsets.only(left:10, bottom: 0, right: 0 ,top:15),
                    child:Icon(Icons.person_pin, size: 25, color: Color.fromARGB(255, 167, 161, 161) ),
                    ),
                    
              Container(
                padding: EdgeInsets.only(left:0, bottom: 0, right: 250 ,top:15),
                child:
                 Text( "Gender: ",
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
                  Text('male',
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
                  Text('Female',
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
                  icon: const Icon(Icons.email),  
                  hintText: 'Enter your email',  
                  labelText: 'email',  
                ),  
                validator: (value) { 
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                    }
                    email = value.toString();
                    return null;
                    },
                    
              ),  
                        ),
              Container( // confirm Email
                padding: EdgeInsets.only(left:50, bottom: 0, right: 13 ,top:0), //You can use EdgeInsets like above
                 margin: const EdgeInsets.all(5),
                 child: TextFormField(  
                 decoration: const InputDecoration(  
                  hintText: 'Enter your email',  
                  labelText: 'confirm email',  
                ),  
                validator: (value) { 
                  confirmEmail = value.toString();
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your email again';
                    }
                  if (email != confirmEmail) {
                    return 'email does not match';
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
                padding: EdgeInsets.only(left:50, bottom: 0, right: 13 ,top:0), //You can use EdgeInsets like above
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

          Container( 
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Container(
                    padding: EdgeInsets.only(left:15, bottom: 0, right: 5 ,top:15),
                    child:Icon(Icons.wheelchair_pickup_sharp, size: 25, color: Color.fromARGB(255, 167, 161, 161) ),
                    ),
                    
              Container(
                padding: EdgeInsets.only(left:0, bottom: 0, right: 150 ,top:15),
                child:
                 Text( "Type of disability : ",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left, // has impact
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
                            Check_blind = value!;
                            disability = disability + "Blind" ;
                            });
                            },
            ),
                  Text('Blind',
                style: TextStyle(fontSize: 18))
                ],
              ),
              Row(
                children: [
                  Checkbox(
                        value: Check_deaf,
                        onChanged: (value) {
                          setState(() {
                            Check_deaf = value!;
                            disability = disability + "Deaf" ;
                            });
                            },
            ),

                  Text('Deaf',
                  style: TextStyle(fontSize: 18))
                ],
              ),
               Row(
                children: [
                  Checkbox(
                        value: Check_wheal,
                        onChanged: (value) {
                          setState(() {
                            Check_wheal = value!;
                            disability = disability + "wheelchair user" ;
                            });
                            },
            ),
                  Text('wheelchair user',
                  style: TextStyle(fontSize: 18))
                ],
              ),
            ],
          ),
          ]
        ),  
      ),
          
             ElevatedButton(
                onPressed: () async{  
                  final result = await FilePicker.platform.pickFiles();
                  if(result == null){
                    print("Please Enter your certification  ") ;
                  }

                },
                child: Text("pick a file: ")
              ),
            
               
              //  ****** Submit button **** 
               Container(  
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate() && email==confirmEmail) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wlcome to Awn')),
                          );
                        }
                      },
                            child: const Text('Submit'),
                    ),
                  ),  
            ],  
          ), 
          ), 
        );  
      }  

        

    
      
    }