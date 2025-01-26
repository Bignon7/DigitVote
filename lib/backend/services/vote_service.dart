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

  // Générer une clé de chiffrement
  final encrypt.Key _encryptionKey = encrypt.Key.fromUtf8(
      "32_characters_encryption_key!"); // Remplacez cette clé par une valeur sûre
  final encrypt.IV _iv = encrypt.IV.fromLength(16);
  late final encrypt.Encrypter _encrypter;

  VoteService() {
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
  }

  // Chiffrer un candidatId
  String _encryptCandidatId(String candidatId) {
    return _encrypter.encrypt(candidatId, iv: _iv).base64;
  }

  // Déchiffrer un candidatId
  String _decryptCandidatId(String encryptedCandidatId) {
    return _encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedCandidatId),
        iv: _iv);
  }

  // Ajouter un vote
  Future<void> createVote(Vote vote, String userId) async {
    final scrutinDoc = await _scrutinsCollection.doc(vote.scrutinId).get();

    if (!scrutinDoc.exists) {
      throw Exception("Scrutin introuvable !");
    }

    final scrutin = Scrutin.fromMap(scrutinDoc.data() as Map<String, dynamic>);

    // Vérifier que l'utilisateur est authentifié
    if (userId != vote.electeurId) {
      throw Exception("L'utilisateur n'est pas authentifié pour ce vote.");
    }

    // Vérifier si le scrutin est encore en cours
    final now = DateTime.now();
    if (now.isBefore(scrutin.dateOuverture) ||
        now.isAfter(scrutin.dateCloture)) {
      throw Exception("Le scrutin est fermé ou n'a pas encore commencé.");
    }

    // Vérifier si l'utilisateur a déjà voté
    final userVotes = await _votesCollection
        .where('electeur_id', isEqualTo: userId)
        .where('scrutin_id', isEqualTo: vote.scrutinId)
        .get();

    if (!scrutin.voteMultiple && userVotes.docs.isNotEmpty) {
      throw Exception("L'utilisateur a déjà voté pour ce scrutin.");
    }

    // Chiffrer le candidatId
    final encryptedCandidatId = _encryptCandidatId(vote.candidatId);

    // Créer le vote
    final docRef = _votesCollection.doc();
    vote.id = docRef.id;
    await docRef.set({
      'id': vote.id,
      'electeur_id': vote.electeurId,
      'scrutin_id': vote.scrutinId,
      'candidat_id': encryptedCandidatId,
      'date_vote': vote.dateVote.toIso8601String(),
    });

    // Incrémenter le nombre de votes pour le candidat
    await _incrementCandidatVoteCount(vote.candidatId);
  }

  // Méthode pour incrémenter le nombre de votes d'un candidat
  Future<void> _incrementCandidatVoteCount(String candidatId) async {
    final candidatDoc = await _candidatsCollection.doc(candidatId).get();

    if (candidatDoc.exists) {
      await _candidatsCollection.doc(candidatId).update({
        'nombreVotes': FieldValue.increment(1),
      });
    } else {
      throw Exception("Candidat introuvable !");
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

    // Extraire les scrutin_id en s'assurant que les données sont bien typées
    final scrutinIds = userVotes.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?; // Cast explicite
          return data?['scrutin_id']
              as String?; // Accéder au champ 'scrutin_id'
        })
        .where((scrutinId) => scrutinId != null) // Filtrer les null
        .cast<String>() // Cast sécurisé en String
        .toSet();

    final List<Scrutin> scrutins = [];
    for (final scrutinId in scrutinIds) {
      final scrutinDoc = await _scrutinsCollection.doc(scrutinId).get();
      if (scrutinDoc.exists) {
        final scrutinData =
            scrutinDoc.data() as Map<String, dynamic>?; // Cast explicite
        if (scrutinData != null) {
          scrutins.add(Scrutin.fromMap(scrutinData));
        }
      }
    }

    return scrutins;
  }

  // Supprimer un vote
  Future<void> deleteVote(String voteId) async {
    await _votesCollection.doc(voteId).delete();
  }
}
