import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../blocs/pet/pet_bloc.dart';
import '../../models/pet.dart';
import '../../screens/reports/activity_logs_screen.dart';
import '../../utils/dialog_utils.dart';
import 'pet_form_screen.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  static const routeName = '/pets/detail';

  @override
  Widget build(BuildContext context) {
    final pet = ModalRoute.of(context)!.settings.arguments as Pet;
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              PetFormScreen.routeName,
              arguments: pet,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await DialogUtils.showConfirmationDialog(
                context,
                title: 'Delete pet',
                message: 'Are you sure you want to delete ${pet.name}?',
              );
              if (!confirmed) return;
              context.read<PetBloc>().add(PetDeleted(pet.id));
              if (context.mounted) Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              'Pet ${pet.name} (${pet.species}/${pet.breed}) - Medical notes: ${pet.medicalHistory ?? 'N/A'}',
              subject: 'PetPal pet profile',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Species: ${pet.species}'),
            Text('Breed: ${pet.breed}'),
            Text('Age: ${pet.age}'),
            const SizedBox(height: 16),
            Text(
              'Medical history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              pet.medicalHistory?.isNotEmpty == true
                  ? pet.medicalHistory!
                  : 'No history provided',
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                ActivityLogsScreen.routeName,
                arguments: pet.id,
              ),
              icon: const Icon(Icons.directions_walk),
              label: const Text('Activity logs'),
            ),
          ],
        ),
      ),
    );
  }
}
