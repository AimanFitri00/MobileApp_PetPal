import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petpal_app/blocs/auth/auth_bloc.dart';
import 'package:petpal_app/blocs/auth/auth_event.dart';
import 'package:petpal_app/blocs/auth/auth_state.dart';
import 'package:petpal_app/models/user_model.dart';
import 'package:petpal_app/repositories/auth_repository.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(
        AuthBloc(authRepository: mockAuthRepository).state,
        equals(const AuthInitial()),
      );
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when sign in succeeds',
      build: () {
        when(mockAuthRepository.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => const UserModel(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          role: UserRole.owner,
          createdAt: null,
        ));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const SignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when sign in fails',
      build: () {
        when(mockAuthRepository.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Invalid credentials'));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const SignInRequested(
        email: 'test@example.com',
        password: 'wrongpassword',
      )),
      expect: () => [
        const AuthLoading(),
        isA<AuthFailure>(),
      ],
    );
  });
}

