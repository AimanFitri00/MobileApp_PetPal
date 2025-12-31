import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/report/report_bloc.dart';
import '../../utils/dialog_utils.dart';

class ClinicDashboardScreen extends StatefulWidget {
  const ClinicDashboardScreen({super.key});

  static const routeName = '/reports/clinic';

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<ReportBloc>().add(VetStatsRequested(user.id));
    }
  }

  Future<void> _exportReport() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    context.read<ReportBloc>().add(
          VetReportExportRequested(
            vetId: user.id,
            clinicName: user.name,
            startDate: null,
            endDate: null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Dashboard')),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          }
          if (state.exportedBytes != null && !state.isExporting) {
            FileSaver.instance.saveFile(
              name: 'clinic-report',
              bytes: state.exportedBytes!,
              ext: 'pdf',
              mimeType: MimeType.pdf,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report downloaded.')),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.reportData;
          if (stats == null) {
            return const Center(child: Text('No data available.'));
          }

          final cards = [
            _StatCard(
              title: 'Total Appointments',
              value: (stats['totalAppointments'] ?? 0).toString(),
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Completed',
              value: (stats['completed'] ?? 0).toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Upcoming',
              value: (stats['upcoming'] ?? 0).toString(),
              icon: Icons.schedule,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Unique Pets Treated',
              value: (stats['uniquePets'] ?? 0).toString(),
              icon: Icons.pets,
              color: Colors.purple,
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 640;
                    final crossAxisCount = isWide ? 2 : 1;
                    final cardHeight = isWide ? 150.0 : 140.0;
                    final childAspectRatio = isWide
                        ? ((constraints.maxWidth - 16) / 2) / cardHeight
                        : constraints.maxWidth / cardHeight;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: cards,
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isExporting ? null : _exportReport,
                    icon: const Icon(Icons.download),
                    label: Text(state.isExporting ? 'Exporting...' : 'Export Report'),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
