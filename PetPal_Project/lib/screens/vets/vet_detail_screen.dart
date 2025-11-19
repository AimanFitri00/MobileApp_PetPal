import 'package:flutter/material.dart';

import '../../models/vet_profile.dart';
import '../bookings/vet_booking_screen.dart';

class VetDetailScreen extends StatelessWidget {
  const VetDetailScreen({super.key});

  static const routeName = '/vets/detail';

  @override
  Widget build(BuildContext context) {
    final vet = ModalRoute.of(context)!.settings.arguments as VetProfile;
    return Scaffold(
      appBar: AppBar(title: Text(vet.clinicName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vet.specialization,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Location: ${vet.location}'),
            const SizedBox(height: 16),
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...vet.schedule.map(Text.new),
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
