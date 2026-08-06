import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState {
  unauthenticated,
  guest,
  authenticated,
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unauthenticated);

  bool get isLoggedIn => state == AuthState.authenticated;
  bool get isGuest => state == AuthState.guest;

  void setGuest() {
    state = AuthState.guest;
  }

  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  void logout() {
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
