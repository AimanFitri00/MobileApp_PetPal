import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PetModel extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String? photoUrl;
  final List<MedicalRecord> medicalHistory;
  final DateTime createdAt;

  const PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    this.photoUrl,
    this.medicalHistory = const [],
    required this.createdAt,
  });

  factory PetModel.fromMap(String id, Map<String, dynamic> map) {
    return PetModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      photoUrl: map['photoUrl'] as String?,
      medicalHistory: (map['medicalHistory'] as List<dynamic>?)
              ?.map((e) => MedicalRecord.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'photoUrl': photoUrl,
      'medicalHistory': medicalHistory.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PetModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? photoUrl,
    List<MedicalRecord>? medicalHistory,
    DateTime? createdAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        species,
        breed,
        age,
        photoUrl,
        medicalHistory,
        createdAt,
      ];
}

class MedicalRecord extends Equatable {
  final String id;
  final String type;
  final DateTime date;
  final String notes;
  final String? fileUrl;

  const MedicalRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.notes,
    this.fileUrl,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] ?? '',
      fileUrl: map['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'fileUrl': fileUrl,
    };
  }

  @override
  List<Object?> get props => [id, type, date, notes, fileUrl];
}

