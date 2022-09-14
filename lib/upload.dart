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

  class upload extends StatefulWidget {
      const upload({super.key});
      @override  
      _uploadExample createState() {  
        return _uploadExample();  
      }  
    }  
    // Create a corresponding State class, which holds data related to the form.  
    class _uploadExample extends State<upload> {

      PlatformFile? pickedFile;

      Future selectFile() async{
        final result = await FilePicker.platform.pickFiles();
        if(result == null)  return ; 
        setState(() {
          pickedFile = result.files.first;
        });
      }
      
      Future uploadFile() async{
        final path = 'User/${pickedFile!.name}';
        final file = File(pickedFile!.path!);
        final ref = FirebaseStorage.instance.ref().child(path);
        ref.putFile(file);
      }


          @override
          Widget build(BuildContext context) {
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
        child: Column(
        children:[ 
          if (pickedFile != null)
          Expanded(
            child: Container(
              child: Center(
                child: Text(pickedFile!.name),
              ),
            ),
          ),
          ElevatedButton(
                onPressed: selectFile ,
                child: const Text("pick a file: ")
                ),

                ElevatedButton(
                    onPressed: uploadFile ,
                            child: const Text('Submit'),
                    ),
                 
                ]
                ),
                )
      );
          }
        }