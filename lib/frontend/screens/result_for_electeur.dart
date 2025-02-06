import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/frontend/utils/custom_loader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/user_provider.dart';
import '../utils/colors.dart';
import 'resultats_page.dart';

class ResultListForVoted extends StatefulWidget {
  const ResultListForVoted({super.key});

  @override
  _ResultListForVotedState createState() => _ResultListForVotedState();
}

class _ResultListForVotedState extends State<ResultListForVoted> {
  List<Scrutin> scrutins = [];
  List<Scrutin> filteredScrutins = [];
  String query = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVotedScrutins();
  }

  void _loadVotedScrutins() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId == null) return;

    try {
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('electeur_id', isEqualTo: userId)
          .get();

      List<String> votedScrutinIds =
          votesSnapshot.docs.map((doc) => doc['scrutin_id'] as String).toList();

      if (votedScrutinIds.isEmpty) {
        setState(() {
          scrutins = [];
          filteredScrutins = [];
        });
        return;
      }
      //et terminés
      ScrutinService().getAllScrutins().listen((scrutinsData) {
        setState(() {
          scrutins = scrutinsData
              .where((scrutin) =>
                  votedScrutinIds.contains(scrutin.id) &&
                  scrutin.dateCloture.isBefore(DateTime.now()))
              .toList();
          filteredScrutins = scrutins;
          isLoading = false;
        });
      });
      //ou vote seulement
      // ScrutinService().getAllScrutins().listen((scrutinsData) {
      //   setState(() {
      //     scrutins = scrutinsData
      //         .where((scrutin) => votedScrutinIds.contains(scrutin.id))
      //         .toList();
      //     filteredScrutins = scrutins;
      //     isLoading = false;
      //   });
      // });
    } catch (e) {
      debugPrint("Erreur lors du chargement des scrutins votés: $e");
    }
  }

  void filterScrutins(String query) {
    setState(() {
      this.query = query;
      filteredScrutins = scrutins.where((scrutin) {
        return scrutin.titre.toLowerCase().contains(query.toLowerCase()) ||
            scrutin.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat("dd MMMM yyyy", "fr_FR");
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultats des Scrutins',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
      body: isLoading
          ? const Center(child: CustomLoader())
          : SafeArea(
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
                        onChanged: filterScrutins,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher  un scrutin',
                          hintStyle: TextStyle(color: Colors.grey),
                          suffixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  // Affichage des résultats
                  Expanded(
                    child: filteredScrutins.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/empty.jpg",
                                  height: 150,
                                ),
                                const SizedBox(height: 17),
                                const Text(
                                  "Aucun scrutin trouvé",
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
                            itemCount: filteredScrutins.length,
                            itemBuilder: (context, index) {
                              final scrutin = filteredScrutins[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ResultsPage(scrutinId: scrutin.id),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.stacked_bar_chart,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                scrutin.titre,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                scrutin.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.event,
                                                      size: 16,
                                                      color: Colors.blueGrey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Ouverture: ${_formatDate(scrutin.dateOuverture)}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.event_available,
                                                      size: 16,
                                                      color: Colors.blueGrey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Clôture: ${_formatDate(scrutin.dateCloture)}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 18, color: Colors.grey),
                                      ],
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
    );
  }
}
