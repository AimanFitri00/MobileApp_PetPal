import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/report_repository.dart';
import '../../services/pdf_service.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc({
    required ReportRepository reportRepository,
    required PdfService pdfService,
  }) : _reportRepository = reportRepository,
       _pdfService = pdfService,
       super(const ReportState.initial()) {
    on<ReportRequested>(_onRequested);
    on<ReportExportRequested>(_onExportRequested);
    on<VetStatsRequested>(_onVetStatsRequested);
    on<SitterStatsRequested>(_onSitterStatsRequested);
    on<VetReportExportRequested>(_onVetReportExportRequested);
    on<SitterReportExportRequested>(_onSitterReportExportRequested);
  }

  final ReportRepository _reportRepository;
  final PdfService _pdfService;

  Future<void> _onVetStatsRequested(
    VetStatsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final stats = await _reportRepository.fetchVetStats(event.vetId);
      emit(state.copyWith(isLoading: false, reportData: stats));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onSitterStatsRequested(
    SitterStatsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final stats = await _reportRepository.fetchSitterStats(event.sitterId);
      emit(state.copyWith(isLoading: false, reportData: stats));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onRequested(
    ReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final map = await _reportRepository.buildPetReport(
        event.ownerId,
        event.petId,
      );
      emit(state.copyWith(isLoading: false, reportData: map));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onExportRequested(
    ReportExportRequested event,
    Emitter<ReportState> emit,
  ) async {
    if (state.reportData == null) return;
    emit(state.copyWith(isExporting: true));
    try {
      final pet = state.reportData!['pet'];
      final bookings = state.reportData!['bookings'] as List;
      // Use repository method to build a detailed pet PDF (same style as vet report)
      final bytes = await _reportRepository.buildPetReportPdf(
        ownerId: pet.ownerId ?? '',
        petId: pet.id,
      );
      emit(state.copyWith(isExporting: false, exportedBytes: bytes));
    } catch (error) {
      emit(state.copyWith(isExporting: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onVetReportExportRequested(
    VetReportExportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await _reportRepository.buildVetReportPdf(
        vetId: event.vetId,
        clinicName: event.clinicName,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(isExporting: false, exportedBytes: bytes));
    } catch (error) {
      emit(state.copyWith(isExporting: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onSitterReportExportRequested(
    SitterReportExportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await _reportRepository.buildSitterReportPdf(
        sitterId: event.sitterId,
        sitterName: event.sitterName,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(isExporting: false, exportedBytes: bytes));
    } catch (error) {
      emit(state.copyWith(isExporting: false, errorMessage: error.toString()));
    }
  }
}
