import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  Stream<User?> get authStateChanges => _authService.authStateChanges();

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    String loginEmail = email;

    // Lightweight email regex check
    final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    if (!isEmail) {
      // Treat as phone number -> lookup email
      // Note: This requires the phone number stored in Firestore to be EXACT format
      final snapshot = await _firestoreService.queryCollection(
        collection: _firestoreService.usersRef(),
        builder: (q) => q.where('phone', isEqualTo: email).limit(1),
      );
      if (snapshot.docs.isNotEmpty) {
        loginEmail = snapshot.docs.first.data()['email'] as String;
      } else {
        // Fallback or let firebase fail with "invalid email"
        // But better to throw:
        throw Exception('No account found with this phone number.');
      }
    }

    final credential = await _authService.signIn(
      email: loginEmail,
      password: password,
    );
    return _loadUser(credential.user!.uid);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? address,
    String? birthday,
  }) async {
    // 1. Check uniqueness of phone number if provided
    if (phone != null && phone.isNotEmpty) {
      final snapshot = await _firestoreService.queryCollection(
        collection: _firestoreService.usersRef(),
        builder: (q) => q.where('phone', isEqualTo: phone).limit(1),
      );
      if (snapshot.docs.isNotEmpty) {
        throw Exception('Phone number already in use.');
      }
    }

    final credential = await _authService.register(
      email: email,
      password: password,
    );
    final user = AppUser(
      id: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
      address: address,
      birthday: birthday,
    );
    await _firestoreService.setDocument(
      collection: _firestoreService.usersRef(),
      docId: user.id,
      data: user.toMap(),
    );
    return user;
  }

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> logout() => _authService.signOut();

  Future<AppUser> fetchUser(String uid) => _loadUser(uid);

  Future<AppUser> _loadUser(String uid) async {
    final snapshot = await _firestoreService.getDocument(
      collection: _firestoreService.usersRef(),
      docId: uid,
    );
    return AppUser.fromMap(snapshot.id, snapshot.data() ?? {});
  }
}
