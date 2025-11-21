import '../models/sitter_profile.dart';
import '../services/firestore_service.dart';

class SitterRepository {
  SitterRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<SitterProfile>> fetchSitters({String? location}) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.usersRef(),
      builder: (query) {
        var filtered = query.where('role', isEqualTo: 'sitter');
        if (location != null && location.isNotEmpty) {
          filtered = filtered.where('address', isEqualTo: location);
        }
        return filtered;
      },
    );
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Map user data to sitter profile format
      // If sitter-specific fields don't exist, use defaults or user data
      final sitterData = {
        'userId': doc.id,
        'experience': data['experience'] ?? 'Not specified',
        'location': data['location'] ?? data['address'] ?? '',
        'pricing': data['pricing'] ?? 'Contact for pricing',
        'services': data['services'] ?? <String>[],
        'certificateUrl': data['certificateUrl'],
      };
      return SitterProfile.fromMap(doc.id, sitterData);
    }).toList();
  }
}
