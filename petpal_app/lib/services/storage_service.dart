import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;

  StorageService({
    FirebaseStorage? storage,
    ImagePicker? imagePicker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _imagePicker = imagePicker ?? ImagePicker();

  /// Pick an image from gallery or camera
  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxSizeMB = 5,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Compress to reduce size
      );

      if (image != null) {
        final file = File(image.path);
        final sizeInMB = await file.length() / (1024 * 1024);
        
        if (sizeInMB > maxSizeMB) {
          throw Exception('Image size exceeds ${maxSizeMB}MB limit');
        }
      }

      return image;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload user profile photo
  Future<String> uploadUserPhoto({
    required String userId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('user_photos/$userId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload user photo: $e');
    }
  }

  /// Upload pet photo
  Future<String> uploadPetPhoto({
    required String petId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('pet_photos/$petId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload pet photo: $e');
    }
  }

  /// Upload medical document
  Future<String> uploadMedicalDoc({
    required String docId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('medical_docs/$docId.pdf');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload medical document: $e');
    }
  }

  /// Upload vet certificate
  Future<String> uploadVetCertificate({
    required String userId,
    required String fileName,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('vet_certificates/$userId/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload vet certificate: $e');
    }
  }

  /// Upload chat image
  Future<String> uploadChatImage({
    required String chatId,
    required String messageId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref('chat_images/$chatId/$messageId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}

