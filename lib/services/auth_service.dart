import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  bool get hasSession => _auth.currentUser != null;

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }
    return _auth.signInWithProvider(provider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
