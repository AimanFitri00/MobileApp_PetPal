import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class PetRepository {
  final FirebaseService _firebaseService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  PetRepository({
    required FirebaseService firebaseService,
    required StorageService storageService,
  })  : _firebaseService = firebaseService,
        _storageService = storageService;

  /// Get all pets for an owner
  Future<List<PetModel>> getPetsByOwner(String ownerId) async {
    try {
      final snapshot = await _firebaseService.queryCollection(
        collection: _firebaseService.petsCollection(),
        builder: (query) => query.where('ownerId', isEqualTo: ownerId),
      );

      return snapshot.docs
          .map((doc) => PetModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pets: $e');
    }
  }

  /// Stream pets for an owner (real-time updates)
  Stream<List<PetModel>> watchPetsByOwner(String ownerId) {
    try {
      return _firebaseService
          .watchCollection(
            collection: _firebaseService.petsCollection(),
            builder: (query) => query.where('ownerId', isEqualTo: ownerId),
          )
          .map((snapshot) => snapshot.docs
              .map((doc) => PetModel.fromMap(doc.id, doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Failed to watch pets: $e');
    }
  }

  /// Get pet by ID
  Future<PetModel> getPet(String petId) async {
    try {
      final snapshot = await _firebaseService.getDocument(
        collection: _firebaseService.petsCollection(),
        docId: petId,
      );

      if (!snapshot.exists) {
        throw Exception('Pet not found');
      }

      return PetModel.fromMap(snapshot.id, snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  /// Create a new pet
  Future<PetModel> createPet({
    required String ownerId,
    required String name,
    required String species,
    required String breed,
    required int age,
    File? photoFile,
  }) async {
    try {
      final petId = _uuid.v4();
      String? photoUrl;

      // Upload photo if provided
      if (photoFile != null) {
        photoUrl = await _storageService.uploadPetPhoto(
          petId: petId,
          file: photoFile,
        );
      }

      final pet = PetModel(
        id: petId,
        ownerId: ownerId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firebaseService.setDocument(
        collection: _firebaseService.petsCollection(),
        docId: pet.id,
        data: pet.toMap(),
        merge: false,
      );

      return pet;
    } catch (e) {
      throw Exception('Failed to create pet: $e');
    }
  }

  /// Update pet
  Future<void> updatePet(PetModel pet, {File? newPhotoFile}) async {
    try {
      String? photoUrl = pet.photoUrl;

      // Upload new photo if provided
      if (newPhotoFile != null) {
        // Delete old photo if exists
        if (photoUrl != null) {
          try {
            await _storageService.deleteFile(photoUrl);
          } catch (_) {
            // Ignore deletion errors
          }
        }

        photoUrl = await _storageService.uploadPetPhoto(
          petId: pet.id,
          file: newPhotoFile,
        );
      }

      final updatedPet = pet.copyWith(photoUrl: photoUrl);

      await _firebaseService.setDocument(
        collection: _firebaseService.petsCollection(),
        docId: updatedPet.id,
        data: updatedPet.toMap(),
        merge: true,
      );
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  /// Delete pet
  Future<void> deletePet(PetModel pet) async {
    try {
      // Delete photo if exists
      if (pet.photoUrl != null) {
        try {
          await _storageService.deleteFile(pet.photoUrl!);
        } catch (_) {
          // Ignore deletion errors
        }
      }

      await _firebaseService.deleteDocument(
        collection: _firebaseService.petsCollection(),
        docId: pet.id,
      );
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }

  /// Add medical record to pet
  Future<void> addMedicalRecord({
    required String petId,
    required String type,
    required String notes,
    File? file,
  }) async {
    try {
      final pet = await getPet(petId);
      final recordId = _uuid.v4();
      String? fileUrl;

      if (file != null) {
        fileUrl = await _storageService.uploadMedicalDoc(
          docId: recordId,
          file: file,
        );
      }

      final record = MedicalRecord(
        id: recordId,
        type: type,
        date: DateTime.now(),
        notes: notes,
        fileUrl: fileUrl,
      );

      final updatedHistory = [...pet.medicalHistory, record];
      final updatedPet = pet.copyWith(medicalHistory: updatedHistory);

      await _firebaseService.setDocument(
        collection: _firebaseService.petsCollection(),
        docId: updatedPet.id,
        data: updatedPet.toMap(),
        merge: true,
      );
    } catch (e) {
      throw Exception('Failed to add medical record: $e');
    }
  }
}

