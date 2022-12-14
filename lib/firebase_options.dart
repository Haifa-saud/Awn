// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADY5AhCL7tHDEwRAnhtuuDRx6nufJHZ5E',
    appId: '1:1039829394290:android:a45fad24714ab0a8d833eb',
    messagingSenderId: '1039829394290',
    projectId: 'awn-swe-444-c20ee',
    databaseURL: 'https://awn-swe-444-c20ee-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'awn-swe-444-c20ee.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgKTWVMS7uZ0fD1SG2Q5znJo1JUSiQXWY',
    appId: '1:1039829394290:ios:17ba86ab24f3ffd6d833eb',
    messagingSenderId: '1039829394290',
    projectId: 'awn-swe-444-c20ee',
    databaseURL: 'https://awn-swe-444-c20ee-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'awn-swe-444-c20ee.appspot.com',
    iosClientId: '1039829394290-tvsjf7rb5fa6qvmh5copu2jhia5vbno5.apps.googleusercontent.com',
    iosBundleId: 'com.example.awn',
  );
}
