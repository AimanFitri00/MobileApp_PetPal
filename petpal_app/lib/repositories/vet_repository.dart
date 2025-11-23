import '../models/vet_profile.dart';
import '../services/firestore_service.dart';

class VetRepository {
  VetRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<VetProfile>> fetchVets({
    String? location,
    String? specialization,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.usersRef(),
      builder: (query) {
        var filtered = query.where('role', isEqualTo: 'vet');
        if (location != null && location.isNotEmpty) {
          filtered = filtered.where('address', isEqualTo: location);
        }
        if (specialization != null && specialization.isNotEmpty) {
          filtered = filtered.where(
            'specialization',
            isEqualTo: specialization,
          );
        }
        return filtered;
      },
    );
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Map user data to vet profile format
      // If vet-specific fields don't exist, use defaults or user data
      final vetData = {
        'userId': doc.id,
        'clinicName': data['clinicName'] ?? data['name'] ?? 'Veterinary Clinic',
        'location': data['location'] ?? data['address'] ?? '',
        'specialization': data['specialization'] ?? 'General Practice',
        'schedule': data['schedule'] ?? <String>[],
        'bio': data['bio'],
        'certificateUrl': data['certificateUrl'],
      };
      return VetProfile.fromMap(doc.id, vetData);
    }).toList();
  }
}
