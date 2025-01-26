class Candidat {
  String _id;
  String _scrutinId;
  String _nom;
  String _biographie;
  String _poste;
  String _image;
  int _nombreVotes;

  Candidat({
    //this.id = '',  à revoir: je epux faire ceci, comme ça blus besoin de le faire ailleurs et plus besoin de gérer mon id
    required String id,
    required String scrutinId,
    required String nom,
    required String biographie,
    required String poste,
    required String image,
    required int nombreVotes,
  })  : _id = id,
        _scrutinId = scrutinId,
        _nom = nom,
        _biographie = biographie,
        _poste = poste,
        _image = image,
        _nombreVotes = nombreVotes;

  String get id => _id;
  String get scrutinId => _scrutinId;
  String get nom => _nom;
  String get biographie => _biographie;
  String get poste => _poste;
  String get image => _image;
  int get nombreVotes => _nombreVotes;

  set id(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'id ne peut pas être nulle.");
    }
    _id = value;
  }

  set scrutinId(String value) {
    if (value.isEmpty) {
      throw ArgumentError("Le scrutin_id ne peut pas être null");
    }
    _scrutinId = value;
  }

  set nom(String value) {
    if (value.isEmpty) {
      throw ArgumentError("Le nom ne peut pas être null");
    }
    _nom = value;
  }

  set biographie(String value) {
    if (value.isEmpty) {
      throw ArgumentError("La biographie ne peut pas être null");
    }
    _biographie = value;
  }

  set poste(String value) {
    if (value.isEmpty) {
      throw ArgumentError("Le poste ne peut pas être null");
    }
    _poste = value;
  }

  set image(String value) {
    if (value.isEmpty) {
      throw ArgumentError("L'image ne peut pas être null");
    }
    _image = value;
  }

  set nombreVotes(int value) {
    _nombreVotes = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'scrutin_id': _scrutinId,
      'nom': _nom,
      'biographie': _biographie,
      'poste': _poste,
      'image': _image,
      'nombreVotes': _nombreVotes,
    };
  }

  factory Candidat.fromMap(Map<String, dynamic> map) {
    return Candidat(
      id: map['id'],
      scrutinId: map['scrutin_id'],
      nom: map['nom'],
      biographie: map['biographie'],
      poste: map['poste'],
      image: map['image'],
      nombreVotes: map['nombreVotes'],
    );
  }
}
