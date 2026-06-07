// TODO: Replace these placeholder values with your actual Firebase project configuration.
// To get these values:
// 1. Go to https://console.firebase.google.com
// 2. Create/select your project
// 3. Add a Windows app or use the Web config
// 4. Copy the config values here

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      default:
        return windows; // Use web config as fallback for other platforms
    }
  }

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBl4NrVSurFLn32sYZbeE2sIN7pIONxQ44',
    appId: '1:157023681724:web:965951e6620ca4740564b9',
    messagingSenderId: '157023681724',
    projectId: 'sz-construction-management',
    authDomain: 'sz-construction-management.firebaseapp.com',
    storageBucket: 'sz-construction-management.firebasestorage.app',
    measurementId: 'G-LNJME5QJVH',
  );
}
