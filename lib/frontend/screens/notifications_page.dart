import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/providers/user_provider.dart';
import '../utils/colors.dart';
import 'scrutin_details.dart';
import '../utils/custom_loader.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Utilisateur non authentifié. Veuillez vous connecter."),
        ),
      );
      return;
    }
    final userId = userProvider.user!.uid;
    scrutinService.getScrutinsByCreateur(userId).listen((scrutins) {
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
              scrutin.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat("dd MMMM yyyy", "fr_FR");
    return formatter.format(date);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes scrutins',
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
                            padding: const EdgeInsets.all(20),
                            itemCount: displayedScrutins.length,
                            itemBuilder: (context, index) {
                              final scrutin = displayedScrutins[index];

                              return Column(
                                children: [
                                  _buildScrutinCard(scrutin, context),
                                  SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScrutinCard(Scrutin scrutin, BuildContext context) {
    final color = scrutin.getStatut() == "En cours"
        ? Colors.green
        : scrutin.getStatut() == "Futur"
            ? Colors.blue
            : Colors.red;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    scrutin.titre ?? "Titre inconnu",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  scrutin.getStatut(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              scrutin.description ?? "Pas de description disponible.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  "Ouverture: ${_formatDate(scrutin.dateOuverture)}",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  "Clôture: ${_formatDate(scrutin.dateCloture)}",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Action Supprimer
                      _deleteScrutin(context, scrutin.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScrutinPage(
                            scrutinId: scrutin.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Gérer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteScrutin(BuildContext context, String scrutinId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: Text("Voulez-vous vraiment supprimer ce scrutin ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Annuler",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                scrutinService.deleteScrutin(scrutinId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Supprimer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
