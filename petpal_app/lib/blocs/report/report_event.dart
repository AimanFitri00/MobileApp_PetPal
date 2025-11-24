part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class ReportRequested extends ReportEvent {
  const ReportRequested({required this.ownerId, required this.petId});

  final String ownerId;
  final String petId;

  @override
  List<Object?> get props => [ownerId, petId];
}

class ReportExportRequested extends ReportEvent {
  const ReportExportRequested();
}

class VetStatsRequested extends ReportEvent {
  const VetStatsRequested(this.vetId);

  final String vetId;

  @override
  List<Object?> get props => [vetId];
}

class SitterStatsRequested extends ReportEvent {
  const SitterStatsRequested(this.sitterId);

  final String sitterId;

  @override
  List<Object?> get props => [sitterId];
}
