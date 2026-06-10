import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Bu platform için Firebase yapılandırması tanımlanmamış: '
          '$defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDNXDfiOZhPCQk5NT6Vuj-GaHMjbopJyU',
    appId: '1:814638614277:android:c8f9f7a86ecdd73ee2996c',
    messagingSenderId: '814638614277',
    projectId: 'lunchquest-ff0bd',
    storageBucket: 'lunchquest-ff0bd.firebasestorage.app',
  );
}
