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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1LI91qSEsce1NEw9FRmuOzz3K3MpT4Fs',
    appId: '1:379384017444:web:75c155713eba3cfd1f9eb1',
    messagingSenderId: '379384017444',
    projectId: 'kolayfb',
    authDomain: 'kolayfb.firebaseapp.com',
    storageBucket: 'kolayfb.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPrbs8FdEW12XQRO05hLOeD4Se1QwQ-xQ',
    appId: '1:379384017444:android:bd410bc42cb24ea91f9eb1',
    messagingSenderId: '379384017444',
    projectId: 'kolayfb',
    storageBucket: 'kolayfb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4BfBQ5LO1XRQ5Jz6sYalXgTI0stqAgJ0',
    appId: '1:379384017444:ios:535525fd9413f5431f9eb1',
    messagingSenderId: '379384017444',
    projectId: 'kolayfb',
    storageBucket: 'kolayfb.appspot.com',
    iosBundleId: 'com.example.kolayApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC4BfBQ5LO1XRQ5Jz6sYalXgTI0stqAgJ0',
    appId: '1:379384017444:ios:4003b3fc1693866e1f9eb1',
    messagingSenderId: '379384017444',
    projectId: 'kolayfb',
    storageBucket: 'kolayfb.appspot.com',
    iosBundleId: 'com.example.kolayApp.RunnerTests',
  );
}