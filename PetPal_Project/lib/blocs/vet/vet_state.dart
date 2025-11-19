part of 'vet_bloc.dart';

class VetState extends Equatable {
  const VetState({
    required this.isLoading,
    required this.vets,
    this.errorMessage,
  });

  const VetState.initial() : this(isLoading: false, vets: const []);

  final bool isLoading;
  final List<VetProfile> vets;
  final String? errorMessage;

  VetState copyWith({
    bool? isLoading,
    List<VetProfile>? vets,
    String? errorMessage,
  }) {
    return VetState(
      isLoading: isLoading ?? this.isLoading,
      vets: vets ?? this.vets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, vets, errorMessage];
}
