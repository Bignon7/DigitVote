import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  Future<void> fetchUserData(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _user = currentUser;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          _userData = doc.data();
        } else {
          _userData = {};
        }
      } catch (e) {
        debugPrint(
            "Erreur lors de la récupération des données utilisateur: $e");
        _showErrorDialog(context, e.toString());
        _userData = {};
      }

      notifyListeners();
    }
  }

  void clearUserData() {
    _user = null;
    _userData = null;
    notifyListeners();
  }

// Fonction pour afficher l'alerte en cas d'erreur
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(
          "Une erreur est survenue lors de la récupération des données utilisateur: $errorMessage",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
