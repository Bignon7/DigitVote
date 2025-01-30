import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digit_vote/backend/models/candidat.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/frontend/utils/custom_loader.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Scrutin> scrutins = [];
  List<Scrutin> filteredScrutins = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadAllScrutins();
  }

  void _loadAllScrutins() {
    ScrutinService().getAllScrutins().listen((scrutinsData) {
      setState(() {
        scrutins = scrutinsData;
        filteredScrutins = scrutins;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats des Scrutins'),
        backgroundColor: Colors.blue,
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
              child: TextField(
                onChanged: filterScrutins,
                decoration: InputDecoration(
                  hintText: 'Rechercher un scrutin',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Affichage des résultats
            Expanded(
              child: filteredScrutins.isEmpty
                  ? Center(child: Text('Aucun scrutin trouvé'))
                  : ListView.builder(
                      itemCount: filteredScrutins.length,
                      itemBuilder: (context, index) {
                        final scrutin = filteredScrutins[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(scrutin.titre),
                            subtitle: Text(scrutin.description),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultsGraphPage(
                                    scrutin: scrutin,
                                  ),
                                ),
                              );
                            },
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

class ResultsGraphPage extends StatelessWidget {
  final Scrutin scrutin;

  const ResultsGraphPage({super.key, required this.scrutin});

  Future<List<Candidat>> getCandidats(List<String> candidatsIds) async {
    List<Candidat> candidats = [];
    final candidatsCollection =
        FirebaseFirestore.instance.collection('candidats');

    for (String id in candidatsIds) {
      final doc = await candidatsCollection.doc(id).get();
      if (doc.exists) {
        candidats.add(Candidat.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    candidats.sort((a, b) => b.nombreVotes.compareTo(a.nombreVotes));
    return candidats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats du scrutin: ${scrutin.titre}'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Candidat>>(
        future: getCandidats(scrutin.candidatsIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoader());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erreur lors du chargement des résultats'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun résultat trouvé'));
          }

          final candidats = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: candidats.first.nombreVotes.toDouble() + 5,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${candidats[group.x].nom}\n${rod.toY.toInt()} votes',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(value.toInt().toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    candidats[value.toInt()].nom,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: candidats.map((candidat) {
                          return BarChartGroupData(
                            x: candidats.indexOf(candidat),
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(
                                    candidat.nombreVotes.toString()),
                                color: _getCandidatColor(
                                    candidats.indexOf(candidat)),
                                width: 14,
                                borderRadius: BorderRadius.circular(8),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: candidats.first.nombreVotes.toDouble() +
                                      5,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCandidateList(candidats),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCandidatColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal
    ];
    return colors[index % colors.length];
  }

  Widget _buildCandidateList(List<Candidat> candidats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: candidats.map((candidat) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _getCandidatColor(candidats.indexOf(candidat)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${candidat.nom} - ${candidat.nombreVotes} votes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
