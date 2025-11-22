import 'package:flutter_bloc/flutter_bloc.dart';
import 'pet_event.dart';
import 'pet_state.dart';
import '../../repositories/pet_repository.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository _petRepository;

  PetBloc({required PetRepository petRepository})
      : _petRepository = petRepository,
        super(const PetInitial()) {
    on<LoadPets>(_onLoadPets);
    on<AddPet>(_onAddPet);
    on<UpdatePet>(_onUpdatePet);
    on<DeletePet>(_onDeletePet);
  }

  Future<void> _onLoadPets(
    LoadPets event,
    Emitter<PetState> emit,
  ) async {
    emit(const PetLoading());
    try {
      final pets = await _petRepository.getPetsByOwner(event.ownerId);
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onAddPet(
    AddPet event,
    Emitter<PetState> emit,
  ) async {
    emit(const PetLoading());
    try {
      await _petRepository.createPet(
        ownerId: event.ownerId,
        name: event.name,
        species: event.species,
        breed: event.breed,
        age: event.age,
        photoFile: event.photoFile,
      );
      // Reload pets
      final pets = await _petRepository.getPetsByOwner(event.ownerId);
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePet(
    UpdatePet event,
    Emitter<PetState> emit,
  ) async {
    emit(const PetLoading());
    try {
      await _petRepository.updatePet(
        event.pet,
        newPhotoFile: event.newPhotoFile,
      );
      // Reload pets
      final pets = await _petRepository.getPetsByOwner(event.pet.ownerId);
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> _onDeletePet(
    DeletePet event,
    Emitter<PetState> emit,
  ) async {
    emit(const PetLoading());
    try {
      final pet = await _petRepository.getPet(event.petId);
      await _petRepository.deletePet(pet);
      // Reload pets
      final pets = await _petRepository.getPetsByOwner(pet.ownerId);
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }
}

