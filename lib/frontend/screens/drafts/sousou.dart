//scrutins page

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Ajoutez ce package à pubspec.yaml
import 'package:digit_vote/backend/models/scrutin.dart';
import '../../../backend/services/scrutin_service.dart';
import '../../utils/colors.dart';
import '../candidats_page.dart';
import '../resultats_page.dart';

class ScrutinPage extends StatefulWidget {
  @override
  _ScrutinPageState createState() => _ScrutinPageState();
}

class _ScrutinPageState extends State<ScrutinPage> {
  final ScrutinService _scrutinService = ScrutinService();
  String searchQuery = "";

  void filterScrutins(String query) {
    setState(() {
      searchQuery = query;
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
          const SizedBox(height: 20),
          const Text(
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
      /*appBar: AppBar(
        title: const Text(
          'Scrutins disponibles',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),*/
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: filterScrutins,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un scrutin',
                    hintStyle: TextStyle(color: Colors.grey),
                    //prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),

            // Liste des scrutins avec gestion des états
            Expanded(
              child: StreamBuilder<List<Scrutin>>(
                stream: _scrutinService.getAllScrutins(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Affichage du chargement
                    return Center(
                      child: Lottie.asset(
                        'assets/animations/Animation.json',
                        width: 150,
                        height: 150,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Affichage de l'erreur
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur : ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                    return buildEmptyListMessage();
                  } else if (snapshot.hasData) {
                    final allScrutins = snapshot.data!;
                    final displayedScrutins = allScrutins.where((scrutin) {
                      return scrutin.titre
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          scrutin.candidatsIds.length
                              .toString()
                              .contains(searchQuery);
                    }).toList();

                    if (displayedScrutins.isEmpty) {
                      return buildEmptyListMessage();
                    }

                    return ListView.builder(
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
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
                                    Text(
                                      scrutin.titre ?? "Titre inconnu",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${scrutin.candidatsIds?.length ?? 0} candidats",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
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
                                                    VoteCandidatsPage(
                                                        scrutinId: "se"),
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
                                    minimumSize: const Size(70, 36),
                                  ),
                                  child: Text(
                                    statut == "Terminé" ? 'Résultats' : 'Voter',
                                    style: const TextStyle(
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
                    );
                  } else {
                    return buildEmptyListMessage();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
