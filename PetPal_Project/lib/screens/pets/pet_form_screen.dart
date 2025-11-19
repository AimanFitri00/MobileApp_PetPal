import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/pet.dart';
import '../../utils/app_validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.pet});

  static const routeName = '/pets/form';

  final Pet? pet;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _historyController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name);
    _speciesController = TextEditingController(text: pet?.species);
    _breedController = TextEditingController(text: pet?.breed);
    _ageController = TextEditingController(text: pet?.age);
    _historyController = TextEditingController(text: pet?.medicalHistory);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<PetBloc>();
    final ownerId = context.read<AuthBloc>().state.user?.id ?? '';
    final pet = Pet(
      id: widget.pet?.id ?? _uuid.v4(),
      ownerId: ownerId,
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      age: _ageController.text.trim(),
      medicalHistory: _historyController.text.trim(),
    );
    if (widget.pet == null) {
      bloc.add(PetCreated(pet));
    } else {
      bloc.add(PetUpdated(pet));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet == null ? 'Add pet' : 'Edit pet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) =>
                    AppValidators.required(value, fieldName: 'Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _speciesController, label: 'Species'),
              const SizedBox(height: 16),
              AppTextField(controller: _breedController, label: 'Breed'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _historyController,
                label: 'Medical history',
                maxLines: 4,
              ),
              const Spacer(),
              PrimaryButton(label: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
