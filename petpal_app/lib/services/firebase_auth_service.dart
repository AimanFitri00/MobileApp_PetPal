import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  Future<UserCredential> register({
    required String email,
    required String password,
  }) => _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  Future<void> sendPasswordResetEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _firebaseAuth.signOut();

  User? get currentUser => _firebaseAuth.currentUser;
}
