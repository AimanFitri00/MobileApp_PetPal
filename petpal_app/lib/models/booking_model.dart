import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BookingType { vet, sitter }
enum BookingStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

class BookingModel extends Equatable {
  final String id;
  final String ownerId;
  final String petId;
  final BookingType type;
  final String? vetId;
  final String? sitterId;
  final String? clinicId;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final BookingStatus status;
  final double? price;
  final String? notes;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.ownerId,
    required this.petId,
    required this.type,
    this.vetId,
    this.sitterId,
    this.clinicId,
    required this.startDateTime,
    this.endDateTime,
    required this.status,
    this.price,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      petId: map['petId'] ?? '',
      type: BookingType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => BookingType.vet,
      ),
      vetId: map['vetId'] as String?,
      sitterId: map['sitterId'] as String?,
      clinicId: map['clinicId'] as String?,
      startDateTime: (map['startDateTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      endDateTime: (map['endDateTime'] as Timestamp?)?.toDate(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name.toUpperCase() == map['status']?.toString().toUpperCase(),
        orElse: () => BookingStatus.pending,
      ),
      price: (map['price'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'petId': petId,
      'type': type.name,
      'vetId': vetId,
      'sitterId': sitterId,
      'clinicId': clinicId,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': endDateTime != null ? Timestamp.fromDate(endDateTime!) : null,
      'status': status.name.toUpperCase(),
      'price': price,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? ownerId,
    String? petId,
    BookingType? type,
    String? vetId,
    String? sitterId,
    String? clinicId,
    DateTime? startDateTime,
    DateTime? endDateTime,
    BookingStatus? status,
    double? price,
    String? notes,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      vetId: vetId ?? this.vetId,
      sitterId: sitterId ?? this.sitterId,
      clinicId: clinicId ?? this.clinicId,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        petId,
        type,
        vetId,
        sitterId,
        clinicId,
        startDateTime,
        endDateTime,
        status,
        price,
        notes,
        createdAt,
      ];
}

