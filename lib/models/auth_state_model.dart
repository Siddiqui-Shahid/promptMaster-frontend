class AuthStateModel {
  const AuthStateModel({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthStateModel copyWith({bool? isAuthenticated, bool? isLoading, String? error}) {
    return AuthStateModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
