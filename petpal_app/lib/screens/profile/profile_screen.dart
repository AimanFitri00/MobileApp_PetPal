import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../models/app_user.dart';
import '../../utils/app_validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().state.user;
    if (authUser != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ProfileBloc>().add(ProfileRequested(authUser.id)),
      );
    }
    final user = context.read<ProfileBloc>().state.user ?? authUser;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _addressController = TextEditingController(text: user?.address);
    _birthdayController = TextEditingController(text: user?.birthday);
    
    // Vet init
    _specializationController = TextEditingController(text: user?.specialization);
    _clinicLocationController = TextEditingController(text: user?.clinicLocation);
    _scheduleController = TextEditingController(text: user?.schedule);

    // Sitter init
    _experienceController = TextEditingController(text: user?.experience);
    _pricingController = TextEditingController(text: user?.pricing?.toString());
    _serviceAreaController = TextEditingController(text: user?.serviceArea);
  }

  Future<void> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    if (!mounted) return;
    context.read<ProfileBloc>().add(
      ProfileImageUploaded(File(result.files.single.path!)),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<ProfileBloc>();
    final user = bloc.state.user;
    if (user == null) return;
    final updated = user.copyWith(
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
    bloc.add(ProfileUpdated(updated));
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Reset Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reset_password');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (val) {}), // Mock
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user =
              state.user ??
              const AppUser(id: '', name: '', email: '', role: UserRole.owner);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                TextButton.icon(
                  onPressed: _uploadImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload photo'),
                ),
                const SizedBox(height: 16),
                Form(
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
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Save changes',
                        isLoading: state.isLoading,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
