import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:digit_vote/backend/services/candidat_service.dart'; // Importation de ton service
import '../utils/custom_loader.dart';
import '../../backend/models/candidat.dart';

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

  void _loadResultsForScrutin() async {
    try {
      // Appeler le service pour obtenir les candidats en fonction de l'ID du scrutin
      final candidatsStream =
          await CandidatService().getCandidatsByScrutin(widget.scrutinId);
      candidatsStream.listen((candidats) {
        setState(() {
          allCandidats = candidats;
          // Trier les candidats par nombre de votes décroissant
          allCandidats.sort((a, b) => b.nombreVotes.compareTo(a.nombreVotes));
          //filteredCandidats = allCandidats.take(3).toList();
          filteredCandidats = allCandidats.toList();
        });
      });
    } catch (error) {
      print('Erreur lors du chargement des résultats : $error');
    }
  }

  void filterCandidats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCandidats = List.from(allCandidats);
      } else {
        filteredCandidats = allCandidats.where((candidat) {
          return candidat.nom.toLowerCase().contains(query.toLowerCase()) ||
              candidat.poste.toLowerCase().contains(query.toLowerCase()) ||
              candidat.nombreVotes.toString().contains(query);
        }).toList();
      }
    });
  }

  void _navigateToDetails(BuildContext context, Candidat candidat) {
    // Définir la navigation vers la page de détails ici, si nécessaire
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: filteredCandidats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/empty.jpg", // Image par défaut si aucune donnée
                            height: 150,
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            "Aucun vote enregistré",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCandidats.length,
                      itemBuilder: (context, index) {
                        final candidat = filteredCandidats[index];
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
                                  candidat.image.isNotEmpty
                                      ? candidat.image
                                      : 'assets/images/hees.jpg',
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () =>
                                  _navigateToDetails(context, candidat),
                              child: Text(
                                candidat.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              "${candidat.nombreVotes} vote(s)",
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
      backgroundColor: Colors.white,
    );
  }
}
