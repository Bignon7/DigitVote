/*import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final String scrutinId;

  const ResultsPage({Key? key, required this.scrutinId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Résultats du scrutin',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Résultats pour le scrutin ID: $scrutinId',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import '../utils/colors.dart';
//import 'candidat_detail.dart';

class ResultsPage extends StatefulWidget {
  final String scrutinId;

  const ResultsPage({super.key, required this.scrutinId});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Candidat> allCandidats = [];
  List<Candidat> filteredCandidats = [];
  String? selectedCandidatId;

  @override
  void initState() {
    super.initState();
    _loadResultsForScrutin();
  }

  void _loadResultsForScrutin() {
    // Exemple de données fictives :
    setState(() {
      allCandidats = [
        Candidat(
            id: '1',
            name: 'Candidat 1',
            poste: 'Poste A',
            imageUrl: 'assets/images/hees.jpg',
            numberVotes: 100),
        Candidat(
            id: '2',
            name: 'Candidat 2',
            poste: 'Poste B',
            imageUrl: 'assets/images/heess.jpg',
            numberVotes: 80),
        Candidat(
            id: '3',
            name: 'Candidat 3',
            poste: 'Poste C',
            imageUrl: 'assets/images/default2.png',
            numberVotes: 120),
      ];
      filteredCandidats = List.from(allCandidats);
    });
  }

  void filterCandidats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCandidats = List.from(allCandidats);
      } else {
        filteredCandidats = allCandidats.where((candidat) {
          return candidat.name.toLowerCase().contains(query.toLowerCase()) ||
              candidat.poste.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToDetails(BuildContext context, Candidat candidat) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatDetailsPage(candidat: candidat),
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    // Tri des candidats par nombre de votes en ordre décroissant
    filteredCandidats.sort((a, b) => b.numberVotes.compareTo(a.numberVotes));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultats du scrutin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: filterCandidats,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un candidat',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            // Affichage des résultats
            Expanded(
              child: filteredCandidats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/hees.jpg", // Image par défaut si aucune donnée
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Aucun candidat trouvé",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCandidats.length,
                      itemBuilder: (context, index) {
                        final candidat = filteredCandidats[index];
                        // Déterminer le nombre d'étoiles à afficher en fonction du classement
                        int starCount = 0;
                        if (index == 0) {
                          starCount = 3; // Premier
                        } else if (index == 1) {
                          starCount = 2; // Deuxième
                        } else if (index == 2) {
                          starCount = 1; // Troisième
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () =>
                                  _navigateToDetails(context, candidat),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  candidat.imageUrl.isNotEmpty
                                      ? candidat.imageUrl
                                      : 'assets/images/hees.jpg',
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () =>
                                  _navigateToDetails(context, candidat),
                              child: Text(
                                candidat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              candidat.poste,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                starCount,
                                (index) => Icon(
                                  Icons.star,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }
}

// Exemple de modèle de candidat
class Candidat {
  final String id;
  final String name;
  final String poste;
  final String imageUrl;
  final int numberVotes;

  Candidat({
    required this.id,
    required this.name,
    required this.poste,
    required this.imageUrl,
    required this.numberVotes,
  });
}
