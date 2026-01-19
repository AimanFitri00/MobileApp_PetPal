import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadFile({required File file, required String path}) async {
    final ref = _storage.ref(path);
    try {
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putFile(file, metadata);
      await uploadTask.whenComplete(() {});
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // Re-throw with clearer message for callers/logging
      throw FirebaseException(plugin: e.plugin, message: 'Storage upload failed: ${e.message}', code: e.code);
    }
  }

  Future<void> deleteFile(String path) => _storage.ref(path).delete();
}
