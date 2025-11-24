import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sitter/sitter_bloc.dart';
import '../../models/app_user.dart';
import '../../widgets/empty_state.dart';
import 'sitter_detail_screen.dart';

class SitterListScreen extends StatefulWidget {
  const SitterListScreen({super.key});

  static const routeName = '/sitters';

  @override
  State<SitterListScreen> createState() => _SitterListScreenState();
}

class _SitterListScreenState extends State<SitterListScreen> {
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _filter());
  }

  void _filter() {
    context.read<SitterBloc>().add(
      SittersRequested(location: _locationController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Pet Sitters')),
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
                ElevatedButton(onPressed: _filter, child: const Text('Filter')),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SitterBloc, SitterState>(
              builder: (context, state) {
                if (state.isLoading && state.sitters.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.sitters.isEmpty) {
                  return const EmptyState(
                    message: 'No sitters match your filters.',
                  );
                }
                return ListView.builder(
                  itemCount: state.sitters.length,
                  itemBuilder: (context, index) =>
                      _SitterCard(sitter: state.sitters[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SitterCard extends StatelessWidget {
  const _SitterCard({required this.sitter});

  final AppUser sitter;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(sitter.name),
        subtitle: Text(
          '${sitter.serviceArea ?? sitter.address} • \$${sitter.pricing ?? '0'}/hr',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          SitterDetailScreen.routeName,
          arguments: sitter,
        ),
      ),
    );
  }
}
