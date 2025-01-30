import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/candidat.dart';

class CandidatService {
  final CollectionReference _candidatsCollection =
      FirebaseFirestore.instance.collection('candidats');

  // Créer un candidat (avec un ID généré automatiquement par Firestore)
  Future<String> createCandidat(Candidat candidat) async {
    final docRef = _candidatsCollection.doc();
    candidat.id = docRef.id;
    await docRef.set(candidat.toMap());
    return docRef.id;
  }

  // Récupérer tous les candidats
  Stream<List<Candidat>> getAllCandidats() {
    return _candidatsCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Candidat.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Récupérer un candidat par ID
  Future<Candidat> getCandidatById(String id) async {
    final doc = await _candidatsCollection.doc(id).get();
    if (doc.exists) {
      return Candidat.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception("Candidat introuvable !");
    }
  }

  // Récupérer tous les candidats d'un scrutin spécifique
  ///Stream permet de recupérer les données en temps réel?????
  Stream<List<Candidat>> getCandidatsByScrutin(String scrutinId) {
    return _candidatsCollection
        .where('scrutin_id', isEqualTo: scrutinId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
              return Candidat.fromMap(doc.data() as Map<String, dynamic>);
            }).toList());
  }

  // Mettre à jour un candidat
  Future<void> updateCandidat(
      String id, Map<String, dynamic> updatedData) async {
    await _candidatsCollection.doc(id).update(updatedData);
  }

  // Supprimer un candidat
  Future<void> deleteCandidat(String id) async {
    await _candidatsCollection.doc(id).delete();
  }

  // Ajouter un vote à un candidat
  Future<void> incrementVote(String candidatId) async {
    final doc = await _candidatsCollection.doc(candidatId).get();
    if (doc.exists) {
      await _candidatsCollection.doc(candidatId).update({
        'nombreVotes': FieldValue.increment(1),
      });
    } else {
      throw Exception("Candidat introuvable !");
    }
  }

  // Réinitialiser les votes d'un candidat
  Future<void> resetVotes(String candidatId) async {
    await updateCandidat(candidatId, {'nombreVotes': 0});
  }

  // Réinitialiser les votes de tous les candidats d'un scrutin
  //Ici le bach est utilisé pour ne pas ralentir notre application, sans batch nous serions obligés de faire une requee distincte pour chaque candidat ce qui pourrait ralentir l'app

  /*Future<void> resetVotesForScrutin(String scrutinId) async {
    final querySnapshot = await _candidatsCollection
        .where('scrutin_id', isEqualTo: scrutinId)
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'nombreVotes': 0});
    }
  }*/

  Future<void> resetVotesForScrutin(String scrutinId) async {
    final querySnapshot = await _candidatsCollection
        .where('scrutin_id', isEqualTo: scrutinId)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'nombreVotes': 0});
    }
    await batch.commit();
  }
}
