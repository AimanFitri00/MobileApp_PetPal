import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../bookings/sitter_booking_screen.dart';

class SitterDetailScreen extends StatelessWidget {
  const SitterDetailScreen({super.key});

  static const routeName = '/sitters/detail';

  @override
  Widget build(BuildContext context) {
    final sitter = ModalRoute.of(context)!.settings.arguments as AppUser;
    return Scaffold(
      appBar: AppBar(title: Text(sitter.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experience: ${sitter.experience ?? 'Not specified'}'),
            Text('Location: ${sitter.address ?? 'Not specified'}'),
            Text('Pricing: \$${sitter.pricing ?? '0'}/hr'),
            const SizedBox(height: 12),
            Text('Service Area', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(sitter.serviceArea ?? 'Not specified'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  SitterBookingScreen.routeName,
                  arguments: sitter,
                ),
                child: const Text('Book sitter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
