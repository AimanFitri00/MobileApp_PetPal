import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/activity/activity_bloc.dart';
import '../../models/activity_log.dart';
import '../../widgets/empty_state.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key, required this.petId});

  static const routeName = '/reports/activity';

  final String petId;

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(ActivityLogsRequested(widget.petId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity logs')),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state.isLoading && state.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.logs.isEmpty) {
            return const EmptyState(message: 'No activity logs for this pet.');
          }
          final sorted = [...state.logs]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final log = sorted[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(log.type.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(log.type.name.toUpperCase()),
                subtitle: Text(log.timestamp.toLocal().toString()),
                trailing: Text(log.notes ?? ''),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    final notesController = TextEditingController();
    var type = ActivityType.food;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<ActivityType>(
              value: type,
              items: ActivityType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => type = value ?? ActivityType.food,
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<ActivityBloc>().add(
                  ActivityLogged(
                    ActivityLog(
                      id: '',
                      petId: widget.petId,
                      type: type,
                      timestamp: DateTime.now(),
                      notes: notesController.text,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save log'),
            ),
          ],
        ),
      ),
    );
  }
}
