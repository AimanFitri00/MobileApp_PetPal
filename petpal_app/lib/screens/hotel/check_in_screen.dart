import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/hotel/hotel_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/app_user.dart';
import '../../models/hotel_stay.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../utils/app_validators.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  static const routeName = '/hotel/check-in';

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _searchController = TextEditingController();
  final _petNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSearching = false;
  AppUser? _foundOwner;
  String? _selectedPetId;
  bool _manualMode = false;

  void _searchOwner() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _foundOwner = null;
      _selectedPetId = null;
      _manualMode = false;
    });

    final repo = context.read<UserRepository>();
    final user = await repo.searchUserByEmailOrPhone(_searchController.text.trim());

    if (user != null) {
      if (mounted) {
        context.read<PetBloc>().add(PetsRequested(user.id));
      }
    }

    setState(() {
      _isSearching = false;
      _foundOwner = user;
      if (user == null) {
        _manualMode = true;
      }
    });
  }

  void _submitCheckInWithOwner() {
    if (_selectedPetId == null) return;
    final vet = context.read<AuthBloc>().state.user;
    if (vet == null) return;

    final pet = context.read<PetBloc>().state.pets.firstWhere((p) => p.id == _selectedPetId);
    
    final stay = HotelStay(
      id: '',
      vetId: vet.id,
      petId: pet.id,
      petName: pet.name,
      petImageUrl: pet.imageUrl,
      ownerId: _foundOwner!.id,
      ownerName: _foundOwner!.name,
      ownerPhone: _foundOwner!.phone,
      checkInDate: DateTime.now(),
      status: HotelStayStatus.checkIn,
      notes: _notesController.text.trim(),
    );

    context.read<HotelBloc>().add(HotelStayAdded(stay));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet Checked In')));
  }

  void _submitManualCheckIn() {
      final vet = context.read<AuthBloc>().state.user;
      if (vet == null) return;
      
      if (_petNameController.text.trim().isEmpty) return;

      final stay = HotelStay(
        id: '',
        vetId: vet.id,
        petId: const Uuid().v4(),
        petName: _petNameController.text.trim(),
        petImageUrl: null,
        ownerId: '',
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        checkInDate: DateTime.now(),
        status: HotelStayStatus.checkIn,
        notes: _notesController.text.trim(),
      );
      
      context.read<HotelBloc>().add(HotelStayAdded(stay));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet Checked In')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Search User', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    label: 'Email or Phone',
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: _isSearching ? null : _searchOwner,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_foundOwner != null)
              _buildOwnerFoundSection()
            else if (_manualMode)
              _buildManualEntrySection()
            else if (_searchController.text.isNotEmpty)
              const Center(child: Text('User not found. You can add manually below.', style: TextStyle(color: Colors.grey))),
              
            if (_manualMode && _foundOwner == null && _searchController.text.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 16),
                 child: OutlinedButton(
                   onPressed: () => setState(() => _manualMode = true), 
                   child: const Text('Add Walk-in / Manual Pet'),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerFoundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Owner: ${_foundOwner!.name}'),
        const SizedBox(height: 16),
        const Text('Select Pet:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state.isLoading) return const CircularProgressIndicator();
            if (state.pets.isEmpty) return const Text('This owner has no registered pets.');
            
            return Wrap(
              spacing: 8,
              children: state.pets.map((pet) {
                return ChoiceChip(
                  label: Text(pet.name),
                  selected: _selectedPetId == pet.id,
                  onSelected: (selected) {
                    setState(() => _selectedPetId = selected ? pet.id : null);
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: _notesController,
          label: 'Notes (Condition, Belongings, etc.)',
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Check In', onPressed: _submitCheckInWithOwner),
      ],
    );
  }

  Widget _buildManualEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manual Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AppTextField(
          controller: _petNameController,
          label: 'Pet Name',
          validator: (v) => AppValidators.required(v, fieldName: 'Pet Name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _ownerNameController,
          label: 'Owner Name (Optional)',
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _ownerPhoneController,
          label: 'Owner Phone (Optional)',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AppTextField(
            controller: _notesController,
            label: 'Notes',
            maxLines: 2,
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Check In', onPressed: _submitManualCheckIn),
      ],
    );
  }
}

