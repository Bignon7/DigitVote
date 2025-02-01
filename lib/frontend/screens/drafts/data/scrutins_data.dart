/*import 'package:flutter/material.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import '../utils/colors.dart';
import 'candidats_page.dart';
import 'resultats_page.dart';

class ScrutinPage extends StatefulWidget {
  @override
  _ScrutinPageState createState() => _ScrutinPageState();
}

class _ScrutinPageState extends State<ScrutinPage> {
  List<Scrutin> scrutins = [
    Scrutin(
      id: "1",
      createurId: "u1",
      titre: "Élection Présidentielle 2025",
      description: "Élection pour élire le prochain président.",
      dateOuverture: DateTime(2025, 1, 1),
      dateCloture: DateTime(2025, 1, 31),
      candidatsIds: ["c1", "c2"],
      code: "Public",
      voteMultiple: false,
    ),
    Scrutin(
      id: "2",
      createurId: "u2",
      titre: "Élection du Conseil Municipal",
      description: "Élection pour le conseil local.",
      dateOuverture: DateTime(2024, 12, 1),
      dateCloture: DateTime(2024, 12, 15),
      candidatsIds: ["c3", "c4", "c5"],
      code: "Privé",
      voteMultiple: true,
    ),
    Scrutin(
      id: "1",
      createurId: "u1",
      titre: "Élection Présidentielle 2025",
      description: "Élection pour élire le prochain président.",
      dateOuverture: DateTime(2025, 1, 1),
      dateCloture: DateTime(2025, 1, 31),
      candidatsIds: ["c1", "c2"],
      code: "Public",
      voteMultiple: false,
    ),
    Scrutin(
      id: "4",
      createurId: "u1",
      titre: "Élection Présidentielle 2025",
      description: "Élection pour élire le prochain président.",
      dateOuverture: DateTime(2025, 2, 1),
      dateCloture: DateTime(2025, 2, 31),
      candidatsIds: ["c1", "c2"],
      code: "Public",
      voteMultiple: false,
    ),
  ];

  List<Scrutin> displayedScrutins = [];

  @override
  void initState() {
    super.initState();
    displayedScrutins = scrutins;
  }

  void filterScrutins(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedScrutins = scrutins;
      } else {
        displayedScrutins = scrutins.where((scrutin) {
          return scrutin.titre.toLowerCase().contains(query.toLowerCase()) ||
              scrutin.candidatsIds.length.toString().contains(query);
        }).toList();
      }
    });
  }

  Widget buildEmptyListMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_data.png', // Remplacez par le chemin de votre image
            height: 150,
          ),
          SizedBox(height: 20),
          Text(
            "Aucun scrutin disponible",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scrutins disponibles',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: filterScrutins,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un scrutin',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Liste des scrutins ou message vide
            Expanded(
              child: displayedScrutins.isEmpty
                  ? buildEmptyListMessage()
                  : ListView.builder(
                      itemCount: displayedScrutins.length,
                      itemBuilder: (context, index) {
                        final scrutin = displayedScrutins[index];
                        final statut = scrutin.getStatut();
                        final color = statut == "En cours"
                            ? Colors.green
                            : statut == "Futur"
                                ? Colors.blue
                                : Colors.red;

                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Titre
                                    Text(
                                      scrutin.titre ?? "Titre inconnu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    SizedBox(height: 8),

                                    // Nombre de candidats
                                    Text(
                                      "${scrutin.candidatsIds?.length ?? 0} candidats",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),

                                    SizedBox(height: 8),

                                    // Statut
                                    Text(
                                      statut,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Bouton voter
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: ElevatedButton(
                                  onPressed: statut == "En cours" ||
                                          statut == "Terminé"
                                      ? () {
                                          if (statut == "En cours") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VoteCandidatsPage(),
                                              ),
                                            );
                                          } else if (statut == "Terminé") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ResultsPage(
                                                  scrutinId: scrutin.id,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: statut == "En cours"
                                        ? AppColors.primary
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: Size(70, 36),
                                  ),
                                  child: Text(
                                    statut == "Terminé" ? 'Résultats' : 'Voter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
*/









/*
import 'package:flutter/material.dart';

import '../../backend/services/scrutin_service.dart';
import '../../backend/models/scrutin.dart';
import 'candidat_form.dart';

class CreateScrutinForm extends StatefulWidget {
  @override
  _CreateScrutinFormState createState() => _CreateScrutinFormState();
}

class _CreateScrutinFormState extends State<CreateScrutinForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _createurIdController = TextEditingController();
  bool _isSecureVote =
      false; // Ajouter un booléen pour savoir si la case est cochée

  final ScrutinService _scrutinService = ScrutinService();

  // Fonction de validation
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  void _submitScrutinForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);
      final createurId = _createurIdController.text;

      // Créer un scrutin
      final scrutin = Scrutin(
        id: '',
        titre: title,
        description: description,
        dateOuverture: startDate,
        dateCloture: endDate,
        createurId: createurId,
        code: '',
        voteMultiple: false,
        candidatsIds: [],
      );

      // Si la case "Sécuriser le vote" est cochée, générer un code
      if (_isSecureVote) {
        scrutin.generateCode();
      }

      try {
        final scrutinId = await _scrutinService.createScrutin(scrutin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scrutin créé avec succès !')),
        );

        // Aller vers la page d'ajout de candidats pour ce scrutin
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateCandidatForm(scrutinId: scrutinId)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un Scrutin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre du Scrutin'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _startDateController,
                decoration:
                    InputDecoration(labelText: 'Date de début (YYYY-MM-DD)'),
                validator: _validateField,
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _endDateController,
                decoration:
                    InputDecoration(labelText: 'Date de fin (YYYY-MM-DD)'),
                validator: _validateField,
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _createurIdController,
                decoration: InputDecoration(labelText: 'ID du créateur'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              // Ajouter la case à cocher "Sécuriser le vote"
              CheckboxListTile(
                title: Text("Sécuriser le vote"),
                value: _isSecureVote,
                onChanged: (bool? value) {
                  setState(() {
                    _isSecureVote = value ?? false;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitScrutinForm,
                child: Text('Créer le Scrutin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


*/