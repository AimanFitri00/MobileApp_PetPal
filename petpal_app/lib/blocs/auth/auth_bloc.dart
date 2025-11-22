import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LoggedOut>(_onLoggedOut);
    on<AuthStatusRequested>(_onAuthStatusRequested);

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _authRepository.getUser(user.uid).then(
              (userModel) => add(const AuthStatusRequested()),
              onError: (_) => add(const AuthStatusRequested()),
            );
      } else {
        add(const AuthStatusRequested());
      }
    });
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final userModel = await _authRepository.getUser(user.uid);
        emit(Authenticated(user: userModel));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLoggedOut(
    LoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final userModel = await _authRepository.getUser(user.uid);
        emit(Authenticated(user: userModel));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }
}

