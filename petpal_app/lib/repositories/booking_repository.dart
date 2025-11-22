import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class BookingRepository {
  final FirebaseService _firebaseService;
  final Uuid _uuid = const Uuid();

  BookingRepository({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String ownerId,
    required String petId,
    required BookingType type,
    required DateTime startDateTime,
    DateTime? endDateTime,
    String? vetId,
    String? sitterId,
    String? clinicId,
    double? price,
    String? notes,
  }) async {
    try {
      final bookingId = _uuid.v4();

      final booking = BookingModel(
        id: bookingId,
        ownerId: ownerId,
        petId: petId,
        type: type,
        vetId: vetId,
        sitterId: sitterId,
        clinicId: clinicId,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        status: BookingStatus.pending,
        price: price,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _firebaseService.setDocument(
        collection: _firebaseService.bookingsCollection(),
        docId: booking.id,
        data: booking.toMap(),
        merge: false,
      );

      return booking;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get bookings for a user (owner, vet, or sitter)
  Future<List<BookingModel>> getBookingsForUser(String userId, UserRole role) async {
    try {
      Query<Map<String, dynamic>> query;

      if (role == UserRole.owner) {
        query = _firebaseService.bookingsCollection().where('ownerId', isEqualTo: userId);
      } else if (role == UserRole.vet) {
        query = _firebaseService.bookingsCollection().where('vetId', isEqualTo: userId);
      } else {
        query = _firebaseService.bookingsCollection().where('sitterId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  /// Stream bookings for a user (real-time updates)
  Stream<List<BookingModel>> watchBookingsForUser(String userId, UserRole role) {
    try {
      Query<Map<String, dynamic>> query;

      if (role == UserRole.owner) {
        query = _firebaseService.bookingsCollection().where('ownerId', isEqualTo: userId);
      } else if (role == UserRole.vet) {
        query = _firebaseService.bookingsCollection().where('vetId', isEqualTo: userId);
      } else {
        query = _firebaseService.bookingsCollection().where('sitterId', isEqualTo: userId);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList());
    } catch (e) {
      throw Exception('Failed to watch bookings: $e');
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      final snapshot = await _firebaseService.getDocument(
        collection: _firebaseService.bookingsCollection(),
        docId: bookingId,
      );

      if (!snapshot.exists) {
        throw Exception('Booking not found');
      }

      final booking = BookingModel.fromMap(snapshot.id, snapshot.data()!);
      final updatedBooking = booking.copyWith(status: status);

      await _firebaseService.setDocument(
        collection: _firebaseService.bookingsCollection(),
        docId: updatedBooking.id,
        data: updatedBooking.toMap(),
        merge: true,
      );
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  /// Get booking by ID
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final snapshot = await _firebaseService.getDocument(
        collection: _firebaseService.bookingsCollection(),
        docId: bookingId,
      );

      if (!snapshot.exists) {
        throw Exception('Booking not found');
      }

      return BookingModel.fromMap(snapshot.id, snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }
}

