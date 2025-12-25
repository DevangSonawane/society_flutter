import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String _bucket = 'documents';
  static const _uuid = Uuid();

  /// Upload a file to Supabase Storage
  /// Returns the public URL of the uploaded file
  static Future<String?> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      // Generate unique filename if not provided
      final String fileExtension = file.path.split('.').last;
      final String finalFileName = fileName ?? 
          '${_uuid.v4()}.$fileExtension';
      
      final String filePath = '$folder/$finalFileName';
      
      // Read file bytes
      final bytes = await file.readAsBytes();
      
      // Upload to Supabase Storage
      await _client.storage.from(_bucket).uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'application/octet-stream',
        ),
      );
      
      // Get public URL
      final String publicUrl = _client.storage.from(_bucket).getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Pick a file using file_picker
  /// Returns the selected file or null if cancelled
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Pick multiple files
  static Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        allowMultiple: true,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  /// Delete a file from Supabase Storage
  static Future<bool> deleteFile(String filePath) async {
    try {
      await _client.storage.from(_bucket).remove([filePath]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

