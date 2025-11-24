import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _exportReport(Map<String, dynamic> stats) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Summary')),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatCard(
                  title: 'Total Jobs',
                  value: stats['totalJobs'].toString(),
                  icon: Icons.work,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Completed',
                        value: stats['completed'].toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        value: stats['pending'].toString(),
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StatCard(
                  title: 'Completion Rate',
                  value: '${stats['completionRate'].toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(stats),
                    icon: const Icon(Icons.download),
                    label: const Text('Export Summary'),
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
