import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadImageForScrutin({
    required File file,
    required String bucketName,
    required BuildContext context,
  }) async {
    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      if (!_isValidImageExtension(fileExtension)) {
        _showErrorDialog(
            context, 'Seuls les fichiers JPG, JPEG et PNG sont acceptés.');
        return null;
      }
      final fileName =
          'scrutins/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final response =
          await _client.storage.from(bucketName).upload(fileName, file);
      if (response.isEmpty) {
        throw Exception('Erreur lors du téléchargement de l\'image');
      }
      final tempsValidite = (100 * 365.25 * 24 * 60 * 60).toInt();
      //final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);
      final signedUrl = await _client.storage
          .from(bucketName)
          .createSignedUrl(fileName, tempsValidite);

      return signedUrl;
    } catch (e) {
      _showErrorDialog(context, 'Erreur lors de l\'upload : $e');
      return null;
    }
  }

  Future<String?> uploadImageForCandidat({
    required File file,
    required String bucketName,
    required BuildContext context,
  }) async {
    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      if (!_isValidImageExtension(fileExtension)) {
        _showErrorDialog(
            context, 'Seuls les fichiers JPG, JPEG et PNG sont acceptés.');
        return null;
      }
      final fileName =
          'candidats/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final response =
          await _client.storage.from(bucketName).upload(fileName, file);
      if (response.isEmpty) {
        throw Exception('Erreur lors du téléchargement de l\'image');
      }
      final tempsValidite = (100 * 365.25 * 24 * 60 * 60).toInt();
      final signedUrl = await _client.storage
          .from(bucketName)
          .createSignedUrl(fileName, tempsValidite);

      return signedUrl;
    } catch (e) {
      _showErrorDialog(context, 'Erreur lors de l\'upload : $e');
      return null;
    }
  }

  bool _isValidImageExtension(String extension) {
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String getPublicUrl(String filePath, String bucketName) {
    return _client.storage.from(bucketName).getPublicUrl(filePath);
  }

  // Future<bool> deleteFile(String filePath, String bucketName) async {
  //   try {
  //     final response = await _client.storage.from(bucketName).remove([filePath]);
  //     if (response.error == null) {
  //       return true;
  //     } else {
  //       throw Exception('Erreur lors de la suppression : ${response.error?.message}');
  //     }
  //   } catch (e) {
  //     print('Erreur Supabase : $e');
  //     return false;
  //   }
  // }
}
