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

  // Vet controllers
  late TextEditingController _specializationController;
  late TextEditingController _clinicLocationController;
  late TextEditingController _scheduleController;

  // Sitter controllers
  late TextEditingController _experienceController;
  late TextEditingController _pricingController;
  late TextEditingController _serviceAreaController;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _birthdayController = TextEditingController(text: user.birthday);

    // Vet init
    _specializationController = TextEditingController(text: user.specialization);
    _clinicLocationController = TextEditingController(text: user.clinicLocation);
    _scheduleController = TextEditingController(text: user.schedule);

    // Sitter init
    _experienceController = TextEditingController(text: user.experience);
    _pricingController = TextEditingController(text: user.pricing?.toString());
    _serviceAreaController = TextEditingController(text: user.serviceArea);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    _specializationController.dispose();
    _clinicLocationController.dispose();
    _scheduleController.dispose();
    _experienceController.dispose();
    _pricingController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      birthday: _birthdayController.text.trim(),
      specialization: _specializationController.text.trim(),
      clinicLocation: _clinicLocationController.text.trim(),
      schedule: _scheduleController.text.trim(),
      experience: _experienceController.text.trim(),
      pricing: double.tryParse(_pricingController.text.trim()),
      serviceArea: _serviceAreaController.text.trim(),
    );
    widget.onSave(updated);
    Navigator.pop(context);
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
              AppTextField(
                controller: _birthdayController,
                label: 'Birthday (YYYY-MM-DD)',
              ),
              if (user.role == UserRole.vet) ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _specializationController,
                  label: 'Specialization',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _clinicLocationController,
                  label: 'Clinic Location',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _scheduleController,
                  label: 'Schedule',
                  maxLines: 3,
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
}
