import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> usersRef() =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> petsRef() =>
      _firestore.collection('pets');

  CollectionReference<Map<String, dynamic>> vetBookingsRef() =>
      _firestore.collection('vetBookings');

  CollectionReference<Map<String, dynamic>> sitterBookingsRef() =>
      _firestore.collection('sitterBookings');

  CollectionReference<Map<String, dynamic>> activityLogsRef() =>
      _firestore.collection('activityLogs');

  Future<void> setDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
    required Map<String, dynamic> data,
  }) => collection.doc(docId).set(data, SetOptions(merge: true));

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) => collection.doc(docId).get();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) => collection.doc(docId).snapshots();

  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection({
    required CollectionReference<Map<String, dynamic>> collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    builder,
  }) {
    final query = builder != null ? builder(collection) : collection;
    return query.get();
  }
}
