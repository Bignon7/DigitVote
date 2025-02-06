import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  static Future<bool> sendEmail({
    required String recipientName,
    required String recipientEmail,
    required String subject,
    required String message,
    required String nomScrutin,
  }) async {
    const url = 'https://api.emailjs.com/api/v1.0/email/send';

    final headers = {
      'origin': 'http://localhost',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'service_id': 'service_700g465',
      'template_id': 'template_4u5jzpa',
      'user_id': 'OlORYoR-GvmgvnZRv',
      'template_params': {
        'from_name': 'Votify',
        'to_name': recipientName,
        'to_email': recipientEmail,
        'nom_scrutin': nomScrutin,
        'subject': subject,
        'message': message,
      }
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return true; // E-mail envoyé avec succès
      } else {
        print('Erreur lors de l\'envoi de l\'e-mail: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception lors de l\'envoi de l\'e-mail: $e');
      return false;
    }
  }

  //essayons l'envoi du code
  static Future<void> sendEmailWithCodeForCurrentUser(
      String code, String nomScrutin) async {
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? _userData;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          _userData = doc.data();
        } else {
          _userData = {};
        }
      } finally {
        String userEmail = user.email ?? 'hindemelais@gmail.com';
        String userName = _userData!['nom'] ?? 'Utilisateur inconnu';
        String scrutinTitre = nomScrutin;

        String subject = 'Code de sécurisation du scrutin';
        String body = ''' $code  ''';

        bool success = await sendEmail(
          recipientName: userName,
          recipientEmail: userEmail,
          subject: subject,
          message: body,
          nomScrutin: scrutinTitre,
        );

        if (success) {
          print('Email envoyé avec succès');
        } else {
          print('Échec de l\'envoi de l\'email');
        }
      }
    } else {
      print('Aucun utilisateur authentifié trouvé.');
    }
  }
}
