import '../models/pet.dart';
import '../services/firestore_service.dart';

class PetRepository {
  PetRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> createPet(Pet pet) {
    return _firestoreService.setDocument(
      collection: _firestoreService.petsRef(),
      docId: pet.id,
      data: pet.toMap(),
    );
  }

  Future<List<Pet>> fetchPets(String ownerId) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: _firestoreService.petsRef(),
      builder: (query) => query.where('ownerId', isEqualTo: ownerId),
    );
    return snapshot.docs.map((doc) => Pet.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> updatePet(Pet pet) {
    return _firestoreService.setDocument(
      collection: _firestoreService.petsRef(),
      docId: pet.id,
      data: pet.toMap(),
    );
  }

  Future<void> deletePet(String petId) {
    return _firestoreService.petsRef().doc(petId).delete();
  }
}
