import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service
/// Handles file uploads and downloads
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns the download URL
  Future<String> uploadFile(
    File file,
    String path, {
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleFiles(
    List<File> files,
    String basePath,
  ) async {
    try {
      final urls = <String>[];

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
        final url = await uploadFile(file, '$basePath/$fileName');
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete file by URL
  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file by URL: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  /// List all files in a directory
  Future<ListResult> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.listAll();
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}


