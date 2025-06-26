import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// A shared upload service for nurse and patient profile photos.
/// Uploads images to Firebase Storage and returns the public download URL.
class PhotoUploadService {
  final FirebaseStorage _storage;

  PhotoUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads [file] to a profile-specific location and returns the download URL.
  ///
  /// - [type] is either 'users' or 'patients'
  /// - [id] is the userId or patientId
  /// - [filename] is usually 'avatar.jpg' (defaults to that)
  ///
  /// Throws on upload error.
  Future<String> uploadProfilePhoto({
    required File file,
    required String type,
    required String id,
    String filename = 'avatar.jpg',
  }) async {
    final path = '$type/$id/$filename';
    final ref = _storage.ref().child(path);

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }
}
