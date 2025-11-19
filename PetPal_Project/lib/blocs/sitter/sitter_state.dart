part of 'sitter_bloc.dart';

class SitterState extends Equatable {
  const SitterState({
    required this.isLoading,
    required this.sitters,
    this.errorMessage,
  });

  const SitterState.initial() : this(isLoading: false, sitters: const []);

  final bool isLoading;
  final List<SitterProfile> sitters;
  final String? errorMessage;

  SitterState copyWith({
    bool? isLoading,
    List<SitterProfile>? sitters,
    String? errorMessage,
  }) {
    return SitterState(
      isLoading: isLoading ?? this.isLoading,
      sitters: sitters ?? this.sitters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, sitters, errorMessage];
}
