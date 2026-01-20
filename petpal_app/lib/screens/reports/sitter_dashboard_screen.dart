import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/report/report_bloc.dart';
import '../../utils/dialog_utils.dart';

class SitterDashboardScreen extends StatefulWidget {
  const SitterDashboardScreen({super.key});

  static const routeName = '/reports/sitter';

  @override
  State<SitterDashboardScreen> createState() => _SitterDashboardScreenState();
}

class _SitterDashboardScreenState extends State<SitterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<ReportBloc>().add(SitterStatsRequested(user.id));
    }
  }

  Future<String?> _saveBytesToDownloads(Uint8List bytes, String filename) async {
    try {
      if (Platform.isAndroid) {
        final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        final dir = (dirs != null && dirs.isNotEmpty) ? dirs.first : null;
        if (dir != null) {
          final file = File('${dir.path}/$filename');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      }

      // For desktop (Windows/macOS/Linux) and fallback
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          final file = File('${downloads.path}/$filename');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      } catch (_) {}

      // Fallback to application documents
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _exportReport(Map<String, dynamic> stats) async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found.')));
      return;
    }
    // Dispatch export event to ReportBloc — reuses vet PDF layout for sitter
    context.read<ReportBloc>().add(
      SitterReportExportRequested(sitterId: user.id, sitterName: user.name ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Summary')),
      body: BlocConsumer<ReportBloc, ReportState>(
        listenWhen: (previous, current) => previous.exportedBytes != current.exportedBytes || previous.errorMessage != current.errorMessage,
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
                  TextButton(onPressed: () => Navigator.of(ctx).pop('share'), child: const Text('Share')),
                  TextButton(onPressed: () => Navigator.of(ctx).pop('save'), child: const Text('Save to Downloads')),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                ],
              ),
            );

            if (choice == 'share') {
              await Printing.sharePdf(bytes: bytes, filename: 'sitter-report.pdf');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share dialog opened.')));
            } else if (choice == 'save') {
              try {
                final docDir = await getApplicationDocumentsDirectory();
                final localFile = File('${docDir.path}/sitter-report.pdf');
                await localFile.writeAsBytes(bytes);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report saved locally: ${localFile.path}')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Local save failed: ${e.toString()}')));
              }

              try {
                await FileSaver.instance.saveFile(name: 'sitter-report', bytes: bytes, ext: 'pdf', mimeType: MimeType.pdf);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report saved (via FileSaver).')));
              } catch (_) {
                final savedPath = await _saveBytesToDownloads(bytes, 'sitter-report.pdf');
                if (savedPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report saved to: $savedPath')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed.')));
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

          // Redesigned stats grid
          final cards = [
            _StatCard(title: 'Total Jobs', value: stats['totalJobs'].toString(), icon: Icons.work, color: Colors.blue),
            _StatCard(title: 'Completed', value: stats['completed'].toString(), icon: Icons.check_circle, color: Colors.green),
            _StatCard(title: 'Pending', value: stats['pending'].toString(), icon: Icons.pending, color: Colors.orange),
            _StatCard(title: 'Completion Rate', value: '${(stats['completionRate'] as double).toStringAsFixed(1)}%', icon: Icons.trending_up, color: Colors.purple),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 640;
                  final crossAxisCount = isWide ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: cards,
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(stats),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export to PDF'),
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
