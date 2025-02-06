import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/scrutin.dart';
import '../models/candidat.dart';
import './candidat_service.dart';
import './email_service.dart';

class ScrutinService {
  final CollectionReference _scrutinsCollection =
      FirebaseFirestore.instance.collection('scrutins');

  final CandidatService? _candidatService;

  ScrutinService({CandidatService? candidatService})
      : _candidatService = candidatService;

  // Ajouter un scrutin
  Future<String> createScrutin(Scrutin scrutin) async {
    final docRef = _scrutinsCollection.doc();
    scrutin.id = docRef.id;
    await docRef.set(scrutin.toMap());
    if (scrutin.code.isNotEmpty) {
      try {
        await EmailService.sendEmailWithCodeForCurrentUser(
            scrutin.code, scrutin.titre);
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
//Futur et En cours
  // Stream<List<Scrutin>> getActiveScrutins() {
  //   return FirebaseFirestore.instance
  //       .collection('scrutins')
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) {
  //           var data = doc.data();
  //           dynamic dateCloture = data['date_cloture'];
  //           DateTime? dateClotureDT;

  //           if (dateCloture is String) {
  //             dateClotureDT = DateTime.parse(dateCloture);
  //           } else if (dateCloture is Timestamp) {
  //             dateClotureDT = dateCloture.toDate();
  //           }
  //           if (dateClotureDT != null &&
  //               dateClotureDT.isAfter(DateTime.now())) {
  //             return Scrutin.fromMap(data);
  //           } else {
  //             return null;
  //           }
  //         })
  //         .where((scrutin) => scrutin != null)
  //         .cast<Scrutin>()
  //         .toList();
  //   });
  // }
  //En cours seulement
  Stream<List<Scrutin>> getActiveScrutins() {
    return FirebaseFirestore.instance
        .collection('scrutins')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            var data = doc.data();
            dynamic dateOuverture = data['date_ouverture'];
            dynamic dateCloture = data['date_cloture'];
            DateTime? dateOuvertureDT;
            DateTime? dateClotureDT;

            if (dateOuverture is String) {
              dateOuvertureDT = DateTime.parse(dateOuverture);
            } else if (dateOuverture is Timestamp) {
              dateOuvertureDT = dateOuverture.toDate();
            }

            if (dateCloture is String) {
              dateClotureDT = DateTime.parse(dateCloture);
            } else if (dateCloture is Timestamp) {
              dateClotureDT = dateCloture.toDate();
            }
            DateTime now = DateTime.now();
            if (dateOuvertureDT != null &&
                dateClotureDT != null &&
                dateOuvertureDT.isBefore(now) &&
                dateClotureDT.isAfter(now)) {
              return Scrutin.fromMap(data);
            } else {
              return null;
            }
          })
          .where((scrutin) => scrutin != null)
          .cast<Scrutin>()
          .toList();
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

  Future<String> addCandidatToScrutin(
      String scrutinId, Candidat candidat) async {
    try {
      final scrutinDoc = await _scrutinsCollection.doc(scrutinId).get();
      if (!scrutinDoc.exists) {
        throw Exception("Scrutin introuvable !");
      }
      String candidatId = await _candidatService!.createCandidat(candidat);
      await updateScrutin(scrutinId, {
        'candidats_ids': FieldValue.arrayUnion([candidatId])
      });
      return candidatId;
    } catch (e) {
      throw Exception(
          "Erreur lors de l'ajout du candidat au scrutin: ${e.toString()}");
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

  Stream<List<Candidat>> getCandidatsByScrutin(String scrutinId) {
    return _scrutinsCollection
        .where('scrutin_id', isEqualTo: scrutinId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Candidat.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
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
    int codeLength = 4,
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
