part of 'pet_bloc.dart';

class PetState extends Equatable {
  const PetState({
    required this.isLoading,
    required this.pets,
    this.errorMessage,
    this.uploadedImageUrl,
  });

  const PetState.initial() : this(isLoading: false, pets: const []);

  final bool isLoading;
  final List<Pet> pets;
  final String? errorMessage;
  final String? uploadedImageUrl;

  PetState copyWith({
    bool? isLoading,
    List<Pet>? pets,
    String? errorMessage,
    String? uploadedImageUrl,
  }) {
    return PetState(
      isLoading: isLoading ?? this.isLoading,
      pets: pets ?? this.pets,
      errorMessage: errorMessage,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }

  @override
  List<Object?> get props => [isLoading, pets, errorMessage, uploadedImageUrl];
}
