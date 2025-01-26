import 'dart:math';

class Scrutin {
  String _id;
  String _createurId;
  String _titre;
  String _description;
  DateTime _dateOuverture;
  DateTime _dateCloture;
  List<String> _candidatsIds;
  String _code;
  bool _voteMultiple;

  Scrutin({
    required String id,
    required String createurId,
    required String titre,
    required String description,
    required DateTime dateOuverture,
    required DateTime dateCloture,
    required List<String> candidatsIds,
    required String code,
    required bool voteMultiple,
  })  : _id = id,
        _createurId = createurId,
        _titre = titre,
        _description = description,
        _dateOuverture = dateOuverture,
        _dateCloture = dateCloture,
        _candidatsIds = candidatsIds,
        _code = code,
        _voteMultiple = voteMultiple;

  // Getters
  String get id => _id;
  String get createurId => _createurId;
  String get titre => _titre;
  String get description => _description;
  DateTime get dateOuverture => _dateOuverture;
  DateTime get dateCloture => _dateCloture;
  List<String> get candidatsIds => _candidatsIds;
  String get code => _code;
  bool get voteMultiple => _voteMultiple;

  // Setters avec validations
  set id(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID ne peut pas être vide.");
    }
    _id = value;
  }

  set createurId(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'ID du créateur ne peut pas être vide.");
    }
    _createurId = value;
  }

  set titre(String value) {
    if (value.isEmpty || value.length < 3) {
      throw ArgumentError("Le titre doit contenir au moins 3 caractères.");
    }
    _titre = value;
  }

  set description(String value) {
    if (value.isEmpty || value.length < 5) {
      throw ArgumentError(
          "La description doit contenir au moins 5 caractères.");
    }
    _description = value;
  }

  set dateOuverture(DateTime value) {
    if (value.isAfter(_dateCloture)) {
      throw ArgumentError(
          "La date d'ouverture doit être avant la date de clôture.");
    }
    _dateOuverture = value;
  }

  set dateCloture(DateTime value) {
    if (value.isBefore(_dateOuverture)) {
      throw ArgumentError(
          "La date de clôture doit être après la date d'ouverture.");
    }
    _dateCloture = value;
  }

  set candidatsIds(List<String> value) {
    if (value.isEmpty) {
      throw ArgumentError("La liste des candidats ne peut pas être vide.");
    }
    _candidatsIds = value;
  }

  set code(String value) {
    _code = value;
  }

  set voteMultiple(bool value) {
    _voteMultiple = value;
  }

  // Statut calculé
  String getStatut() {
    final now = DateTime.now();
    if (now.isBefore(_dateOuverture)) {
      return "Futur";
    } else if (now.isAfter(_dateCloture)) {
      return "Terminé";
    } else {
      return "En cours";
    }
  }

  // Conversion en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'createur_id': _createurId,
      'titre': _titre,
      'description': _description,
      'date_ouverture': _dateOuverture.toIso8601String(),
      'date_cloture': _dateCloture.toIso8601String(),
      'candidats_ids': _candidatsIds,
      'code': _code,
      'vote_multiple': _voteMultiple,
    };
  }

  // Création à partir d'un document Firestore
  factory Scrutin.fromMap(Map<String, dynamic> map) {
    return Scrutin(
      id: map['id'],
      createurId: map['createur_id'],
      titre: map['titre'],
      description: map['description'],
      dateOuverture: DateTime.parse(map['date_ouverture']),
      dateCloture: DateTime.parse(map['date_cloture']),
      candidatsIds: List<String>.from(map['candidats_ids']),
      code: map['code'],
      voteMultiple: map['vote_multiple'],
    );
  }

  void generateCode({
    int codeLength = 8,
    String allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?!@#',
  }) {
    final random = Random();
    _code = List.generate(
      codeLength,
      (index) => allowedChars[random.nextInt(allowedChars.length)],
    ).join();
  }

  void resetCode() {
    _code = '';
  }
}
