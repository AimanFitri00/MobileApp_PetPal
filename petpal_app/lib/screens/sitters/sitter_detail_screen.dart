import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_user.dart';
import '../bookings/sitter_booking_screen.dart';

class SitterDetailScreen extends StatelessWidget {
  const SitterDetailScreen({super.key});

  static const routeName = '/sitters/detail';

  Widget _buildAvatar(AppUser sitter, BuildContext context) {
    if ((sitter.profileImageUrl ?? '').isNotEmpty) {
      return CircleAvatar(radius: 40, backgroundImage: NetworkImage(sitter.profileImageUrl!));
    }
    final initials = sitter.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();
    return CircleAvatar(radius: 40, child: Text(initials, style: const TextStyle(fontSize: 20)));
  }

  Widget _buildChips(List<String>? items) {
    if (items == null || items.isEmpty) return const Text('Not specified');
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((s) => Chip(label: Text(s))).toList(),
    );
  }

  void _showContactSheet(BuildContext context, AppUser sitter) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final phone = sitter.phone;
        final email = sitter.email;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact ${sitter.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (phone != null) ...[
                Row(
                  children: [
                    const Icon(Icons.phone),
                    const SizedBox(width: 8),
                    Expanded(child: Text(phone)),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: phone));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone copied')));
                      },
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 8),
                  Expanded(child: Text(email)),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied')));
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, SitterBookingScreen.routeName, arguments: sitter);
                  },
                  child: const Text('Book now'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitter = ModalRoute.of(context)!.settings.arguments as AppUser;

    return Scaffold(
      appBar: AppBar(title: Text(sitter.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(sitter, context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sitter.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(sitter.address ?? sitter.serviceArea ?? 'Location not specified', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Row(children: [
                        if (sitter.yearsOfExperience != null) Text('${sitter.yearsOfExperience} yrs experience'),
                        if (sitter.yearsOfExperience != null) const SizedBox(width: 12),
                        Text('\$${sitter.pricing?.toStringAsFixed(0) ?? '0'}/hr', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text('Services', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildChips(sitter.servicesProvided),

            const SizedBox(height: 12),
            Text('Pet Types Accepted', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildChips(sitter.petTypesAccepted),

            const SizedBox(height: 12),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(sitter.experience ?? 'No description provided.'),

            const SizedBox(height: 16),
            if (sitter.hotelImageUrls != null && sitter.hotelImageUrls!.isNotEmpty) ...[
              Text('Photos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  itemCount: sitter.hotelImageUrls!.length,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(sitter.hotelImageUrls![i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Text('Availability', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if ((sitter.availableDays ?? []).isEmpty && (sitter.availableHours ?? {}).isEmpty)
              const Text('No availability information'),
            if (sitter.availableDays != null && sitter.availableDays!.isNotEmpty) ...[
              Wrap(spacing: 8, children: sitter.availableDays!.map((d) => Chip(label: Text(d))).toList()),
            ],
            if (sitter.availableHours != null && sitter.availableHours!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...sitter.availableHours!.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],

            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, SitterBookingScreen.routeName, arguments: sitter),
                  child: const Text('Book sitter'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _showContactSheet(context, sitter),
                child: const Row(children: [Icon(Icons.contact_phone), SizedBox(width: 8), Text('Contact')]),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
