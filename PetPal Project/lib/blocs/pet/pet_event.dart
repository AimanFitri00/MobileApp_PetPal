part of 'pet_bloc.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class PetsRequested extends PetEvent {
  const PetsRequested(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

class PetCreated extends PetEvent {
  const PetCreated(this.pet);

  final Pet pet;

  @override
  List<Object?> get props => [pet];
}

class PetUpdated extends PetEvent {
  const PetUpdated(this.pet);

  final Pet pet;

  @override
  List<Object?> get props => [pet];
}

class PetDeleted extends PetEvent {
  const PetDeleted(this.petId);

  final String petId;

  @override
  List<Object?> get props => [petId];
}
