import 'dart:typed_data';

import '../models/activity_log.dart';
import '../models/booking.dart';
import '../models/pet.dart';
import 'activity_repository.dart';
import 'booking_repository.dart';
import 'pet_repository.dart';
import '../services/pdf_service.dart';

class ReportRepository {
  ReportRepository({
    required PetRepository petRepository,
    required BookingRepository bookingRepository,
    required ActivityRepository activityRepository,
    required PdfService pdfService,
  }) : _petRepository = petRepository,
       _bookingRepository = bookingRepository,
       _activityRepository = activityRepository,
       _pdfService = pdfService;

  final PetRepository _petRepository;
  final BookingRepository _bookingRepository;
  final ActivityRepository _activityRepository;
  final PdfService _pdfService;

  Future<Map<String, dynamic>> buildPetReport(
    String ownerId,
    String petId,
  ) async {
    final pets = await _petRepository.fetchPets(ownerId);
    final pet = pets.firstWhere((pet) => pet.id == petId);
    final bookings = await _bookingRepository.fetchOwnerBookings(ownerId);
    final petBookings = bookings
        .where((booking) => booking.petId == petId)
        .toList();
    final logs = await _activityRepository.fetchLogs(petId);
    return {'pet': pet, 'bookings': petBookings, 'activities': logs};
  }

  Future<Uint8List> buildPetReportPdf({
    required String ownerId,
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bookings = await _bookingRepository.fetchOwnerBookings(ownerId);
    final petBookings = bookings.where((b) => b.petId == petId).toList();

    final start = startDate != null
        ? DateTime(startDate.year, startDate.month, startDate.day)
        : null;
    final end = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999)
        : null;

    final filtered = petBookings.where((b) {
      final afterStart = start == null || !b.date.isBefore(start);
      final beforeEnd = end == null || !b.date.isAfter(end);
      return afterStart && beforeEnd;
    }).toList();

    final completed = filtered.where((b) => b.status == BookingStatus.completed).length;
    final upcoming = filtered.where((b) => b.status == BookingStatus.accepted && !b.date.isBefore(DateTime.now())).length;
    final pending = filtered.where((b) => b.status == BookingStatus.pending).length;

    final uniqueVets = filtered
      .where((b) => b.status == BookingStatus.completed)
      .map((b) => b.providerId)
      .toSet()
      .length;

    final stats = {
      'totalAppointments': filtered.length,
      'completed': completed,
      'upcoming': upcoming,
      'pending': pending,
      'uniqueVets': uniqueVets,
    };

    final pets = await _petRepository.fetchPets(ownerId);
    final pet = pets.firstWhere((p) => p.id == petId);

    final periodLabel = () {
      if (start == null && end == null) return 'All time';
      if (start != null && end == null) return 'From ${_fmtDate(start)}';
      if (start == null && end != null) return 'Until ${_fmtDate(end)}';
      return '${_fmtDate(start!)} - ${_fmtDate(end!)}';
    }();

    return _pdfService.buildPetReportDetailed(
      petName: pet.name,
      periodLabel: periodLabel,
      stats: stats,
      bookings: filtered,
    );
  }

  String formatOverview(
    Pet pet,
    List<Booking> bookings,
    List<ActivityLog> logs,
  ) {
    final appointments = bookings.length;
    final upcoming = bookings
        .where((b) => b.date.isAfter(DateTime.now()))
        .length;
    final activityCount = logs.length;
    return '''
Pet: ${pet.name}
Species: ${pet.species}
Total Appointments: $appointments
Upcoming Appointments: $upcoming
Activity Logs: $activityCount
''';
  }
  Future<Map<String, dynamic>> fetchVetStats(String vetId) async {
    final bookings = await _bookingRepository.fetchVetBookings(vetId);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final completed = bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final upcoming = bookings
        .where((b) {
          final isAccepted = b.status == BookingStatus.accepted;
          final isTodayOrFuture = !b.date.isBefore(todayStart);
          return isAccepted && isTodayOrFuture;
        })
        .length;
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    
    // Calculate unique pets treated (completed bookings only)
    final uniquePets = bookings
      .where((b) => b.status == BookingStatus.completed)
      .map((b) => b.petId)
      .toSet()
      .length;

    return {
      'totalAppointments': bookings.length,
      'completed': completed,
      'upcoming': upcoming,
      'pending': pending,
      'rejected': bookings.where((b) => b.status == BookingStatus.rejected || b.status == BookingStatus.cancelled).length,
      'uniquePets': uniquePets,
      'bookings': bookings,
    };
  }

