import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.isVaccinated,
    this.allergies,
    this.medicalConditions,
    this.medicalHistory, // Mapped to 'medicalNotes' in requirements, keeping existing name to minimize refactor risk unless requested
    this.imageUrl,
    this.createdAt,
  });

  factory Pet.fromMap(String id, Map<String, dynamic> data) {
    return Pet(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '0', // Changed to display '0' if null
      gender: data['gender'] ?? 'Unknown',
      weight: (data['weight'] ?? 0).toDouble(),
      isVaccinated: data['isVaccinated'] ?? false,
      allergies: data['allergies'] as String?,
      medicalConditions: data['medicalConditions'] as String?,
      medicalHistory: data['medicalNotes'] as String? ?? data['medicalHistory'] as String?, // Fallback for backward compatibility
      imageUrl: data['imageUrl'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final String age; 
  final String gender;
  final double weight;
  final bool isVaccinated;
  final String? allergies;
  final String? medicalConditions;
  final String? medicalHistory; // Renamed to Notes in UI but kept for consistency
  final String? imageUrl;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'weight': weight,
      'isVaccinated': isVaccinated,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medicalNotes': medicalHistory, // Store as medicalNotes per requirement
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    String? age,
    String? gender,
    double? weight,
    bool? isVaccinated,
    String? allergies,
    String? medicalConditions,
    String? medicalHistory,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      imageUrl: imageUrl ?? this.imageUrl,
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
    gender,
    weight,
    isVaccinated,
    allergies,
    medicalConditions,
    medicalHistory,
    imageUrl,
    createdAt,
  ];
}
