import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for PetPal application.
///
/// Configuration values are loaded from google-services.json (Android) and
/// GoogleService-Info.plist (iOS), or set manually for web/desktop platforms.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.web:
        return web;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByndk7ngFb83xuaMazSAm3tU6F23L2-vg',
    appId: '1:343448345698:android:9ce4e22dccafcd0ec5853b',
    messagingSenderId: '343448345698',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ADD_IOS_API_KEY',
    appId: 'ADD_IOS_APP_ID',
    messagingSenderId: '343448345698',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
    iosClientId: 'ADD_IOS_CLIENT_ID',
    iosBundleId: 'com.petpal.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'ADD_MACOS_API_KEY',
    appId: 'ADD_MACOS_APP_ID',
    messagingSenderId: '343448345698',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
    iosClientId: 'ADD_MACOS_CLIENT_ID',
    iosBundleId: 'com.petpal.app.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyClK-yD-MhsmrxvpwftcZqnbFLTZmotRWM',
    authDomain: 'petpal-dc596.firebaseapp.com',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
    messagingSenderId: '343448345698',
    appId: '1:343448345698:web:c50aece17ade91b8c5853b',
    measurementId: 'G-QNT8GCF0EM',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyClK-yD-MhsmrxvpwftcZqnbFLTZmotRWM',
    authDomain: 'petpal-dc596.firebaseapp.com',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
    messagingSenderId: '343448345698',
    appId: '1:343448345698:web:c50aece17ade91b8c5853b',
    measurementId: 'G-QNT8GCF0EM',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyClK-yD-MhsmrxvpwftcZqnbFLTZmotRWM',
    authDomain: 'petpal-dc596.firebaseapp.com',
    projectId: 'petpal-dc596',
    storageBucket: 'petpal-dc596.firebasestorage.app',
    messagingSenderId: '343448345698',
    appId: '1:343448345698:web:c50aece17ade91b8c5853b',
    measurementId: 'G-QNT8GCF0EM',
  );
}
