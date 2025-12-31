import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/booking.dart';
import '../../models/app_user.dart';
import '../../screens/bookings/booking_summary_screen.dart';
import '../../widgets/primary_button.dart';

class VetBookingScreen extends StatefulWidget {
  const VetBookingScreen({super.key});

  static const routeName = '/bookings/vet';

  @override
  State<VetBookingScreen> createState() => _VetBookingScreenState();
}

class _VetBookingScreenState extends State<VetBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedPetId;

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(AppUser vet) {
    final user = context.read<AuthBloc>().state.user;
    if (user == null || _selectedPetId == null) return;
    
    // Find the selected pet
    final selectedPet = context.read<PetBloc>().state.pets.firstWhere(
      (pet) => pet.id == _selectedPetId,
    );
    
    final booking = Booking.vet(
      id: '',
      ownerId: user.id,
      petId: _selectedPetId!,
      vetId: vet.id,
      date: _selectedDate,
      time: _timeController.text,
      notes: _notesController.text,
      status: BookingStatus.pending,
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
    final vet = ModalRoute.of(context)!.settings.arguments as AppUser;
    final pets = context.watch<PetBloc>().state.pets;
    _selectedPetId = _selectedPetId ?? (pets.isNotEmpty ? pets.first.id : null);
    return Scaffold(
      appBar: AppBar(title: Text('Book ${vet.name}')),
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
            CalendarDatePicker(
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              initialDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Preferred time'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const Spacer(),
            if (pets.isEmpty)
              const Text('Add a pet before booking an appointment.')
            else
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'Confirm booking',
                    isLoading: state.isLoading,
                    onPressed: () => _submit(vet),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
