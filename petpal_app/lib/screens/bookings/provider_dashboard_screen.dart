import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../models/booking.dart';
import '../../utils/dialog_utils.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  static const routeName = '/provider/dashboard';

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<BookingBloc>().add(
            ProviderBookingsRequested(userId: user.id, role: user.role),
          );
    }
  }

  void _updateStatus(Booking booking, BookingStatus status) {
    context.read<BookingBloc>().add(BookingStatusUpdated(booking, status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.bookings.isEmpty) {
            return const Center(child: Text('No booking requests found.'));
          }
          final sortedBookings = List<Booking>.from(state.bookings)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedBookings.length,
            itemBuilder: (context, index) {
              final booking = sortedBookings[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(booking.date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          _StatusChip(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Notes: ${booking.notes ?? "None"}'),
                      if (booking.time != null) Text('Time: ${booking.time}'),
                      const SizedBox(height: 16),
                      if (booking.status == BookingStatus.pending)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _updateStatus(
                                booking,
                                BookingStatus.cancelled,
                              ),
                              child: const Text('Decline'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateStatus(
                                booking,
                                BookingStatus.accepted,
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.accepted:
        color = Colors.green;
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
