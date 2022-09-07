import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('طلب مساعدة')),
        body: SingleChildScrollView(
            child: Center(
          child: Column(children: <Widget>[
            Text('Awn Requist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            AwnRequestForm(),
            Container(
              color: Color.fromARGB(255, 222, 222, 222),
              width: 300,
              height: 300,
              margin: EdgeInsets.only(bottom: 20, top: 20),
              child: Center(child: Text("data2")),
            ),
            Container(
                color: Color.fromARGB(255, 222, 222, 222),
                width: 300,
                height: 300,
                child: Center(child: Text("data2"))),
          ]),
        )));
  }
}

class AwnRequestForm extends StatefulWidget {
  AwnRequestFormState createState() {
    return AwnRequestFormState();
  }
}

class AwnRequestFormState extends State<AwnRequestForm> {
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.schedule),
                hintText: 'time',
                labelText: 'time',
              ),
              keyboardType: TextInputType.datetime,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time';
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today),
                iconColor: Colors.red,
                hintText: 'date',
                labelText: 'date',
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.schedule),
                hintText: 'duration',
                labelText: 'duration',
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.description),
                hintText: 'describtion',
                labelText: 'describtion',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Sending Data to firestor'),
                  ));
                }
              },
              child: Text('Submit'),
            ))
          ],
        ));
  }
}
