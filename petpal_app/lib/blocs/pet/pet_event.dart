import 'package:equatable/equatable.dart';
import '../../models/pet_model.dart';
import 'dart:io';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class LoadPets extends PetEvent {
  final String ownerId;

  const LoadPets({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

class AddPet extends PetEvent {
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final File? photoFile;

  const AddPet({
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    this.photoFile,
  });

  @override
  List<Object?> get props => [ownerId, name, species, breed, age, photoFile];
}

class UpdatePet extends PetEvent {
  final PetModel pet;
  final File? newPhotoFile;

  const UpdatePet({
    required this.pet,
    this.newPhotoFile,
  });

  @override
  List<Object?> get props => [pet, newPhotoFile];
}

class DeletePet extends PetEvent {
  final String petId;

  const DeletePet({required this.petId});

  @override
  List<Object?> get props => [petId];
}

