import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/booking.dart';
import '../../models/app_user.dart';
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

  void _submit(AppUser sitter) {
    if (_dateRange == null) return;
    final user = context.read<AuthBloc>().state.user;
    if (user == null || _selectedPetId == null) return;
    
    // Find the selected pet
    final selectedPet = context.read<PetBloc>().state.pets.firstWhere(
      (pet) => pet.id == _selectedPetId,
    );
    
    final booking = Booking.sitter(
      id: '',
      ownerId: user.id,
      petId: _selectedPetId!,
      sitterId: sitter.id,
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      status: BookingStatus.pending,
      notes: _notesController.text,
      petName: selectedPet.name,
      petImageUrl: selectedPet.imageUrl,
      ownerName: user.name,
      ownerEmail: user.email,
      petSpecies: selectedPet.species,
      petBreed: selectedPet.breed,
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
    final sitter = ModalRoute.of(context)!.settings.arguments as AppUser;
    final pets = context.watch<PetBloc>().state.pets;
    _selectedPetId = _selectedPetId ?? (pets.isNotEmpty ? pets.first.id : null);
    return Scaffold(
      appBar: AppBar(title: Text('Book ${sitter.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedPetId,
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
                    : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}',
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
