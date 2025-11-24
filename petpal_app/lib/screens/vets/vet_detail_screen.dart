import 'package:flutter/material.dart';

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
