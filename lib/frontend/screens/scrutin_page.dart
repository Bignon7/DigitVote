import 'package:digit_vote/backend/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import 'candidats_page.dart';
import 'resultats_page.dart';
import 'verify_scrutin.dart';
import '../utils/custom_loader.dart';

class ScrutinPage extends StatefulWidget {
  @override
  _ScrutinPageState createState() => _ScrutinPageState();
}

class _ScrutinPageState extends State<ScrutinPage> {
  final ScrutinService scrutinService = ScrutinService();
  List<Scrutin> displayedScrutins = [];
  List<Scrutin> allScrutins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScrutins();
  }

  Future<void> _loadScrutins() async {
    scrutinService.getActiveScrutins().listen((scrutins) {
      setState(() {
        allScrutins = scrutins;
        displayedScrutins = scrutins;
        isLoading = false;
      });
    });
  }

  void filterScrutins(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedScrutins = allScrutins;
      } else {
        displayedScrutins = allScrutins.where((scrutin) {
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
            'assets/images/no_data.png',
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
    final userProvider = Provider.of<UserProvider>(context);
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
        child: isLoading
            ? Center(child: CustomLoader())
            : Column(
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
                          suffixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // Liste des scrutins
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
                              final hasVoted =
                                  userProvider.hasVoted(scrutin.id);
                              final canVote = userProvider.canVote(
                                  scrutin.id, scrutin.voteMultiple);

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            style: TextStyle(
                                                color: Colors.grey[600]),
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
                                        onPressed: (statut == "Futur" ||
                                                (statut == "Terminé" &&
                                                    !hasVoted))
                                            ? null
                                            : () async {
                                                await userProvider
                                                    .checkUserVoteStatus(
                                                        scrutin.id);
                                                final hasVoted = userProvider
                                                    .hasVoted(scrutin.id);
                                                final canVote =
                                                    userProvider.canVote(
                                                        scrutin.id,
                                                        scrutin.voteMultiple);
                                                if (statut == "En cours") {
                                                  if (hasVoted && !canVote) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Text(
                                                          "Vote non autorisé",
                                                          style: TextStyle(
                                                              fontSize: 19,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: Text(
                                                            "Vous avez déjà voté pour ce scrutin et vous ne pouvez pas voter à nouveau."),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Text("OK",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    if (scrutin.code != null &&
                                                        scrutin
                                                            .code.isNotEmpty) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              VerifyPage(
                                                            scrutinId:
                                                                scrutin.id,
                                                            scrutinCode:
                                                                scrutin.code,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              VoteCandidatsPage(
                                                                  scrutinId:
                                                                      scrutin
                                                                          .id),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } else if (statut ==
                                                        "Terminé" &&
                                                    hasVoted) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ResultsPage(
                                                              scrutinId:
                                                                  scrutin.id),
                                                    ),
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (statut == "Futur" ||
                                                  (statut == "Terminé" &&
                                                      !hasVoted) ||
                                                  (hasVoted && !canVote))
                                              ? Colors.grey
                                              : AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          minimumSize: Size(70, 36),
                                        ),
                                        child: Text(
                                          statut == "Terminé"
                                              ? 'Résultats'
                                              : 'Voter',
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
