import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/hotel/hotel_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../models/app_user.dart';
import '../../models/hotel_stay.dart';
import '../../services/storage_service.dart';
import 'check_in_screen.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<HotelBloc>().add(HotelStaysRequested(user.id));
      // Ensure profile is loaded for images
      context.read<ProfileBloc>().add(ProfileRequested(user.id));
    }
  }

  Future<void> _uploadHotelImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    if (!mounted) return;
    
    final file = File(result.files.single.path!);
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));

    try {
      final storage = context.read<StorageService>();
      final path = 'hotel_images/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storage.uploadFile(file: file, path: path);

      final updatedImgs = List<String>.from(user.hotelImageUrls ?? [])..add(url);
      final updatedUser = user.copyWith(hotelImageUrls: updatedImgs);

      context.read<ProfileBloc>().add(ProfileUpdated(updatedUser));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // We listen to ProfileBloc for images and HotelBloc for stays
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Hotel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final user = state.user ?? context.read<AuthBloc>().state.user;
                if (user == null) return const SizedBox.shrink();
                return _buildHotelImageSection(user);
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildHotelGuestList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImageSection(AppUser user) {
     final images = user.hotelImageUrls ?? [];
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(
                'Hotel Facilities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(onPressed: _uploadHotelImage, icon: const Icon(Icons.add_a_photo)),
           ],
         ),
         const SizedBox(height: 8),
         if (images.isEmpty)
           const Text('No hotel images uploaded.')
         else
           SizedBox(
             height: 120,
             child: ListView.separated(
               scrollDirection: Axis.horizontal,
               itemCount: images.length,
               separatorBuilder: (_, __) => const SizedBox(width: 8),
               itemBuilder: (context, index) {
                 return ClipRRect(
                   borderRadius: BorderRadius.circular(8),
                   child: Image.network(images[index], width: 120, height: 120, fit: BoxFit.cover),
                 );
               },
             ),
           ),
       ],
     );
  }

  Widget _buildHotelGuestList() {
    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        final activeStays = state.stays.where((s) => s.status == HotelStayStatus.checkIn).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Make a new check in',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, CheckInScreen.routeName),
                  child: const Text('Check In'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hotel Guests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
             if (state.isLoading && state.stays.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (activeStays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No pets currently checked in.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeStays.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final stay = activeStays[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: stay.petImageUrl != null
                            ? NetworkImage(stay.petImageUrl!)
                            : null,
                        child: stay.petImageUrl == null
                            ? Text(stay.petName.isNotEmpty ? stay.petName[0].toUpperCase() : '?')
                            : null,
                      ),
                      title: Text(stay.petName),
                      subtitle: Text('Owner: ${stay.ownerName ?? "Unknown"}'),
                      trailing: const Icon(Icons.bed),
                      onTap: () {
                          // View details?
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
