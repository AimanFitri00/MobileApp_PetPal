import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BookingType { vet, sitter }

enum BookingStatus { pending, accepted, completed, cancelled, rejected } // Added rejected

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.ownerId,
    required this.petId,
    required this.providerId,
    required this.date,
    required this.status,
    required this.type,
    this.petName = '',
    this.petImageUrl,
    this.time,
    this.notes,
    this.endDate,
    this.serviceType,
    this.rejectionReason,
  });

  factory Booking.vet({
    required String id,
    required String ownerId,
    required String petId,
    required String vetId,
    required DateTime date,
    required BookingStatus status,
    String? petName,
    String? petImageUrl,
    String? time,
    String? notes,
  }) {
    return Booking(
      id: id,
      ownerId: ownerId,
      petId: petId,
      providerId: vetId,
      date: date,
      status: status,
      time: time,
      notes: notes,
      type: BookingType.vet,
      petName: petName ?? '',
      petImageUrl: petImageUrl,
    );
  }

  factory Booking.sitter({
    required String id,
    required String ownerId,
    required String petId,
    required String sitterId,
    required DateTime startDate,
    required DateTime endDate,
    required BookingStatus status,
    String? petName,
    String? petImageUrl,
    String? notes,
    String? serviceType,
  }) {
    return Booking(
      id: id,
      ownerId: ownerId,
      petId: petId,
      providerId: sitterId,
      date: startDate,
      endDate: endDate,
      status: status,
      notes: notes,
      type: BookingType.sitter,
      petName: petName ?? '',
      petImageUrl: petImageUrl,
      serviceType: serviceType,
    );
  }

  factory Booking.fromMap(
    String id,
    Map<String, dynamic> data,
    BookingType type,
  ) {
    return Booking(
      id: id,
      ownerId: data['ownerId'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrl: data['petImageUrl'],
      providerId: type == BookingType.vet
          ? data['vetId'] ?? ''
          : data['sitterId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      time: data['time'] as String?,
      notes: data['notes'] as String?,
      serviceType: data['serviceType'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      status: BookingStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      type: type,
    );
  }

  final String id;
  final String ownerId;
  final String petId;
  final String petName;
  final String? petImageUrl;
  final String providerId;
  final DateTime date;
  final DateTime? endDate;
  final BookingStatus status;
  final BookingType type;
  final String? time;
  final String? notes;
  final String? serviceType;
  final String? rejectionReason;

  Map<String, dynamic> toMap() {
    final map = {
      'ownerId': ownerId,
      'petId': petId,
      'petName': petName,
      'petImageUrl': petImageUrl,
      'date': date,
      'status': status.name,
      'notes': notes,
      'serviceType': serviceType,
      'rejectionReason': rejectionReason,
    };

    if (type == BookingType.vet) {
      map.addAll({'vetId': providerId, 'time': time});
    } else {
      map.addAll({'sitterId': providerId, 'endDate': endDate});
    }
    return map;
  }

  Booking copyWith({
    String? id,
    String? ownerId,
    String? petId,
    String? petName,
    String? petImageUrl,
    String? providerId,
    DateTime? date,
    DateTime? endDate,
    BookingStatus? status,
    BookingType? type,
    String? time,
    String? notes,
    String? serviceType,
    String? rejectionReason,
  }) {
    return Booking(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      providerId: providerId ?? this.providerId,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      type: type ?? this.type,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      serviceType: serviceType ?? this.serviceType,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    petId,
    petName,
    petImageUrl,
    providerId,
    date,
    endDate,
    status,
    type,
    time,
    notes,
    serviceType,
    rejectionReason,
  ];
}
