import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../repositories/user_repository.dart';
import '../../services/notification_service.dart';
import '../bookings/provider_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/report_dashboard_screen.dart';
import '../sitters/sitter_list_screen.dart';
import '../vets/vet_list_screen.dart';
import '../../models/app_user.dart';
import 'owner_dashboard_screen.dart';
import '../hotel/hotel_screen.dart';
import '../sitters/sitter_dashboard_screen.dart';
import '../sitters/sitter_feed_screen.dart';
import '../sitters/sitter_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 2; // Default to Home for Owner, logic will adjust for Provider

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


          // Navigation Order: Vets, Sitters, Home, Reports, Profile
          List<Widget> pages;
          List<NavigationDestination> destinations;

          if (user?.role == UserRole.vet) {
             pages = [
               const ProviderDashboardScreen(),
               const HotelScreen(),
               const ProviderDashboardScreen(),
               const ReportDashboardScreen(),
               const ProfileScreen(),
             ];
             destinations = [
               const NavigationDestination(
                 icon: Icon(Icons.calendar_today_outlined),
                 selectedIcon: Icon(Icons.calendar_today),
                 label: 'Appointments',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.hotel_outlined),
                 selectedIcon: Icon(Icons.hotel),
                 label: 'Hotel',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.home_outlined),
                 selectedIcon: Icon(Icons.home),
                 label: 'Home',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.bar_chart_outlined),
                 selectedIcon: Icon(Icons.bar_chart),
                 label: 'Reports',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.person_outline),
                 selectedIcon: Icon(Icons.person),
                 label: 'Profile',
               ),
             ];
             if (_index >= pages.length) _index = 2; // Default to Home
          } else if (user?.role == UserRole.sitter) {
             // Requested Sitter View: Dashboard, Feed, Home, Reports, Profile
             pages = [
               const SitterDashboardScreen(),
               const SitterFeedScreen(),
               const SitterHomeScreen(),
               const ReportDashboardScreen(),
               const ProfileScreen(),
             ];
             destinations = [
               const NavigationDestination(
                 icon: Icon(Icons.dashboard_outlined),
                 selectedIcon: Icon(Icons.dashboard),
                 label: 'Dashboard',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.newspaper_outlined),
                 selectedIcon: Icon(Icons.newspaper),
                 label: 'Feed',
               ),
                const NavigationDestination(
                 icon: Icon(Icons.home_outlined),
                 selectedIcon: Icon(Icons.home),
                 label: 'Home',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.bar_chart_outlined),
                 selectedIcon: Icon(Icons.bar_chart),
                 label: 'Reports',
               ),
               const NavigationDestination(
                 icon: Icon(Icons.person_outline),
                 selectedIcon: Icon(Icons.person),
                 label: 'Profile',
               ),
             ];
             // Default to Home (Index 2)
             if (_index >= pages.length) _index = 2;
          } else {
             pages = [
              const VetListScreen(),
              const SitterListScreen(),
              const OwnerDashboardScreen(),
              const ReportDashboardScreen(),
              const ProfileScreen(),
            ];
            destinations = [
              const NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: 'Vets',
              ),
              const NavigationDestination(
                icon: Icon(Icons.home_work_outlined),
                selectedIcon: Icon(Icons.home_work),
                label: 'Sitters',
              ),
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ];
            // Ensure index is valid for owner (default to home=2)
            if (_index >= pages.length) _index = 2; 
          }

          return Scaffold(
            body: pages[_index],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: destinations,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            ),
          );
        },
      ),
    );
  }
}

