import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Centralized Firebase service wrapper
class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Firestore collections
  CollectionReference<Map<String, dynamic>> usersCollection() =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> petsCollection() =>
      _firestore.collection('pets');

  CollectionReference<Map<String, dynamic>> bookingsCollection() =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> chatsCollection() =>
      _firestore.collection('chats');

  // Storage references
  Reference userPhotosRef() => _storage.ref('user_photos');
  Reference petPhotosRef() => _storage.ref('pet_photos');
  Reference medicalDocsRef() => _storage.ref('medical_docs');
  Reference vetCertificatesRef() => _storage.ref('vet_certificates');

  // Firestore helpers
  Future<void> setDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await collection.doc(docId).set(data, SetOptions(merge: merge));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) async {
    return await collection.doc(docId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) {
    return collection.doc(docId).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection({
    required CollectionReference<Map<String, dynamic>> collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        builder,
  }) async {
    final query = builder != null ? builder(collection) : collection;
    return await query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection({
    required CollectionReference<Map<String, dynamic>> collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        builder,
  }) {
    final query = builder != null ? builder(collection) : collection;
    return query.snapshots();
  }

  Future<void> deleteDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) async {
    await collection.doc(docId).delete();
  }
}

