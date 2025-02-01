import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/providers/user_provider.dart';
import '../../utils/colors.dart';
import '../scrutin_details.dart';
import '../../utils/custom_loader.dart';

class NotificationsPage extends StatelessWidget {
  final ScrutinService scrutinService = ScrutinService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final userId = userProvider.user!.uid;

    if (user == null) {
      return Center(
        child: Text(
          "Erreur : utilisateur non authentifié.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes scrutins',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Scrutin>>(
          stream: scrutinService.getScrutinsByCreateur(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomLoader());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur lors du chargement des scrutins.",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 100, color: Colors.grey[400]),
                    SizedBox(height: 20),
                    Text(
                      "Aucun scrutin créé.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final scrutins = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: scrutins.length,
              itemBuilder: (context, index) {
                final scrutin = scrutins[index];
                return Column(
                  children: [
                    _buildScrutinCard(scrutin, context),
                    SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildScrutinCard(Scrutin scrutin, BuildContext context) {
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
                Text(
                  scrutin.titre ?? "Titre inconnu",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Ajouter des actions ou des paramètres ici
                  },
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
                      'Modifier',
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
