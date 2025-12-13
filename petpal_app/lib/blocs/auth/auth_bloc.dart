import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState.unknown()) {
    on<AuthStatusRequested>(_onStatusRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach(
      _authRepository.authStateChanges.asyncMap((firebaseUser) async {
        if (firebaseUser == null) {
          return const AuthState.unauthenticated();
        }
        final user = await _authRepository.fetchUser(firebaseUser.uid);
        return AuthState.authenticated(user);
      }),
      onData: (state) => state,
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
        address: event.address,
        birthday: event.birthday,
      );
      emit(AuthState.authenticated(user));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.sendPasswordReset(event.email);
    emit(state.copyWith(message: 'Password reset email sent'));
  }
}
