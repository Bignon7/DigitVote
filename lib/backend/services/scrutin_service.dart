import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/scrutin.dart';
import '../models/candidat.dart';
import './candidat_service.dart';
import './email_service.dart';

class ScrutinService {
  final CollectionReference _scrutinsCollection =
      FirebaseFirestore.instance.collection('scrutins');

  final CollectionReference _candidatsCollection =
      FirebaseFirestore.instance.collection('candidats');

  final CandidatService? _candidatService;

  ScrutinService({CandidatService? candidatService})
      : _candidatService = candidatService;

  // Ajouter un scrutin
  Future<String> createScrutin(Scrutin scrutin) async {
    //await _scrutinsCollection.doc(scrutin.id).set(scrutin.toMap()); ceci pour ajouter avec id scrutin.id
    /*final docRef = await _scrutinsCollection.add(scrutin.toMap()); ceci est une version moins optimale 
    scrutin.id = docRef.id;
    await _scrutinsCollection.doc(docRef.id).set(scrutin.toMap());*/
    final docRef = _scrutinsCollection.doc();
    scrutin.id = docRef.id;
    await docRef.set(scrutin.toMap());
    if (scrutin.code.isNotEmpty) {
      try {
        await EmailService.sendEmailWithCodeForCurrentUser(scrutin.code);
      } catch (e) {
        //
      }
    }
    return docRef.id;
  }

  // Récupérer tous les scrutins
  Stream<List<Scrutin>> getAllScrutins() {
    return _scrutinsCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Scrutin.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Récupérer un scrutin par ID
  Future<Scrutin> getScrutinById(String id) async {
    final doc = await _scrutinsCollection.doc(id).get();
    if (doc.exists) {
      return Scrutin.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  // Récupérer tous les scrutins d'un créateur spécifique
  Stream<List<Scrutin>> getScrutinsByCreateur(String createurId) {
    return _scrutinsCollection
        .where('createur_id', isEqualTo: createurId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Scrutin.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Mettre à jour un scrutin
  Future<void> updateScrutin(
      String id, Map<String, dynamic> updatedData) async {
    await _scrutinsCollection.doc(id).update(updatedData);
  }

  // Supprimer un scrutin
  Future<void> deleteScrutin(String id) async {
    await _scrutinsCollection.doc(id).delete();
  }

  // Ajouter un candidat à un scrutin
  Future<String> addCandidatToScrutin(
      String scrutinId, Candidat candidat) async {
    final doc = await _scrutinsCollection.doc(scrutinId).get();
    if (doc.exists) {
      //final scrutin = Scrutin.fromMap(doc.data() as Map<String, dynamic>);
      final candidatId =
          await _candidatService?.createCandidat(candidat) ?? candidat.id;
      await updateScrutin(scrutinId, {
        'candidats_ids': FieldValue.arrayUnion([candidatId])
      }); //cette méthode pour ne pas créer des doublons, c'est mieux que .add
      return candidatId;
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  // Supprimer un candidat d'un scrutin
  Future<void> removeCandidatFromScrutin(
      String scrutinId, String candidatId) async {
    final doc = await _scrutinsCollection.doc(scrutinId).get();
    if (doc.exists) {
      await _candidatService?.deleteCandidat(candidatId);
      await updateScrutin(scrutinId, {
        'candidats_ids': FieldValue.arrayRemove([candidatId])
      });
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  Future<List<Candidat>> getCandidatsByScrutin(String scrutinId) async {
    final scrutinDoc = await _scrutinsCollection.doc(scrutinId).get();

    if (scrutinDoc.exists) {
      final data = scrutinDoc.data() as Map<String, dynamic>;
      final List<String> candidatsIds =
          List<String>.from(data['candidats_ids'] ?? []);

      final querySnapshot = await _candidatsCollection
          .where(FieldPath.documentId, whereIn: candidatsIds)
          .get();
      return querySnapshot.docs.map((doc) {
        return Candidat.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  Future<void> resetVotesForScrutin(String scrutinId) async {
    final scrutinDoc = await _scrutinsCollection.doc(scrutinId).get();

    if (scrutinDoc.exists) {
      final scrutin =
          Scrutin.fromMap(scrutinDoc.data() as Map<String, dynamic>);

      for (final candidatId in scrutin.candidatsIds) {
        await _candidatService?.resetVotesForScrutin(candidatId);
      }
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  //Essai de fonction pour générer le code, on pourra maybe l'utiliser pour la création et le update

  String getGeneratedCode({
    int codeLength = 8,
    String allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?!@#',
  }) {
    final random = Random();
    return List.generate(
      codeLength,
      (index) => allowedChars[random.nextInt(allowedChars.length)],
    ).join();
  }

  Future<void> generateAndSetCodeForScrutin(String scrutinId) async {
    final newCode = getGeneratedCode();
    final doc = await _scrutinsCollection.doc(scrutinId).get();

    if (doc.exists) {
      await _scrutinsCollection.doc(scrutinId).update({'code': newCode});
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }

  Future<void> resetCodeForScrutin(String scrutinId) async {
    final doc = await _scrutinsCollection.doc(scrutinId).get();

    if (doc.exists) {
      await _scrutinsCollection.doc(scrutinId).update({'code': ''});
    } else {
      throw Exception("Scrutin introuvable !");
    }
  }
}
