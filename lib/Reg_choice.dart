
// import 'package:awn/reg_U.dart';
// import 'package:flutter/material.dart';  

      
    

//     class choice_page extends StatefulWidget {
//        const choice_page({super.key});
  
//       @override  
//       reg_choice createState() {  
//         return reg_choice();  
//       }  
//     }  
//     // Create a corresponding State class, which holds data related to the form.  
//     class reg_choice extends State<choice_page> {
//       final _formKey = GlobalKey<FormState>();

//       @override
//       Widget build(BuildContext context) {
//          return Form(  
//           key: _formKey,
//           child: Column(
//           children:[ 
//             Container(  
//                   padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
//                   child: ElevatedButton(
//                   onPressed: () {
//                       // Validate returns true if the form is valid, or false otherwise.
//                     if (_formKey.currentState!.validate()) {
//                           // If the form is valid, display a snackbar. In the real world,
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('register as user')),
//                           );
//                         }
//                       },
//                             child: const Text('Register As A User'),
//                     ),
//                   ),
//                   Container(  
//                   padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Validate returns true if the form is valid, or false otherwise.
//                     if (_formKey.currentState!.validate()) {
//                           // If the form is valid, display a snackbar. In the real world,
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('register as volunteer')),
//                           );
//                         }
//                       },
//                             child: const Text('Register As A Volunteer'),
//                     ),
//                   ), 
//           ], 
//           ),
//          );
//       } 


//     }