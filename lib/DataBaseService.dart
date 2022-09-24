import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class DatabaseServices {
  final String uid;
  DatabaseServices({required this.uid });
  final userCollection = FirebaseFirestore.instance.collection('users');

  // Future updateUserInfo (String name,String bday,String email,String gender,String phone,String disability) async{
  //   return await userCollection.doc(uid).set({
  //     "Email": email,
  //     "gender": gender,
  //     "name": name,
  //     "phone number": phone,
  //     "DOB": bday,
  //     "Disability": disability,        
  //   });
  // }
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }
  
  
  Future getCurrentUserData() async{
    try {
      DocumentSnapshot ds = await userCollection.doc(uid).get(); 
      String Name = ds.get('name');
      String bDay = ds.get('DOB');
      String Email = ds.get('Email');
      String Gender = ds.get('gender');
      String phone = ds.get('phone number');
      //String disability = ds.get('Disability');
      return [ Name, bDay , Email , Gender , phone 
      //, disability 
      ];
      }catch(e){
        print(e.toString());
        return null;
        }
        }
}

