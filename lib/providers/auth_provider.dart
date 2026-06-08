import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state_model.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AuthStateModel> {
  AuthNotifier({required AuthService authService})
      : _authService = authService,
        super(const AuthStateModel(isAuthenticated: false, isLoading: true));

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  Future<void> bootstrap() async {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChange);
    _applyUser(FirebaseAuth.instance.currentUser);
  }

  void _onAuthStateChange(User? user) {
    _applyUser(user);
  }

  void _applyUser(User? user) {
    state = state.copyWith(
      isAuthenticated: user != null,
      isLoading: false,
      error: user != null ? null : state.error,
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        state = state.copyWith(isAuthenticated: true, isLoading: false, error: null);
        return true;
      }
      state = state.copyWith(isLoading: false, error: null);
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in failed: ${e.code} ${e.message}');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: kDebugMode ? 'Google sign-in failed: ${e.message}' : 'Google sign-in failed',
      );
      return false;
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: kDebugMode ? 'Google sign-in failed: $e' : 'Google sign-in failed',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthStateModel(isAuthenticated: false, isLoading: false);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
