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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    PetListScreen(),
    VetListScreen(),
    SitterListScreen(),
    ReportDashboardScreen(),
  ];

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
      child: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              label: 'Pets',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_information_outlined),
              label: 'Vets',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              label: 'Sitters',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}
