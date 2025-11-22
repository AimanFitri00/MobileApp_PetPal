import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/messaging_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseService _firebaseService;
  final MessagingService _messagingService;

  AuthRepository({
    required AuthService authService,
    required FirebaseService firebaseService,
    required MessagingService messagingService,
  })  : _authService = authService,
        _firebaseService = firebaseService,
        _messagingService = messagingService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update FCM token
      await _updateFCMToken(credential.user!.uid);

      return await getUser(credential.user!.uid);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await _authService.updateDisplayName(name);

      // Create user document
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firebaseService.setDocument(
        collection: _firebaseService.usersCollection(),
        docId: user.id,
        data: user.toMap(),
        merge: false,
      );

      // Update FCM token
      await _updateFCMToken(user.id);

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Get user by ID
  Future<UserModel> getUser(String uid) async {
    try {
      final snapshot = await _firebaseService.getDocument(
        collection: _firebaseService.usersCollection(),
        docId: uid,
      );

      if (!snapshot.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(snapshot.id, snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _firebaseService.setDocument(
        collection: _firebaseService.usersCollection(),
        docId: user.id,
        data: user.toMap(),
        merge: true,
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Update FCM token
  Future<void> _updateFCMToken(String uid) async {
    try {
      final token = await _messagingService.getFCMToken();
      if (token != null) {
        final user = await getUser(uid);
        final updatedUser = user.copyWith(fcmToken: token);
        await updateUser(updatedUser);
      }
    } catch (e) {
      // Silently fail - token update is not critical
    }
  }
}

