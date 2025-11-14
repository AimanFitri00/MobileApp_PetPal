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
  }

  Future<void> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
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
    );
    bloc.add(ProfileUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
