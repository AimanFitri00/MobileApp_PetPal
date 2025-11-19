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
  }

  final ReportRepository _reportRepository;
  final PdfService _pdfService;

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
      final bookings = state.reportData!['bookings'];
      final logs = state.reportData!['activities'];
      final overview = _reportRepository.formatOverview(pet, bookings, logs);
      final bytes = await _pdfService.buildPetReport(
        petName: pet.name,
        sections: [overview],
      );
      emit(state.copyWith(isExporting: false, exportedBytes: bytes));
    } catch (error) {
      emit(state.copyWith(isExporting: false, errorMessage: error.toString()));
    }
  }
}
