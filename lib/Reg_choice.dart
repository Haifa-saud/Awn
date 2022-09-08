
import 'package:flutter/material.dart';  

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
    class MyCustomForm extends StatefulWidget {
       const MyCustomForm({super.key});
  
      @override  
      MyCustomFormState createState() {  
        return MyCustomFormState();  
      }  
    }  
    // Create a corresponding State class, which holds data related to the form.  
    class MyCustomFormState extends State<MyCustomForm> {

      final _formKey = GlobalKey<FormState>();

      @override
      Widget build(BuildContext context) {
         return Form(  
          key: _formKey,
          child: Column(
          children:[ 
            Container(  
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wlcome to Awn')),
                          );
                        }
                      },
                            child: const Text('Register As A User'),
                    ),
                  ),
            Container(  
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wlcome to Awn')),
                          );
                        }
                      },
                            child: const Text('Register As A Volunteer'),
                    ),
                  ), 
          ], 
          ),
         );
      } 


    }