import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDkDS__09I_6YPA6v82BYZjwGpIiggJWsU",
    authDomain: "echospartan-2a2dd.firebaseapp.com",
    projectId: "echospartan-2a2dd",
    storageBucket: "echospartan-2a2dd.firebasestorage.app",
    messagingSenderId: "707138239166",
    appId: "1:707138239166:web:0c50135e9008d31f467cef",
    measurementId: "G-CZ4EZFRSGR",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDkDS__09I_6YPA6v82BYZjwGpIiggJWsU",
    appId: "1:707138239166:android:a32eb742388be8b7467cef",
    messagingSenderId: "707138239166",
    projectId: "echospartan-2a2dd",
    storageBucket: "echospartan-2a2dd.firebasestorage.app",
  );
}
