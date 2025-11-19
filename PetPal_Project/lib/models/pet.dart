import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    this.medicalHistory,
    this.imageUrl,
  });

  factory Pet.fromMap(String id, Map<String, dynamic> data) {
    return Pet(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      medicalHistory: data['medicalHistory'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final String age;
  final String? medicalHistory;
  final String? imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'medicalHistory': medicalHistory,
      'imageUrl': imageUrl,
    };
  }

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    String? age,
    String? medicalHistory,
    String? imageUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      imageUrl: imageUrl ?? this.imageUrl,
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
    medicalHistory,
    imageUrl,
  ];
}
