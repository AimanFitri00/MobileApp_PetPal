import '../models/activity_log.dart';
import '../models/booking.dart';
import '../models/pet.dart';
import 'activity_repository.dart';
import 'booking_repository.dart';
import 'pet_repository.dart';

class ReportRepository {
  ReportRepository({
    required PetRepository petRepository,
    required BookingRepository bookingRepository,
    required ActivityRepository activityRepository,
  }) : _petRepository = petRepository,
       _bookingRepository = bookingRepository,
       _activityRepository = activityRepository;

  final PetRepository _petRepository;
  final BookingRepository _bookingRepository;
  final ActivityRepository _activityRepository;

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
    final completed = bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final upcoming = bookings
        .where((b) => b.status == BookingStatus.accepted && b.date.isAfter(DateTime.now()))
        .length;
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    
    // Calculate unique pets treated
    final uniquePets = bookings.map((b) => b.petId).toSet().length;

    return {
      'totalAppointments': bookings.length,
      'completed': completed,
      'upcoming': upcoming,
      'pending': pending,
      'uniquePets': uniquePets,
      'bookings': bookings,
    };
  }

  Future<Map<String, dynamic>> fetchSitterStats(String sitterId) async {
    final bookings = await _bookingRepository.fetchSitterBookings(sitterId);
    final completed = bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    
    // Calculate completion rate
    final total = bookings.length;
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    return {
      'totalJobs': total,
      'completed': completed,
      'pending': pending,
      'completionRate': completionRate,
      'bookings': bookings,
    };
  }
}
