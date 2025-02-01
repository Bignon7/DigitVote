import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digit_vote/backend/models/candidat.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/frontend/utils/custom_loader.dart';

//import '../utils/colors.dart';

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
        title: const Text(
          'Résultats des Scrutins',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        //backgroundColor: AppColors.primary,
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
                  onChanged: filterScrutins,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher  un scrutin',
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
        title: Text(
          'Résultats du scrutin: ${scrutin.titre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Candidat>>(
        future: getCandidats(scrutin.candidatsIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoader());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/empty.jpg",
                    height: 150,
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    "Aucun résultat trouvé",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
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
                            offset: Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: candidats.first.nombreVotes.toDouble() + 5,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
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
                                }),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Transform.rotate(
                                  angle: -0.5,
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
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
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
