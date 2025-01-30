import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // *Authentification*
  // Future<User?> inscrireUtilisateur(
  //     String email, String password, String nom) async {
  //   try {
  //     // Création d'un utilisateur avec Firebase Auth
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     // Ajout des détails de l'utilisateur dans Firestore
  //     await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //       'email': email,
  //       'nom': nom,
  //       'date_inscription': FieldValue.serverTimestamp(),
  //       'scrutins_crees': [],
  //       'votes': [],
  //     });

  //     return userCredential.user;
  //   } catch (e) {
  //     print('Erreur lors de l\'inscription : $e');
  //     return null;
  //   }
  // }

  Future<User?> inscrireUtilisateur(
      String email, String password, String nom) async {
    try {
      // Création d'un utilisateur avec Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ajout des détails de l'utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'nom': nom,
        'email': email,
        'image_url': '',
        'date_inscription': FieldValue.serverTimestamp(),
        'scrutins_crees': [],
        'votes': [],
      });

      return userCredential.user;
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      return null;
    }
  }

  Future<User?> inscrireUtilisateurGoogle(
      String email, String displayName) async {
    try {
      // L'utilisateur est déjà créé par Firebase Auth lors de la connexion Google
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Ajout des détails de l'utilisateur dans Firestore avec la même structure
        await _firestore.collection('users').doc(currentUser.uid).set({
          'id': currentUser.uid,
          'nom': displayName,
          'email': email,
          'image_url': currentUser.photoURL ??
              '', // On utilise la photo Google si disponible
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
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  Future<void> deconnecterUtilisateur() async {
    await _auth.signOut();
  }

  // *Scrutins*
  Future<String?> creerScrutin(
    String titre,
    String description,
    DateTime dateOuverture,
    DateTime dateCloture,
    List<String> nomsCandidats,
  ) async {
    try {
      String userId = _auth.currentUser!.uid;

      // Création du scrutin dans Firestore
      DocumentReference scrutinRef =
          await _firestore.collection('scrutins').add({
        'titre': titre,
        'description': description,
        'date_ouverture': dateOuverture,
        'date_cloture': dateCloture,
        'candidats': [], // Initialise le tableau vide
        'votes': [],
        'creator_id': userId,
      });

      // Liste pour stocker les IDs des candidats
      List<String> candidatsIds = [];

      // Ajout des candidats à la collection candidats
      for (String nomCandidat in nomsCandidats) {
        DocumentReference candidatRef =
            await _firestore.collection('candidats').add({
          'nom': nomCandidat,
          'scrutin_id': scrutinRef.id,
        });
        candidatsIds.add(candidatRef.id); // Stocke l'ID du candidat
      }

      // Mise à jour du tableau candidats dans le document du scrutin
      await scrutinRef.update({
        'candidats': FieldValue.arrayUnion(candidatsIds),
      });

      // Mise à jour du tableau scrutins_crees dans le document de l'utilisateur
      await _firestore.collection('users').doc(userId).update({
        'scrutins_crees': FieldValue.arrayUnion([scrutinRef.id]),
      });

      print('Scrutin créé avec succès et candidats ajoutés.');
      return scrutinRef.id;
    } catch (e) {
      print('Erreur lors de la création du scrutin : $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> recupererScrutins() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('scrutins').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des scrutins : $e');
      return [];
    }
  }

  // *Votes*
  Future<bool> voter(String scrutinId, String candidatId) async {
    try {
      String userId = _auth.currentUser!.uid;

      // Vérifier si l'utilisateur a déjà voté pour ce scrutin
      QuerySnapshot existingVote = await _firestore
          .collection('votes')
          .where('electeur_id', isEqualTo: userId)
          .where('scrutin_id', isEqualTo: scrutinId)
          .get();

      if (existingVote.docs.isNotEmpty) {
        print('Erreur : Vous avez déjà voté pour ce scrutin.');
        return false;
      }

      // Ajouter un vote
      DocumentReference voteRef = await _firestore.collection('votes').add({
        'electeur_id': userId,
        'scrutin_id': scrutinId,
        'candidat_id': candidatId,
        'date_vote': FieldValue.serverTimestamp(),
      });

      // Mise à jour de la liste des votes du scrutin
      await _firestore.collection('scrutins').doc(scrutinId).update({
        'votes': FieldValue.arrayUnion([voteRef.id]),
      });

      // Mise à jour de la liste des votes de l'utilisateur
      await _firestore.collection('users').doc(userId).update({
        'votes': FieldValue.arrayUnion([voteRef.id]),
      });

      return true;
    } catch (e) {
      print('Erreur lors du vote : $e');
      return false;
    }
  }

  // *Candidats*
  Future<List<Map<String, dynamic>>> recupererCandidats(
      String scrutinId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('candidats')
          .where('scrutin_id', isEqualTo: scrutinId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des candidats : $e');
      return [];
    }
  }
}
