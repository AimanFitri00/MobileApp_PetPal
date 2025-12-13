import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum HotelStayStatus { checkIn, checkOut }

class HotelStay extends Equatable {
  const HotelStay({
    required this.id,
    required this.vetId,
    required this.petId,
    required this.petName,
    required this.petImageUrl,
    required this.ownerId, // Can be null if manual add, but for string we check isEmpty
    required this.checkInDate,
    required this.status,
    this.checkOutDate,
    this.ownerName,
    this.ownerPhone,
    this.notes,
  });

  factory HotelStay.fromMap(String id, Map<String, dynamic> data) {
    return HotelStay(
      id: id,
      vetId: data['vetId'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrl: data['petImageUrl'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'],
      ownerPhone: data['ownerPhone'],
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp?)?.toDate(),
      status: HotelStayStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => HotelStayStatus.checkIn,
      ),
      notes: data['notes'],
    );
  }

  final String id;
  final String vetId;
  final String petId;
  final String petName;
  final String? petImageUrl;
  final String ownerId; // If empty, means manually added by vet without linking user
  final String? ownerName; // For display
  final String? ownerPhone; // For display
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final HotelStayStatus status;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'vetId': vetId,
      'petId': petId,
      'petName': petName,
      'petImageUrl': petImageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': checkOutDate != null ? Timestamp.fromDate(checkOutDate!) : null,
      'status': status.name,
      'notes': notes,
    };
  }

  HotelStay copyWith({
    String? id,
    String? vetId,
    String? petId,
    String? petName,
    String? petImageUrl,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    HotelStayStatus? status,
    String? notes,
  }) {
    return HotelStay(
      id: id ?? this.id,
      vetId: vetId ?? this.vetId,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vetId,
    petId,
    petName,
    petImageUrl,
    ownerId,
    ownerName,
    ownerPhone,
    checkInDate,
    checkOutDate,
    status,
    notes,
  ];
}
