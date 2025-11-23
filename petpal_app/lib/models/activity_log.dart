import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ActivityType { food, walk, medicine }

class ActivityLog extends Equatable {
  const ActivityLog({
    required this.id,
    required this.petId,
    required this.type,
    required this.timestamp,
    this.notes,
  });

  factory ActivityLog.fromMap(String id, Map<String, dynamic> data) {
    return ActivityLog(
      id: id,
      petId: data['petId'] ?? '',
      type: ActivityType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => ActivityType.food,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String?,
    );
  }

  final String id;
  final String petId;
  final ActivityType type;
  final DateTime timestamp;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'type': type.name,
      'timestamp': timestamp,
      'notes': notes,
    };
  }

  ActivityLog copyWith({
    String? id,
    String? petId,
    ActivityType? type,
    DateTime? timestamp,
    String? notes,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, petId, type, timestamp, notes];
}
