import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // *Authentification*
  Future<User?> inscrireUtilisateur(
      String email, String password, String nom) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'nom': nom,
        'email': email,
        'image_url': '',
        'date_inscription': FieldValue.serverTimestamp(),
        'scrutins_crees': [],
        'votes': [],
      });
      await sendEmailVerification();
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      return null;
    }
  }

  Future<User?> inscrireUtilisateurGoogle(
      String email, String displayName) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'id': currentUser.uid,
          'nom': displayName,
          'email': email,
          'image_url': currentUser.photoURL ?? '',
          'date_inscription': FieldValue.serverTimestamp(),
          'scrutins_crees': [],
          'votes': [],
        });

        return currentUser;
      }

      return null;
    } catch (e) {
      print('Erreur lors de l\'inscription avec Google : $e');
      return null;
    }
  }

  Future<User?> connecterUtilisateur(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        return null;
      }
      return user;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  Future<void> deconnecterUtilisateur() async {
    await _auth.signOut();
  }

  // Vérifier si l'email est vérifié
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Pour renvoyer un email de vérification
  Future<void> resendVerificationEmail() async {
    await sendEmailVerification();
  }

  // Envoyer email de reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
