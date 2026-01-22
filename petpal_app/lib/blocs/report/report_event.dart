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

class VetReportExportRequested extends ReportEvent {
  const VetReportExportRequested({
    required this.vetId,
    required this.clinicName,
    this.startDate,
    this.endDate,
  });

  final String vetId;
  final String clinicName;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [vetId, clinicName, startDate, endDate];
}

class VetStatsRequested extends ReportEvent {
  const VetStatsRequested(this.vetId);

  final String vetId;

  @override
  List<Object?> get props => [vetId];
}

class VetReportExportCsvRequested extends ReportEvent {
  const VetReportExportCsvRequested({
    required this.vetId,
    required this.clinicName,
    this.startDate,
    this.endDate,
  });

  final String vetId;
  final String clinicName;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [vetId, clinicName, startDate, endDate];
}

class SitterStatsRequested extends ReportEvent {
  const SitterStatsRequested(this.sitterId);

  final String sitterId;

  @override
  List<Object?> get props => [sitterId];
}

class SitterReportExportRequested extends ReportEvent {
  const SitterReportExportRequested({required this.sitterId, required this.sitterName, this.startDate, this.endDate});

  final String sitterId;
  final String sitterName;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [sitterId, sitterName, startDate, endDate];
}
