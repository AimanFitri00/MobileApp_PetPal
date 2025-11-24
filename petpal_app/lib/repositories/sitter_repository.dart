import '../models/app_user.dart';
import '../services/firestore_service.dart';

class SitterRepository {
  SitterRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<List<AppUser>> fetchSitters({String? location}) async {
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
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data()))
        .toList();
  }
}
