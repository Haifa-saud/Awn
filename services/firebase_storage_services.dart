import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';

class Storage {
  // ignore: non_constant_identifier_names
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<firebase_storage.ListResult> listFile() async {
    firebase_storage.ListResult results = await storage.ref('logo').listAll();
    results.items.forEach((firebase_storage.Reference ref) {
      print('found file $ref ');
    });
    return results;
  }

  Future<String> downloadURL(String imgName) async {
    String downloadURL = await storage.ref('logo/$imgName').getDownloadURL();
    return downloadURL;
  }
}
