part of 'sitter_bloc.dart';

abstract class SitterEvent extends Equatable {
  const SitterEvent();

  @override
  List<Object?> get props => [];
}

class SittersRequested extends SitterEvent {
  const SittersRequested({this.location});

  final String? location;

  @override
  List<Object?> get props => [location];
}
