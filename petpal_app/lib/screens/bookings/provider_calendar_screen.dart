import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../models/app_user.dart';
import '../../models/booking.dart';
import '../../models/pet.dart';
import '../../repositories/pet_repository.dart';
import '../../repositories/user_repository.dart';
import '../../utils/dialog_utils.dart';

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({super.key});

  static const routeName = '/provider/calendar';

  @override
  State<ProviderCalendarScreen> createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  final Map<String, Pet> _petCache = {};
  final Map<String, AppUser> _ownerCache = {};
  final Set<String> _ownersFetched = {};
  bool _isLoadingData = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  Future<void> _loadBookingData(List<Booking> bookings) async {
    if (_isLoadingData) return;

    setState(() => _isLoadingData = true);

    final petRepo = context.read<PetRepository>();
    final userRepo = context.read<UserRepository>();

    for (final booking in bookings) {
      // Fetch all pets for an owner once (more reliable than depending on petId presence)
      if (!_ownersFetched.contains(booking.ownerId)) {
        try {
          final pets = await petRepo.fetchPets(booking.ownerId);
          for (final pet in pets) {
            _petCache[pet.id] = pet;
          }
        } catch (_) {
          // Ignore fetch errors for now
        }
        _ownersFetched.add(booking.ownerId);
      }

      // Fetch owner data if not cached
      if (!_ownerCache.containsKey(booking.ownerId)) {
        try {
          final owner = await userRepo.fetchUser(booking.ownerId);
          _ownerCache[booking.ownerId] = owner;
        } catch (_) {
          // Ignore fetch errors for now
        }
      }
    }

    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments Calendar')),
      body: SafeArea(
        child: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              DialogUtils.showErrorDialog(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.bookings.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = state.bookings
                .where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.accepted)
                .toList();

            if (bookings.isNotEmpty && !_isLoadingData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadBookingData(bookings);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarSection(bookings),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProviderCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No-op
  }

  Widget _buildCalendarSection(List<Booking> bookings) {
    final selectedDay = _selectedDay ?? DateTime.now();
    final selectedBookings = _bookingsForDay(bookings, selectedDay)
        .toList()
      ..sort((a, b) => a.time?.compareTo(b.time ?? '') ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<Booking>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.horizontalSwipe,
          eventLoader: (day) => _bookingsForDay(bookings, day),
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        ),
        const SizedBox(height: 12),
        if (selectedBookings.isEmpty)
          Text(
            'No bookings on ${DateFormat.MMMd().format(selectedDay)}',
            style: TextStyle(color: Colors.grey[600]),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedBookings
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildBookingTile(b),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  List<Booking> _bookingsForDay(List<Booking> bookings, DateTime day) {
    return bookings.where((b) => isSameDay(b.date, day)).toList();
  }

  Widget _buildBookingTile(Booking booking) {
    final pet = _petCache[booking.petId];
    final owner = _ownerCache[booking.ownerId];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (booking.petName.isNotEmpty ? booking.petName : (pet?.name ?? '')),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (kDebugMode)
                          Text('petId: ${booking.petId} id: ${booking.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat.MMMd().format(booking.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(booking.time ?? 'TBD', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.category, 'Species', booking.petSpecies ?? pet?.species ?? 'N/A'),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.class_, 'Breed', booking.petBreed ?? pet?.breed ?? 'N/A'),
          const SizedBox(height: 4),
          Text(
            owner?.name ?? booking.ownerName ?? 'Loading...',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            owner?.email ?? booking.ownerEmail ?? 'Loading...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              booking.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
