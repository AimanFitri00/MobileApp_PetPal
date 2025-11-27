import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

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
      emit(state.copyWith(isLoading: false, pets: pets));
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
      emit(state.copyWith(isLoading: false, pets: updated));
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
      final url = await _storageService.uploadFile(
        file: event.image,
        path: 'pets/${_uuid.v4()}',
      );
      emit(state.copyWith(isLoading: false, uploadedImageUrl: url));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
