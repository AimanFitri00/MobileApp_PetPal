import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/pet.dart';
import '../../repositories/pet_repository.dart';
import '../../services/storage_service.dart';

part 'pet_event.dart';
part 'pet_state.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  PetBloc({
    required PetRepository petRepository,
    required StorageService storageService,
  })  : _petRepository = petRepository,
        _storageService = storageService,
        super(const PetState.initial()) {
    on<PetsRequested>(_onPetsRequested);
    on<PetCreated>(_onPetCreated);
    on<PetUpdated>(_onPetUpdated);
    on<PetDeleted>(_onPetDeleted);
    on<PetImageSelected>(_onImageSelected);
  }

  final PetRepository _petRepository;
  final StorageService _storageService;
  final _uuid = const Uuid();

  Future<void> _onPetsRequested(
    PetsRequested event,
    Emitter<PetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final pets = await _petRepository.fetchPets(event.ownerId);
      // overlay any locally persisted pet images (local-only previews)
      final prefs = await SharedPreferences.getInstance();
      final updated = pets.map((p) {
        final key = 'local_pet_image_${p.id}';
        final localPath = prefs.getString(key);
        if (localPath != null && localPath.isNotEmpty) {
          return p.copyWith(imageUrl: localPath);
        }
        return p;
      }).toList();
      emit(state.copyWith(isLoading: false, pets: updated, uploadedImageUrl: ''));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onPetCreated(PetCreated event, Emitter<PetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final pet = event.pet.id.isEmpty
          ? event.pet.copyWith(id: _uuid.v4())
          : event.pet;
      await _petRepository.createPet(pet);
      final updated = List<Pet>.from(state.pets)..add(pet);
      // Persist local pet image path if it's a local file
      try {
        final prefs = await SharedPreferences.getInstance();
        if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty) {
          final f = File(pet.imageUrl!);
          if (f.existsSync()) {
            await prefs.setString('local_pet_image_${pet.id}', pet.imageUrl!);
          }
        }
      } catch (_) {}
      emit(state.copyWith(isLoading: false, pets: updated, uploadedImageUrl: ''));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onPetUpdated(PetUpdated event, Emitter<PetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _petRepository.updatePet(event.pet);
      final updated = state.pets
          .map((pet) => pet.id == event.pet.id ? event.pet : pet)
          .toList();
      // Persist local pet image path if it's a local file
      try {
        final prefs = await SharedPreferences.getInstance();
        if (event.pet.imageUrl != null && event.pet.imageUrl!.isNotEmpty) {
          final f = File(event.pet.imageUrl!);
          if (f.existsSync()) {
            await prefs.setString('local_pet_image_${event.pet.id}', event.pet.imageUrl!);
          }
        }
      } catch (_) {}
      emit(state.copyWith(isLoading: false, pets: updated));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onPetDeleted(PetDeleted event, Emitter<PetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _petRepository.deletePet(event.petId);
      final updated = state.pets.where((pet) => pet.id != event.petId).toList();
      emit(state.copyWith(isLoading: false, pets: updated));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onImageSelected(
    PetImageSelected event,
    Emitter<PetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Copy selected image to a stable local temp path for local-only preview
      final dest = File('${Directory.systemTemp.path}/petpal_pet_${_uuid.v4()}.jpg');
      await event.image.copy(dest.path);
      emit(state.copyWith(isLoading: false, uploadedImageUrl: dest.path));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
