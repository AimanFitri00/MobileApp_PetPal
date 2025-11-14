import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/booking.dart';
import '../../models/sitter_profile.dart';
import '../../widgets/primary_button.dart';
import 'booking_summary_screen.dart';

class SitterBookingScreen extends StatefulWidget {
  const SitterBookingScreen({super.key});

  static const routeName = '/bookings/sitter';

  @override
  State<SitterBookingScreen> createState() => _SitterBookingScreenState();
}

class _SitterBookingScreenState extends State<SitterBookingScreen> {
  DateTimeRange? _dateRange;
  final _notesController = TextEditingController();
  String? _selectedPetId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  void _submit(SitterProfile sitter) {
    if (_dateRange == null) return;
    final ownerId = context.read<AuthBloc>().state.user?.id;
    if (ownerId == null || _selectedPetId == null) return;
    final booking = Booking.sitter(
      id: '',
      ownerId: ownerId,
      petId: _selectedPetId!,
      sitterId: sitter.userId,
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      status: BookingStatus.pending,
      notes: _notesController.text,
    );
    context.read<BookingBloc>().add(BookingCreated(booking));
    Navigator.pushReplacementNamed(
      context,
      BookingSummaryScreen.routeName,
      arguments: booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitter = ModalRoute.of(context)!.settings.arguments as SitterProfile;
    final pets = context.watch<PetBloc>().state.pets;
    _selectedPetId = _selectedPetId ?? (pets.isNotEmpty ? pets.first.id : null);
    return Scaffold(
      appBar: AppBar(title: Text('Book ${sitter.userId}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPetId,
              decoration: const InputDecoration(labelText: 'Select pet'),
              items: pets
                  .map(
                    (pet) =>
                        DropdownMenuItem(value: pet.id, child: Text(pet.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedPetId = value),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _dateRange == null
                    ? 'Select dates'
                    : '${_dateRange!.start} - ${_dateRange!.end}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickRange,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes for sitter'),
              maxLines: 3,
            ),
            const Spacer(),
            if (pets.isEmpty)
              const Text('Add a pet before booking a sitter.')
            else
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'Confirm sitter booking',
                    isLoading: state.isLoading,
                    onPressed: () => _submit(sitter),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
