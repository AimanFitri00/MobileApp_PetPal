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
