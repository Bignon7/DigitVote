import 'package:digit_vote/frontend/screens/edit_scruin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../backend/models/scrutin.dart';
import 'candidat_form.dart';
import '../utils/custom_loader.dart';
import 'charts_page.dart';
import 'candidat_for_scrutin.dart';

class ScrutinPage extends StatelessWidget {
  final String scrutinId;

  ///Mon dialog là
  void _demanderNombreCandidats(BuildContext context) {
    final TextEditingController _nombreController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Nombre de Candidats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Entrez le nombre de candidats que vous voulez ajouter'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _nombreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Nombre de candidats',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un nombre')),
                  );
                  return;
                }

                final nombre = int.tryParse(_nombreController.text);
                if (nombre == null || nombre <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez entrer un nombre valide')),
                  );
                  return;
                }

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CandidatFormSequence(
                      scrutinId: scrutinId,
                      nombreTotal: nombre,
                    ),
                  ),
                );
              },
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );
  }

  ///Mon dialog là
  Future<Scrutin> getScrutin(String scrutinId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('scrutins')
        .doc(scrutinId)
        .get();
    return Scrutin.fromMap(doc.data() as Map<String, dynamic>);
  }

  ScrutinPage({required this.scrutinId});
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat("d MMMM yyyy", "fr_FR");
      return formatter.format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du scrutin'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('scrutins')
            .doc(scrutinId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoader());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur lors du chargement du scrutin.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Scrutin introuvable.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final scrutinData = snapshot.data!.data() as Map<String, dynamic>;
          DateTime dateActuelle = DateTime.now();
          DateTime dateScrutin = DateTime.parse(scrutinData['date_ouverture']);
          bool scrutinCommence = dateActuelle.isAfter(dateScrutin) ||
              dateActuelle.isAtSameMomentAs(dateScrutin);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: scrutinData['image_scrutin'] != null &&
                              scrutinData['image_scrutin']!.isNotEmpty
                          ? Image.network(
                              scrutinData['image_scrutin']!,
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_scrutin_img.jpg',
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 300,
                                );
                              },
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return CustomLoader();
                              },
                            )
                          : Image.asset(
                              'assets/images/default_scrutin_img.jpg',
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      scrutinData['description'] ?? 'Pas de description.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Disponible du ${formatDate(scrutinData['date_ouverture'] ?? 'N/A')} au ${formatDate(scrutinData['date_cloture'] ?? 'N/A')}.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text('Consulter les Résultats'),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () async {
                        Scrutin scrutin = await getScrutin(scrutinId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResultsGraphPage(scrutin: scrutin)),
                        );
                      },
                    ),
                  ),
                  if (!scrutinCommence) ...[
                    SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text('Ajouter les candidats'),
                        trailing:
                            Icon(Icons.arrow_forward_ios, color: Colors.green),
                        onTap: () {
                          _demanderNombreCandidats(context);
                        },
                      ),
                    ),
                  ],
                  if (!scrutinCommence) ...[
                    SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text('Modifier le scrutin'),
                        trailing:
                            Icon(Icons.arrow_forward_ios, color: Colors.green),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UpdateScrutinScreen(scrutinId: scrutinId)),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text('Liste des candidats'),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CandidatForScrutinPage(
                                  scrutinId: scrutinId,
                                  scrutinCommence: scrutinCommence)),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
