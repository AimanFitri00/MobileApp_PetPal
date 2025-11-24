import '../models/app_user.dart';
import '../services/firestore_service.dart';

class VetRepository {
  VetRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<AppUser>> fetchVets({
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
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data()))
        .toList();
  }
}
