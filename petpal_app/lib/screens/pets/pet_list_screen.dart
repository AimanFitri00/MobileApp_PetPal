import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/pet.dart';
import '../../widgets/empty_state.dart';
import 'pet_form_screen.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  static const routeName = '/pets';

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<PetBloc>().add(PetsRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _loadPets();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Pets')),
        body: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state.isLoading && state.pets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.pets.isEmpty) {
              return EmptyState(
                message: 'No pets yet. Add your first furry friend!',
                actionLabel: 'Add pet',
                onActionPressed: () =>
                    Navigator.pushNamed(context, PetFormScreen.routeName),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => _PetTile(pet: state.pets[index]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: state.pets.length,
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, PetFormScreen.routeName),
          label: const Text('Add pet'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(pet.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(pet.name),
        subtitle: Text('${pet.species} • ${pet.breed}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          PetDetailScreen.routeName,
          arguments: pet,
        ),
      ),
    );
  }
}
