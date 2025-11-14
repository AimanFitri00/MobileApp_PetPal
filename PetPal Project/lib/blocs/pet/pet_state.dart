part of 'pet_bloc.dart';

class PetState extends Equatable {
  const PetState({
    required this.isLoading,
    required this.pets,
    this.errorMessage,
  });

  const PetState.initial() : this(isLoading: false, pets: const []);

  final bool isLoading;
  final List<Pet> pets;
  final String? errorMessage;

  PetState copyWith({bool? isLoading, List<Pet>? pets, String? errorMessage}) {
    return PetState(
      isLoading: isLoading ?? this.isLoading,
      pets: pets ?? this.pets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, pets, errorMessage];
}
