import '../models/activity_log.dart';
import '../services/firestore_service.dart';

class ActivityRepository {
  ActivityRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> logActivity(ActivityLog log) {
    return _firestoreService.setDocument(
      collection: _firestoreService.activityLogsRef(),
      docId: log.id,
      data: log.toMap(),
    );
  }

  Future<List<ActivityLog>> fetchLogs(String petId) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.activityLogsRef(),
      builder: (query) => query.where('petId', isEqualTo: petId),
    );
    return snapshot.docs
        .map((doc) => ActivityLog.fromMap(doc.id, doc.data()))
        .toList();
  }
}
