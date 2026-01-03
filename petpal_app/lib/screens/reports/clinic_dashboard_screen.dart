import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<String?> _saveBytesToDownloads(Uint8List bytes, String filename) async {
    try {
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) {
        final dir = dirs.first;
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        return file.path;
      }

      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Dashboard')),
      body: BlocConsumer<ReportBloc, ReportState>(
        listenWhen: (previous, current) => previous.exportedBytes != current.exportedBytes,
        listener: (context, state) async {
          if (state.errorMessage != null) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          }
          if (state.exportedBytes != null && !state.isExporting) {
            final bytes = state.exportedBytes!;
            final choice = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Report ready'),
                content: const Text('Would you like to share the report or save it to Downloads?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('share'),
                    child: const Text('Share'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('save'),
                    child: const Text('Save to Downloads'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );

            if (choice == 'share') {
              await Printing.sharePdf(bytes: bytes, filename: 'clinic-report.pdf');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share dialog opened.')),
              );
            } else if (choice == 'save') {
              // First, write a guaranteed copy into the app documents directory so file is non-empty
              try {
                final docDir = await getApplicationDocumentsDirectory();
                final localFile = File('${docDir.path}/clinic-report.pdf');
                await localFile.writeAsBytes(bytes);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report saved locally: ${localFile.path}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Local save failed: ${e.toString()}')),
                );
              }

              // Then attempt to save to Downloads via FileSaver; fallback to direct Downloads write if it fails
              try {
                await FileSaver.instance.saveFile(
                  name: 'clinic-report',
                  bytes: bytes,
                  ext: 'pdf',
                  mimeType: MimeType.pdf,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report saved (via FileSaver).')),
                );
              } catch (_) {
                final savedPath = await _saveBytesToDownloads(bytes, 'clinic-report.pdf');
                if (savedPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report saved to: $savedPath')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save failed.')),
                  );
                }
              }
            }
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
