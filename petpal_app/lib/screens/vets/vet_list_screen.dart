import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/vet/vet_bloc.dart';
import '../../models/app_user.dart';
import '../../widgets/empty_state.dart';
import 'vet_detail_screen.dart';

class VetListScreen extends StatefulWidget {
  const VetListScreen({super.key});

  static const routeName = '/vets';

  @override
  State<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends State<VetListScreen> {
  final _locationController = TextEditingController();
  final _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _filter());
  }

  void _filter() {
    context.read<VetBloc>().add(
      VetsRequested(
        location: _locationController.text.trim(),
        specialization: _specializationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Veterinarians')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _filter, child: const Text('Filter')),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<VetBloc, VetState>(
              builder: (context, state) {
                if (state.isLoading && state.vets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.vets.isEmpty) {
                  return const EmptyState(
                    message: 'No vets match your filters.',
                  );
                }
                return ListView.builder(
                  itemCount: state.vets.length,
                  itemBuilder: (context, index) =>
                      _VetCard(vet: state.vets[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  const _VetCard({required this.vet});

  final AppUser vet;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(vet.name),
        subtitle: Text('${vet.clinicLocation ?? vet.address} • ${vet.specialization}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          VetDetailScreen.routeName,
          arguments: vet,
        ),
      ),
    );
  }
}
