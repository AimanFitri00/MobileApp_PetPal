import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../models/app_user.dart';
import '../bookings/vet_booking_screen.dart';

class VetDetailScreen extends StatelessWidget {
  const VetDetailScreen({super.key});

  static const routeName = '/vets/detail';

  @override
  Widget build(BuildContext context) {
    final vet = ModalRoute.of(context)!.settings.arguments as AppUser;
    return Scaffold(
      appBar: AppBar(title: Text(vet.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final currentId = authState.user?.id;
                  if (vet.id == currentId) {
                    return BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, pstate) {
                        final local = pstate.localProfileImagePath;
                        if (local != null && local.isNotEmpty) {
                          return CircleAvatar(radius: 48, backgroundImage: FileImage(File(local)));
                        }
                        if (vet.profileImageUrl != null) {
                          return CircleAvatar(radius: 48, backgroundImage: NetworkImage(vet.profileImageUrl!));
                        }
                        return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
                      },
                    );
                  }
                  if (vet.profileImageUrl != null) {
                    return CircleAvatar(radius: 48, backgroundImage: NetworkImage(vet.profileImageUrl!));
                  }
                  return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vet.specialization ?? 'General Practice',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Location: ${vet.clinicLocation ?? vet.address}'),
            const SizedBox(height: 16),
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(vet.schedule ?? 'No schedule available'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  VetBookingScreen.routeName,
                  arguments: vet,
                ),
                child: const Text('Book appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
