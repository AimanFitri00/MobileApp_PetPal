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
    final credential = await _authService.signIn(
      email: email,
      password: password,
    );
    return _loadUser(credential.user!.uid);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _authService.register(
      email: email,
      password: password,
    );
    final user = AppUser(
      id: credential.user!.uid,
      name: name,
      email: email,
      role: role,
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
