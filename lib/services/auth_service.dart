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

  /// Completes a prior [signInWithRedirect] flow (web only).
  Future<UserCredential?> getRedirectResult() async {
    if (!kIsWeb) return null;
    return _auth.getRedirectResult();
  }

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..addScope('email');
    if (kIsWeb) {
      try {
        return await _auth.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-blocked' ||
            e.code == 'popup-closed-by-user' ||
            e.code == 'internal-error') {
          await _auth.signInWithRedirect(provider);
          throw const RedirectInProgress();
        }
        rethrow;
      }
    }
    return _auth.signInWithProvider(provider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// Thrown after [signInWithRedirect] — page reload will finish sign-in.
class RedirectInProgress implements Exception {
  const RedirectInProgress();
}
