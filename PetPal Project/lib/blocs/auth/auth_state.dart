part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.message,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(AppUser user)
    : this(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, isLoading, errorMessage, message];
}
