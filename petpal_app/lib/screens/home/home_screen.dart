import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../repositories/user_repository.dart';
import '../../services/notification_service.dart';
import '../pets/pet_list_screen.dart';
import '../reports/report_dashboard_screen.dart';
import '../sitters/sitter_list_screen.dart';
import '../vets/vet_list_screen.dart';
import '../bookings/provider_dashboard_screen.dart';
import '../../models/app_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          context.read<ProfileBloc>().add(ProfileRequested(state.user!.id));
          context.read<PetBloc>().add(PetsRequested(state.user!.id));
          final token = await context.read<NotificationService>().getFcmToken();
          if (token != null) {
            await context.read<UserRepository>().saveFcmToken(
              state.user!.id,
              token,
            );
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final isProvider =
              user?.role == UserRole.vet || user?.role == UserRole.sitter;

          final pages = [
            if (isProvider) const ProviderDashboardScreen(),
            const PetListScreen(),
            const VetListScreen(),
            const SitterListScreen(),
            const ReportDashboardScreen(),
          ];

          final destinations = [
            if (isProvider)
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Dashboard',
              ),
            const NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              label: 'Pets',
            ),
            const NavigationDestination(
              icon: Icon(Icons.medical_information_outlined),
              label: 'Vets',
            ),
            const NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              label: 'Sitters',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
          ];

          // Ensure index is valid
          if (_index >= pages.length) _index = 0;

          return Scaffold(
            body: pages[_index],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: destinations,
            ),
          );
        },
      ),
    );
  }
}
