import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  unauthenticated,
  guest,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final String userName;

  const AuthState({
    required this.status,
    this.userName = 'Hesap Adı',
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userName,
  }) {
    return AuthState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(status: AuthStatus.unauthenticated));

  bool get isLoggedIn => state.status == AuthStatus.authenticated;
  bool get isGuest => state.status == AuthStatus.guest;

  void setGuest() {
    state = state.copyWith(status: AuthStatus.guest);
  }

  void setAuthenticated({String userName = 'Hesap Adı'}) {
    state = AuthState(
      status: AuthStatus.authenticated,
      userName: userName,
    );
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
