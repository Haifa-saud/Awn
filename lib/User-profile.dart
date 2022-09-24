
import 'package:awn/DataBaseService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awn/login.dart';




// // This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String uid ;
  String name = "";
  String bday = "";
  String email = "";
  String phone = "";
  String gender = "";
  //String dis = "";


  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<MyUser>{context};
    //final uid = user.uid ;
    DatabaseServices databaseServices = DatabaseServices(uid: uid);

    return Scaffold(
       appBar: AppBar(
          title: const Text('Profile', textAlign: TextAlign.center),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Discard the changes you made?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () {
                      //clearForm();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Discard'),
                  ),
                ],
              ),
            ),
          ),
        ),
  
                
      body: Center(
        child: Column (
          children: [
            Text(name),
            Text(bday),
            Text(email),
            Text(phone),
            Text(gender),
            //Text(dis),

            ElevatedButton(
              onPressed: () async{
                dynamic Info = await databaseServices.getCurrentUserData();
                if(Info != null){
                   bday = Info[0];
                   //dis = Info[1];
                   email = Info[2];
                   gender = Info[5];
                   name = Info[7];
                   phone = Info[8];
                }
                }, child: Text('Show info'),
                ),
              ]
            ),
        )
    );
  }
  
}