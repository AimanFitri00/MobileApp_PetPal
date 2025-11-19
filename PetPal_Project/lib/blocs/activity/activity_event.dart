part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class ActivityLogsRequested extends ActivityEvent {
  const ActivityLogsRequested(this.petId);

  final String petId;

  @override
  List<Object?> get props => [petId];
}

class ActivityLogged extends ActivityEvent {
  const ActivityLogged(this.log);

  final ActivityLog log;

  @override
  List<Object?> get props => [log];
}