  Future<Uint8List> buildVetReportPdf({
    required String vetId,
    required String clinicName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bookings = await _bookingRepository.fetchVetBookings(vetId);

    final start = startDate != null
        ? DateTime(startDate.year, startDate.month, startDate.day)
        : null;
    final end = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999)
        : null;

    final filtered = bookings.where((b) {
      final afterStart = start == null || !b.date.isBefore(start);
      final beforeEnd = end == null || !b.date.isAfter(end);
      return afterStart && beforeEnd;
    }).toList();

    final completed = filtered.where((b) => b.status == BookingStatus.completed).length;
    final upcoming = filtered.where((b) => b.status == BookingStatus.accepted && !b.date.isBefore(DateTime.now())).length;
    final pending = filtered.where((b) => b.status == BookingStatus.pending).length;
    final rejected = filtered.where((b) => b.status == BookingStatus.rejected || b.status == BookingStatus.cancelled).length;
    final uniquePets = filtered
        .where((b) => b.status == BookingStatus.completed)
        .map((b) => b.petId)
        .toSet()
        .length;

    final stats = {
      'totalAppointments': filtered.length,
      'completed': completed,
      'upcoming': upcoming,
      'pending': pending,
      'rejected': rejected,
      'uniquePets': uniquePets,
    };

    final periodLabel = () {
      if (start == null && end == null) return 'All time';
      if (start != null && end == null) return 'From ${_fmtDate(start)}';
      if (start == null && end != null) return 'Until ${_fmtDate(end)}';
      return '${_fmtDate(start!)} - ${_fmtDate(end!)}';
    }();

    return _pdfService.buildVetReportDetailed(
      clinicName: clinicName,
      periodLabel: periodLabel,
      stats: stats,
      bookings: filtered,
    );
  }

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> fetchSitterStats(String sitterId) async {
    final bookings = await _bookingRepository.fetchSitterBookings(sitterId);
    final completed = bookings.where((b) => b.status == BookingStatus.completed).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;

    // Calculate completion rate based on past appointments only (appointments that have occurred)
    final now = DateTime.now();
    final pastBookings = bookings.where((b) => !b.date.isAfter(now)).toList();
    final pastTotal = pastBookings.length;
    final pastCompleted = pastBookings.where((b) => b.status == BookingStatus.completed).length;
    final completionRate = pastTotal > 0 ? (pastCompleted / pastTotal) * 100 : 0.0;

    return {
      'totalJobs': bookings.length,
      'completed': completed,
      'pending': pending,
      'completionRate': completionRate,
      'bookings': bookings,
    };
  }

  Future<Uint8List> buildSitterReportPdf({
    required String sitterId,
    required String sitterName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bookings = await _bookingRepository.fetchSitterBookings(sitterId);

    final start = startDate != null
        ? DateTime(startDate.year, startDate.month, startDate.day)
        : null;
    final end = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999)
        : null;

    final filtered = bookings.where((b) {
      final afterStart = start == null || !b.date.isBefore(start);
      final beforeEnd = end == null || !b.date.isAfter(end);
      return afterStart && beforeEnd;
    }).toList();

    final completed = filtered.where((b) => b.status == BookingStatus.completed).length;
    final pending = filtered.where((b) => b.status == BookingStatus.pending).length;
    final total = filtered.length;

    // Compute completion rate based on past appointments in the filtered range
    final now = DateTime.now();
    final pastFiltered = filtered.where((b) => !b.date.isAfter(now)).toList();
    final pastTotal = pastFiltered.length;
    final pastCompleted = pastFiltered.where((b) => b.status == BookingStatus.completed).length;
    final stats = {
      'totalJobs': total,
      'completed': completed,
      'pending': pending,
      'completionRate': pastTotal > 0 ? (pastCompleted / pastTotal) * 100 : 0.0,
    };

    final periodLabel = () {
      if (start == null && end == null) return 'All time';
      if (start != null && end == null) return 'From ${_fmtDate(start)}';
      if (start == null && end != null) return 'Until ${_fmtDate(end)}';
      return '${_fmtDate(start!)} - ${_fmtDate(end!)}';
    }();

    // Reuse the vet detailed layout for sitter by passing sitterName and bookings
    return _pdfService.buildVetReportDetailed(
      clinicName: sitterName,
      periodLabel: periodLabel,
      stats: stats,
      bookings: filtered,
    );
  }
}
