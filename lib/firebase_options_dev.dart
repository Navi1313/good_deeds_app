// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options_dev.dart';
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2xSHcZ1h9KjpDtQFXTfI3DQelS382yqM',
    appId: '1:944557385111:web:028e015ac60a9fece010d2',
    messagingSenderId: '944557385111',
    projectId: 'good-deeds-dev',
    authDomain: 'good-deeds-dev.firebaseapp.com',
    storageBucket: 'good-deeds-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBadmGpwP6-P87rLRryeHMK1XDGEr-jNmI',
    appId: '1:944557385111:android:80a4ef8b3fb4d046e010d2',
    messagingSenderId: '944557385111',
    projectId: 'good-deeds-dev',
    storageBucket: 'good-deeds-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCnIRGp-FXatCkasub6J4Y7Is1Q1WI2i8I',
    appId: '1:944557385111:ios:4839c5abd764479fe010d2',
    messagingSenderId: '944557385111',
    projectId: 'good-deeds-dev',
    storageBucket: 'good-deeds-dev.appspot.com',
    iosClientId: '944557385111-dgj02kqr4o1jgftv82auhv0d9ro75uv6.apps.googleusercontent.com',
    iosBundleId: 'com.navi.goodDeedsApp.dev',
  );
}
