import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  void setup({required FirebaseOptions options}) {
    Firebase.initializeApp(options: options);
  }
}
