import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../utils/app_validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user, required this.onSave});

  static const routeName = '/profile/edit';

  final AppUser user;
  final Function(AppUser) onSave;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthdayController;

  // Vet Data
  List<String> _selectedSpecializations = [];
  List<String> _selectedDays = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Sitter controllers
  late TextEditingController _experienceController;
  late TextEditingController _pricingController;
  late TextEditingController _serviceAreaController;

  final List<String> _allSpecializations = [
    'General Practice',
    'Surgery',
    'Dermatology',
    'Exotic Animals',
    'Emergency Care',
    'Dentistry',
    'Internal Medicine'
  ];

  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _addressController.addListener(() {
      if (mounted) setState(() {});
    });
    _birthdayController = TextEditingController(text: user.birthday);

    if (user.role == UserRole.vet) {
      _initVetData(user);
    } else if (user.role == UserRole.sitter) {
      _experienceController = TextEditingController(text: user.experience);
      _pricingController = TextEditingController(text: user.pricing?.toString());
      _serviceAreaController = TextEditingController(text: user.serviceArea);
    }
  }

  void _initVetData(AppUser user) {
    // Specializations
    if (user.specialization != null && user.specialization!.isNotEmpty) {
      _selectedSpecializations = user.specialization!.split(',').map((e) => e.trim()).toList();
    }

    // Clinic Location - Synced with Address now


    // Schedule: Expected format "Mon, Tue | 09:00 - 17:00"
    if (user.schedule != null && user.schedule!.isNotEmpty) {
      final parts = user.schedule!.split('|');
      if (parts.isNotEmpty) {
        final daysStr = parts[0];
        _selectedDays = daysStr.split(',').map((e) => e.trim()).toList();
        
        if (parts.length > 1) {
          final timePart = parts[1].trim();
          final times = timePart.split('-');
          if (times.length == 2) {
             _startTime = _parseTime(times[0].trim());
             _endTime = _parseTime(times[1].trim());
          }
        }
      }
    }
  }

  TimeOfDay? _parseTime(String s) {
    try {
      // Expected "HH:mm" or "HH:mm AM/PM"
      // Let's rely on TimeOfDay string parsing logic or manual
      // Material TimeOfDay(09:00) output is "TimeOfDay(09:00)"
      // But we stored formatted string.
      // Let's assume standard HH:mm 24h for simplicity or parse typical format
      final parts = s.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]); // Handle potentially ' AM' suffix?
        
        if (s.toLowerCase().contains('pm') && hour < 12) hour += 12;
        if (s.toLowerCase().contains('am') && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();

    if (widget.user.role == UserRole.sitter) {
      _experienceController.dispose();
      _pricingController.dispose();
      _serviceAreaController.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    AppUser updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      birthday: _birthdayController.text.trim(),
    );

    if (widget.user.role == UserRole.vet) {
      // Serialize Vet Data
      final specString = _selectedSpecializations.join(', ');
      
      String scheduleString = '';
      if (_selectedDays.isNotEmpty) {
        scheduleString += _selectedDays.join(', ');
        if (_startTime != null && _endTime != null) {
          scheduleString += ' | ${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}';
        }
      }

      updated = updated.copyWith(
        specialization: specString,
        clinicLocation: _addressController.text.trim(), // Synced with address
        schedule: scheduleString,
      );
    } else if (widget.user.role == UserRole.sitter) {
      updated = updated.copyWith(
        experience: _experienceController.text.trim(),
        pricing: double.tryParse(_pricingController.text.trim()),
        serviceArea: _serviceAreaController.text.trim(),
      );
    }

    widget.onSave(updated);
    Navigator.pop(context);
  }

  String _formatTime(TimeOfDay t) {
    // 24 hours format for internal storage
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _toggleSpecialization(String spec) {
    setState(() {
      if (_selectedSpecializations.contains(spec)) {
        _selectedSpecializations.remove(spec);
      } else {
        _selectedSpecializations.add(spec);
      }
    });
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Full name',
                validator: (value) =>
                    AppValidators.required(value, fieldName: 'Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: 'Address',
              ),
              const SizedBox(height: 16),
              if (user.role == UserRole.vet)
                 _buildMapPlaceholder(_addressController.text),
              const SizedBox(height: 16),
              AppTextField(
                controller: _birthdayController,
                label: 'Birthday (YYYY-MM-DD)',
              ),
              if (user.role == UserRole.vet) ...[
                const SizedBox(height: 24),
                const Text('Specialization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _allSpecializations.map((spec) {
                    final isSelected = _selectedSpecializations.contains(spec);
                    return FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (_) => _toggleSpecialization(spec),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _daysOfWeek.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (_) => _toggleDay(day),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectStartTime,
                        child: Text(_startTime?.format(context) ?? 'Start Time'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectEndTime,
                        child: Text(_endTime?.format(context) ?? 'End Time'),
                      ),
                    ),
                  ],
                ),
              ],
              if (user.role == UserRole.sitter) ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _experienceController,
                  label: 'Experience',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _pricingController,
                  label: 'Hourly Rate',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _serviceAreaController,
                  label: 'Service Area',
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save Changes',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(String address) {
    // A mock Google Map view
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
           // Mock Map Grid lines
           Column(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: List.generate(5, (_) => const Divider(color: Colors.white)),
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: List.generate(5, (_) => const VerticalDivider(color: Colors.white)),
           ),
           Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.location_on, color: Colors.red, size: 40),
               const SizedBox(height: 4),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(4),
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                 ),
                 child: Text(
                   address.isEmpty ? 'Select Address' : address,
                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                 ),
               )
             ],
           ),
        ],
      ),
    );
  }
}
