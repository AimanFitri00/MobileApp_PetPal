import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'blocs/activity/activity_bloc.dart';
import 'blocs/app_bloc_observer.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/booking/booking_bloc.dart';
import 'blocs/pet/pet_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/report/report_bloc.dart';
import 'blocs/sitter/sitter_bloc.dart';
import 'blocs/vet/vet_bloc.dart';
import 'blocs/hotel/hotel_bloc.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'models/booking.dart';
import 'models/pet.dart';
import 'repositories/activity_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/pet_repository.dart';
import 'repositories/report_repository.dart';
import 'repositories/sitter_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/vet_repository.dart';
import 'repositories/hotel_repository.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/bookings/appointment_history_screen.dart';
import 'screens/bookings/booking_summary_screen.dart';
import 'screens/hotel/check_in_screen.dart';
import 'screens/bookings/sitter_booking_screen.dart';
import 'screens/bookings/vet_booking_screen.dart';
import 'screens/bookings/provider_dashboard_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/pets/pet_detail_screen.dart';
import 'screens/pets/pet_form_screen.dart';
import 'screens/pets/pet_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/reports/activity_logs_screen.dart';
import 'screens/reports/report_dashboard_screen.dart';
import 'screens/sitters/sitter_detail_screen.dart';
import 'screens/sitters/sitter_list_screen.dart';
import 'screens/vets/vet_detail_screen.dart';
import 'screens/vets/vet_list_screen.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/storage_service.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/vets/vet_profile_setup_screen.dart';
import 'screens/sitters/sitter_profile_setup_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = AppBlocObserver();

  final notificationService = NotificationService(
    FirebaseMessaging.instance,
    FlutterLocalNotificationsPlugin(),
  );
  // Don't await here to avoid blocking startup
  // Initialize in PetPalApp.initState instead

  final authService = FirebaseAuthService(FirebaseAuth.instance);
  final firestoreService = FirestoreService(FirebaseFirestore.instance);
  final storageService = StorageService(FirebaseStorage.instance);
  final pdfService = PdfService();

  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final userRepository = UserRepository(firestoreService);
  final petRepository = PetRepository(firestoreService);
  final vetRepository = VetRepository(firestoreService);
  final sitterRepository = SitterRepository(firestoreService);
  final bookingRepository = BookingRepository(firestoreService);
  final activityRepository = ActivityRepository(firestoreService);
  final reportRepository = ReportRepository(
    petRepository: petRepository,
    bookingRepository: bookingRepository,
    activityRepository: activityRepository,
    pdfService: pdfService,
  );
  final hotelRepository = HotelRepository(firestoreService);

  runApp(
    PetPalApp(
      authRepository: authRepository,
      userRepository: userRepository,
      petRepository: petRepository,
      vetRepository: vetRepository,
      sitterRepository: sitterRepository,
      bookingRepository: bookingRepository,
      activityRepository: activityRepository,
      reportRepository: reportRepository,
      hotelRepository: hotelRepository,
      storageService: storageService,
      pdfService: pdfService,
      notificationService: notificationService,
    ),
  );
}

class PetPalApp extends StatefulWidget {
  const PetPalApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.petRepository,
    required this.vetRepository,
    required this.sitterRepository,
    required this.bookingRepository,
    required this.activityRepository,
    required this.reportRepository,
    required this.hotelRepository,
    required this.storageService,
    required this.pdfService,
    required this.notificationService,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PetRepository petRepository;
  final VetRepository vetRepository;
  final SitterRepository sitterRepository;
  final BookingRepository bookingRepository;
  final ActivityRepository activityRepository;
  final ReportRepository reportRepository;
  final HotelRepository hotelRepository;
  final StorageService storageService;
  final PdfService pdfService;
  final NotificationService notificationService;

  @override
  State<PetPalApp> createState() => _PetPalAppState();
}

