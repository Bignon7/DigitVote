import 'package:encrypt/encrypt.dart' as encrypt;

class Vote {
  String _id;
  String _electeurId;
  String _scrutinId;
  String _candidatId; // Chiffré pour sécuriser le vote
  DateTime _dateVote;

  Vote({
    required String id,
    required String electeurId,
    required String scrutinId,
    required String candidatId,
    required DateTime dateVote,
  })  : _id = id,
        _electeurId = electeurId,
        _scrutinId = scrutinId,
        _candidatId = candidatId,
        _dateVote = dateVote;

  // Getters
  String get id => _id;
  String get electeurId => _electeurId;
  String get scrutinId => _scrutinId;
  String get candidatId => _candidatId;
  DateTime get dateVote => _dateVote;

  // Setters
  set id(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID ne peut pas être vide.");
    }
    _id = value;
  }

  set electeurId(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID de l'électeur ne peut pas être vide.");
    }
    _electeurId = value;
  }

  set scrutinId(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID du scrutin ne peut pas être vide.");
    }
    _scrutinId = value;
  }

  set candidatId(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID du candidat ne peut pas être vide.");
    }
    _candidatId = value;
  }

  set dateVote(DateTime value) {
    _dateVote = value;
  }

  // Conversion en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'electeur_id': _electeurId,
      'scrutin_id': _scrutinId,
      'candidat_id': _candidatId,
      'date_vote': _dateVote.toIso8601String(),
    };
  }

  // Création à partir d'un document Firestore
  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      id: map['id'],
      electeurId: map['electeur_id'],
      scrutinId: map['scrutin_id'],
      candidatId: map['candidat_id'],
      dateVote: DateTime.parse(map['date_vote']),
    );
  }

  // Chiffrer le candidat_id
  static String encryptCandidatId(String candidatId, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

    return encrypter.encrypt(candidatId, iv: iv).base64;
  }

  // Déchiffrer le candidat_id
  static String decryptCandidatId(String encryptedId, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

    return encrypter.decrypt64(encryptedId, iv: iv);
  }
}
