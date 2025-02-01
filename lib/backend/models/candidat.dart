class Candidat {
  String _id;
  String _scrutinId;
  String _nom;
  String _biographie;
  String _image;
  int _nombreVotes;

  Candidat({
    required String id,
    required String scrutinId,
    required String nom,
    required String biographie,
    required String image,
    required int nombreVotes,
  })  : _id = id,
        _scrutinId = scrutinId,
        _nom = nom,
        _biographie = biographie,
        _image = image,
        _nombreVotes = nombreVotes;

  String get id => _id;
  String get scrutinId => _scrutinId;
  String get nom => _nom;
  String get biographie => _biographie;
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
      image: map['image'],
      nombreVotes: map['nombreVotes'],
    );
  }
}
