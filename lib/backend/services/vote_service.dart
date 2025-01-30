import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/vote.dart';
import '../models/scrutin.dart';

class VoteService {
  final CollectionReference _votesCollection =
      FirebaseFirestore.instance.collection('votes');
  final CollectionReference _scrutinsCollection =
      FirebaseFirestore.instance.collection('scrutins');
  final CollectionReference _candidatsCollection =
      FirebaseFirestore.instance.collection('candidats');

  final encrypt.Key _encryptionKey =
      encrypt.Key.fromUtf8('my 32 length key................');
  late final encrypt.Encrypter _encrypter;

  VoteService() {
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
  }

  // Chiffrer un candidatId
  String _encryptCandidatId(String candidatId) {
    final iv = encrypt.IV.fromLength(16);
    final encrypted = _encrypter.encrypt(candidatId, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptCandidatId(String encryptedCandidatId) {
    final parts = encryptedCandidatId.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  // Ajouter un vote
  Future<void> createVote(Vote vote, String userId) async {
    try {
      final scrutinDoc = await _scrutinsCollection.doc(vote.scrutinId).get();
      if (!scrutinDoc.exists) {
        throw Exception("Scrutin introuvable !");
      }
      final scrutin =
          Scrutin.fromMap(scrutinDoc.data() as Map<String, dynamic>);

      if (userId != vote.electeurId) {
        throw Exception("Vous devez vous authentifier avant de pouvoir voter.");
      }
      final now = DateTime.now();
      if (now.isBefore(scrutin.dateOuverture)) {
        throw Exception("Ce scrutin n'a pas encore commencé");
      }
      if (now.isAfter(scrutin.dateCloture)) {
        throw Exception("Le délai d'existence de ce scrutin est expiré.");
      }
      final userVotes = await _votesCollection
          .where('electeur_id', isEqualTo: userId)
          .where('scrutin_id', isEqualTo: vote.scrutinId)
          .get();
      if (!scrutin.voteMultiple && userVotes.docs.isNotEmpty) {
        throw Exception("Votre vote a déjà été enregistré pour ce scrutin.");
      }
      final encryptedCandidatId = _encryptCandidatId(vote.candidatId);
      final docRef = _votesCollection.doc();
      vote.id = docRef.id;
      await docRef.set({
        'id': vote.id,
        'electeur_id': vote.electeurId,
        'scrutin_id': vote.scrutinId,
        'candidat_id': encryptedCandidatId,
        'date_vote': vote.dateVote.toIso8601String(),
      });
      await _incrementCandidatVoteCount(vote.candidatId);
    } catch (e) {
      print("Erreur lors de la création du vote : $e");
      rethrow;
    }
  }

  // Méthode pour incrémenter le nombre de votes d'un candidat
  Future<void> _incrementCandidatVoteCount(String candidatId) async {
    try {
      final candidatDoc = await _candidatsCollection.doc(candidatId).get();
      if (!candidatDoc.exists) {
        throw Exception("Candidat introuvable !");
      }
      await _candidatsCollection.doc(candidatId).update({
        'nombreVotes': FieldValue.increment(1),
      });
    } catch (e) {
      // Logique pour gérer l'exception
      print("Erreur lors de l'incrémentation des votes : $e");
      rethrow;
    }
  }

  // Récupérer les votes par scrutin
  Stream<List<Vote>> getVotesByScrutin(String scrutinId) {
    return _votesCollection
        .where('scrutin_id', isEqualTo: scrutinId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final vote = Vote.fromMap(doc.data() as Map<String, dynamic>);
        vote.candidatId = _decryptCandidatId(vote.candidatId);
        return vote;
      }).toList();
    });
  }

  // Récupérer les scrutins pour lesquels un électeur a voté
  Future<List<Scrutin>> getScrutinsByElecteur(String electeurId) async {
    final userVotes = await _votesCollection
        .where('electeur_id', isEqualTo: electeurId)
        .get();

    final scrutinIds = userVotes.docs
        .map((doc) => doc['scrutin_id'] as String?)
        .where((scrutinId) => scrutinId != null)
        .toSet();

    final List<Scrutin> scrutins = [];
    for (final scrutinId in scrutinIds) {
      final scrutinDoc = await _scrutinsCollection.doc(scrutinId).get();
      if (scrutinDoc.exists) {
        scrutins
            .add(Scrutin.fromMap(scrutinDoc.data() as Map<String, dynamic>));
      }
    }

    return scrutins;
  }

  // Supprimer un vote
  Future<void> deleteVote(String voteId) async {
    try {
      await _votesCollection.doc(voteId).delete();
    } catch (e) {
      print("Erreur lors de la suppression du vote : $e");
      rethrow;
    }
  }
}
