import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/booking/booking_bloc.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  static const routeName = '/bookings/history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment history')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state.isLoading && state.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          final sorted = [...state.bookings]
            ..sort((a, b) => b.date.compareTo(a.date));
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final booking = sorted[index];
              return ListTile(
                title: Text('${booking.type.name.toUpperCase()} booking'),
                subtitle: Text(
                  '${booking.date.toLocal()} • Status: ${booking.status.name}',
                ),
                trailing: Text(booking.petId),
              );
            },
          );
        },
      ),
    );
  }
}
