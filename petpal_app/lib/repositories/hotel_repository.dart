import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_stay.dart';
import '../services/firestore_service.dart';

class HotelRepository {
  HotelRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  CollectionReference<Map<String, dynamic>> _hotelRef() =>
      _firestoreService.collection('hotel_stays');

  Future<void> addHotelStay(HotelStay stay) async {
    // If id is empty, generate one
    final docRef = _hotelRef().doc(stay.id.isEmpty ? null : stay.id);
    final stayWithId = stay.copyWith(id: docRef.id);
    await docRef.set(stayWithId.toMap());
  }

  Future<void> updateHotelStay(HotelStay stay) async {
    await _hotelRef().doc(stay.id).update(stay.toMap());
  }

  Stream<List<HotelStay>> getHotelStaysForVet(String vetId) {
    return _firestoreService.collectionStream(
      collection: _hotelRef(),
      builder: (q) => q.where('vetId', isEqualTo: vetId),
      fromMap: (id, data) => HotelStay.fromMap(id, data),
    );
  }

  Future<List<HotelStay>> getActiveStaysForVet(String vetId) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: _hotelRef(),
      builder: (q) => q
          .where('vetId', isEqualTo: vetId)
          .where('status', isEqualTo: 'checkIn'),
    );
    return snapshot.docs
        .map((doc) => HotelStay.fromMap(doc.id, doc.data()))
        .toList();
  }
}