class _PetPalAppState extends State<PetPalApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize notifications without blocking the UI
    widget.notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.userRepository),
        RepositoryProvider.value(value: widget.petRepository),
        RepositoryProvider.value(value: widget.vetRepository),
        RepositoryProvider.value(value: widget.sitterRepository),
        RepositoryProvider.value(value: widget.bookingRepository),
        RepositoryProvider.value(value: widget.activityRepository),
        RepositoryProvider.value(value: widget.reportRepository),
        RepositoryProvider.value(value: widget.hotelRepository),
        RepositoryProvider.value(value: widget.storageService),
        RepositoryProvider.value(value: widget.pdfService),
        RepositoryProvider.value(value: widget.notificationService),
      ],
        child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthBloc(widget.authRepository)..add(const AuthStatusRequested()),
          ),
          BlocProvider(
            create: (_) => ProfileBloc(
              userRepository: widget.userRepository,
              storageService: widget.storageService,
            ),
          ),
          BlocProvider(
            create: (_) => PetBloc(
              petRepository: widget.petRepository,
              storageService: widget.storageService,
            ),
          ),
          BlocProvider(create: (_) => VetBloc(widget.vetRepository)),
          BlocProvider(create: (_) => SitterBloc(widget.sitterRepository)),
          BlocProvider(create: (_) => VetBloc(widget.vetRepository)),
          BlocProvider(create: (_) => SitterBloc(widget.sitterRepository)),
          BlocProvider(create: (_) => BookingBloc(widget.bookingRepository)),
          BlocProvider(create: (_) => HotelBloc(widget.hotelRepository)),
          BlocProvider(create: (_) => ActivityBloc(widget.activityRepository)),
          BlocProvider(
            create: (_) => ReportBloc(
              reportRepository: widget.reportRepository,
              pdfService: widget.pdfService,
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Navigate to login screen when user logs out
            if (state.status == AuthStatus.unauthenticated) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            }
          },
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'PetPal',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            initialRoute: LoginScreen.routeName,
            routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),
            ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
            ResetPasswordScreen.routeName: (_) => const ResetPasswordScreen(),
            HomeScreen.routeName: (_) => const HomeScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            PetListScreen.routeName: (_) => const PetListScreen(),
            PetFormScreen.routeName: (context) {
              final pet = ModalRoute.of(context)?.settings.arguments as Pet?;
              return PetFormScreen(pet: pet);
            },
            PetDetailScreen.routeName: (_) => const PetDetailScreen(),
            VetListScreen.routeName: (_) => const VetListScreen(),
            VetDetailScreen.routeName: (_) => const VetDetailScreen(),
            VetBookingScreen.routeName: (_) => const VetBookingScreen(),
            SitterListScreen.routeName: (_) => const SitterListScreen(),
            SitterDetailScreen.routeName: (_) => const SitterDetailScreen(),
            SitterBookingScreen.routeName: (_) => const SitterBookingScreen(),
            AppointmentHistoryScreen.routeName: (_) =>
                const AppointmentHistoryScreen(),
            BookingSummaryScreen.routeName: (context) {
              final booking = ModalRoute.of(context)!.settings.arguments as Booking;
              return BookingSummaryScreen(booking: booking);
            },
            ReportDashboardScreen.routeName: (_) =>
                const ReportDashboardScreen(),
            ActivityLogsScreen.routeName: (context) {
              final petId =
                  ModalRoute.of(context)!.settings.arguments as String;
              return ActivityLogsScreen(petId: petId);
            },
            ProviderDashboardScreen.routeName: (_) =>
                const ProviderDashboardScreen(),
            EditProfileScreen.routeName: (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return EditProfileScreen(
                user: args['user'] as AppUser,
                onSave: args['onSave'] as Function(AppUser),
              );
            },
            VetProfileSetupScreen.routeName: (_) => const VetProfileSetupScreen(),
            SitterProfileSetupScreen.routeName: (_) => const SitterProfileSetupScreen(),
            CheckInScreen.routeName: (_) => const CheckInScreen(),
          },
          ),
        ),
      ),
    );
  }
}
