import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../services/firestore_service.dart';

class UserRepository {
  UserRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<AppUser> fetchUser(String uid) async {
    final snapshot = await _firestoreService.getDocument(
      collection: _firestoreService.usersRef(),
      docId: uid,
    );
    return AppUser.fromMap(snapshot.id, snapshot.data() ?? {});
  }

  Future<void> updateUser(AppUser user) {
    return _firestoreService.setDocument(
      collection: _firestoreService.usersRef(),
      docId: user.id,
      data: user.toMap(),
    );
  }

  Future<void> saveFcmToken(String uid, String token) {
    return _firestoreService.setDocument(
      collection: _firestoreService.usersRef(),
      docId: uid,
      data: {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
    );
  }

  Future<AppUser?> searchUserByEmailOrPhone(String query) async {
    // Try email first
    var snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.usersRef(),
      builder: (q) => q.where('email', isEqualTo: query).limit(1),
    );
    if (snapshot.docs.isNotEmpty) {
      return AppUser.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    }
    
    // Try phone
    snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.usersRef(),
      builder: (q) => q.where('phone', isEqualTo: query).limit(1),
    );
    if (snapshot.docs.isNotEmpty) {
      return AppUser.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    }
    
    return null;
  }
}
