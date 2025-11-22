import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/messaging_service.dart';
import 'ui/screens/splash_screen.dart';

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final firebaseService = FirebaseService();
    final authService = AuthService();
    final messagingService = MessagingService();
    
    // Initialize messaging
    messagingService.initialize();

    // Create repositories
    final authRepository = AuthRepository(
      authService: authService,
      firebaseService: firebaseService,
      messagingService: messagingService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: authRepository)
          ..add(const AppStarted()),
        child: MaterialApp(
          title: 'PetPal',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

