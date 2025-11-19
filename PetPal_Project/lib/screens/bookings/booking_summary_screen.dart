import 'package:flutter/material.dart';

import '../../models/booking.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key, required this.booking});

  static const routeName = '/bookings/summary';

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking summary')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${booking.type.name}'),
            Text('Pet: ${booking.petId}'),
            Text('Date: ${booking.date}'),
            if (booking.time != null) Text('Time: ${booking.time}'),
            if (booking.endDate != null) Text('End date: ${booking.endDate}'),
            const SizedBox(height: 12),
            Text('Notes: ${booking.notes ?? 'None'}'),
            const Spacer(),
            FilledButton(
              onPressed: () =>
                  Navigator.popUntil(context, ModalRoute.withName('/home')),
              child: const Text('Back to dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
