import 'package:flutter/material.dart';

import '../../models/sitter_profile.dart';
import '../bookings/sitter_booking_screen.dart';

class SitterDetailScreen extends StatelessWidget {
  const SitterDetailScreen({super.key});

  static const routeName = '/sitters/detail';

  @override
  Widget build(BuildContext context) {
    final sitter = ModalRoute.of(context)!.settings.arguments as SitterProfile;
    return Scaffold(
      appBar: AppBar(title: Text(sitter.userId)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experience: ${sitter.experience}'),
            Text('Location: ${sitter.location}'),
            Text('Pricing: ${sitter.pricing}'),
            const SizedBox(height: 12),
            Text('Services', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (sitter.services != null)
              ...sitter.services!.map(Text.new)
            else
              const Text('No services listed'),
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
