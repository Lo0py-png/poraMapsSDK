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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-eNrwC5HdZ8v4KcTP5c2w17l6dNfh41g',
    appId: '1:467000119099:android:470a058c17e6b248af311e',
    messagingSenderId: '467000119099',
    projectId: 'prevozi-mk',
    storageBucket: 'prevozi-mk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAn_4Ya1J1FNPuOwUT6APT9W6-9WWN5uB0',
    appId: '1:467000119099:ios:69f4a3c897e02d64af311e',
    messagingSenderId: '467000119099',
    projectId: 'prevozi-mk',
    storageBucket: 'prevozi-mk.appspot.com',
    iosClientId:
        '467000119099-vjndfr3e1fhqa66936p62hb28oc361j8.apps.googleusercontent.com',
    iosBundleId: 'com.example.prevoziMk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAn_4Ya1J1FNPuOwUT6APT9W6-9WWN5uB0',
    appId: '1:467000119099:ios:96d7658e0cb0506faf311e',
    messagingSenderId: '467000119099',
    projectId: 'prevozi-mk',
    storageBucket: 'prevozi-mk.appspot.com',
    iosClientId:
        '467000119099-61qvvgt69guah03na1550jngurslhrif.apps.googleusercontent.com',
    iosBundleId: 'com.example.prevoziMk.RunnerTests',
  );
}
