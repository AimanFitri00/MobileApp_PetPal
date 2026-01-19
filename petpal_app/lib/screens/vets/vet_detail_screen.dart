import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../models/app_user.dart';
import '../bookings/vet_booking_screen.dart';

class VetDetailScreen extends StatelessWidget {
  const VetDetailScreen({super.key});

  static const routeName = '/vets/detail';

  Widget _buildAvatar(AppUser vet, BuildContext context) {
    return Center(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currentId = authState.user?.id;
          if (vet.id == currentId) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, pstate) {
                final local = pstate.localProfileImagePath;
                if (local != null && local.isNotEmpty) {
                  return CircleAvatar(radius: 48, backgroundImage: FileImage(File(local)));
                }
                if (vet.profileImageUrl != null) {
                  return CircleAvatar(radius: 48, backgroundImage: NetworkImage(vet.profileImageUrl!));
                }
                return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
              },
            );
          }
          if (vet.profileImageUrl != null) {
            return CircleAvatar(radius: 48, backgroundImage: NetworkImage(vet.profileImageUrl!));
          }
          return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
        },
      ),
    );
  }

  Widget _buildChips(List<String>? items) {
    if (items == null || items.isEmpty) return const Text('Not specified');
    return Wrap(spacing: 8, runSpacing: 6, children: items.map((s) => Chip(label: Text(s))).toList());
  }

  void _showContactSheet(BuildContext context, AppUser vet) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final phone = vet.phone;
        final email = vet.email;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact ${vet.name}', style: Theme.of(context).textTheme.titleMedium),
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
                    Navigator.pushNamed(context, VetBookingScreen.routeName, arguments: vet);
                  },
                  child: const Text('Book appointment'),
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
    final vet = ModalRoute.of(context)!.settings.arguments as AppUser;

    return Scaffold(
      appBar: AppBar(title: Text(vet.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildAvatar(vet, context),
          const SizedBox(height: 12),

          Text(vet.specialization ?? 'General Practice', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(vet.clinicLocation ?? vet.address ?? 'Location not specified', style: Theme.of(context).textTheme.bodySmall),

          const SizedBox(height: 12),
          Text('Services', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildChips(vet.servicesProvided),

          const SizedBox(height: 12),
          Text('Pet Types Accepted', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildChips(vet.petTypesAccepted),

          const SizedBox(height: 12),
          Text('About / Bio', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(vet.experience ?? 'No bio available'),

          const SizedBox(height: 16),
          if (vet.hotelImageUrls != null && vet.hotelImageUrls!.isNotEmpty) ...[
            Text('Clinic Photos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: PageView.builder(
                itemCount: vet.hotelImageUrls!.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(vet.hotelImageUrls![i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(vet.schedule ?? 'No schedule available'),

          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, VetBookingScreen.routeName, arguments: vet),
                child: const Text('Book appointment'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => _showContactSheet(context, vet),
              child: const Row(children: [Icon(Icons.contact_phone), SizedBox(width: 8), Text('Contact')]),
            ),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
