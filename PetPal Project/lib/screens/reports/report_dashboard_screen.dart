import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../blocs/report/report_bloc.dart';
import '../../models/pet.dart';
import '../../widgets/primary_button.dart';

class ReportDashboardScreen extends StatefulWidget {
  const ReportDashboardScreen({super.key});

  static const routeName = '/reports';

  @override
  State<ReportDashboardScreen> createState() => _ReportDashboardScreenState();
}

class _ReportDashboardScreenState extends State<ReportDashboardScreen> {
  String? _selectedPetId;

  void _generateReport() {
    final ownerId = context.read<AuthBloc>().state.user?.id;
    if (ownerId == null || _selectedPetId == null) return;
    context.read<ReportBloc>().add(
      ReportRequested(ownerId: ownerId, petId: _selectedPetId!),
    );
  }

  void _exportReport() {
    context.read<ReportBloc>().add(const ReportExportRequested());
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetBloc>().state.pets;
    _selectedPetId ??= pets.isNotEmpty ? pets.first.id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocListener<ReportBloc, ReportState>(
          listenWhen: (previous, current) =>
              previous.exportedBytes != current.exportedBytes,
          listener: (context, state) async {
            if (state.exportedBytes != null) {
              await Printing.sharePdf(
                bytes: state.exportedBytes!,
                filename: 'pet_report.pdf',
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPetId,
                decoration: const InputDecoration(labelText: 'Pet'),
                items: pets
                    .map(
                      (pet) => DropdownMenuItem(
                        value: pet.id,
                        child: Text(pet.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedPetId = value),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Generate report',
                onPressed: _generateReport,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: BlocBuilder<ReportBloc, ReportState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.reportData == null) {
                      return const Center(
                        child: Text(
                          'Select a pet to generate detailed health insights.',
                        ),
                      );
                    }
                    final pet = state.reportData!['pet'] as Pet;
                    final bookings = state.reportData!['bookings'] as List;
                    final activities = state.reportData!['activities'] as List;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet: ${pet.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('Species: ${pet.species}'),
                        const SizedBox(height: 12),
                        Text('Appointments: ${bookings.length}'),
                        Text('Activity logs: ${activities.length}'),
                        const Spacer(),
                        PrimaryButton(
                          label: 'Export as PDF',
                          isLoading: state.isExporting,
                          onPressed: _exportReport,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
