part of 'vet_bloc.dart';

abstract class VetEvent extends Equatable {
  const VetEvent();

  @override
  List<Object?> get props => [];
}

class VetsRequested extends VetEvent {
  const VetsRequested({this.location, this.specialization});

  final String? location;
  final String? specialization;

  @override
  List<Object?> get props => [location, specialization];
}
