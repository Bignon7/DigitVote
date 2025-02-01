import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digit_vote/backend/models/candidat.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:digit_vote/backend/services/scrutin_service.dart';
import 'package:digit_vote/backend/models/scrutin.dart';
import 'package:digit_vote/frontend/utils/custom_loader.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';

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

                        final DateTime now = DateTime.now();
                        final DateTime ouverture = scrutin.dateOuverture;
                        final DateTime cloture = scrutin.dateCloture;
                        final bool isOuvert =
                            now.isAfter(ouverture) && now.isBefore(cloture);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResultsGraphPage(scrutin: scrutin),
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
                                      color: isOuvert
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isOuvert ? Icons.how_to_vote : Icons.lock,
                                      color:
                                          isOuvert ? Colors.green : Colors.red,
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

class ResultsGraphPage extends StatefulWidget {
  final Scrutin scrutin;

  const ResultsGraphPage({super.key, required this.scrutin});

  @override
  _ResultsGraphPageState createState() => _ResultsGraphPageState();
}

class _ResultsGraphPageState extends State<ResultsGraphPage> {
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
          'Résultats: ${widget.scrutin.titre}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Candidat>>(
        future: getCandidats(widget.scrutin.candidatsIds),
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
                  Image.asset("assets/images/empty.jpg", height: 150),
                  const SizedBox(height: 17),
                  const Text(
                    "Aucun résultat trouvé",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final candidats = snapshot.data!;
          final totalVotes = candidats.fold<int>(
              0, (sum, candidat) => sum + candidat.nombreVotes);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPieChart(candidats, totalVotes),
                    const SizedBox(height: 20),
                    _buildCandidateList(candidats, totalVotes),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(List<Candidat> candidats, int totalVotes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        //border: Border.all(color: AppColors.primary, width: 2),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Répartition des votes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: candidats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final candidat = entry.value;
                      final color = _generateDistinctColor(index);
                      final percentage = totalVotes > 0
                          ? (candidat.nombreVotes / totalVotes) * 100
                          : 0;

                      return PieChartSectionData(
                        value: candidat.nombreVotes.toDouble(),
                        color: color,
                        radius: 40,
                        title: '${percentage.toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent &&
                            pieTouchResponse?.touchedSection != null) {
                          final index = pieTouchResponse!
                              .touchedSection!.touchedSectionIndex;
                          final candidat = candidats[index];

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.white,
                              title: Text(candidat.nom,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              content: Text("${candidat.nombreVotes} vote(s)",
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      "$totalVotes\nvotes",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList(List<Candidat> candidats, int totalVotes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: candidats.map((candidat) {
        final index = candidats.indexOf(candidat);
        final color = _generateDistinctColor(index);
        final percentage =
            totalVotes > 0 ? (candidat.nombreVotes / totalVotes) * 100 : 0;
        final fraction =
            totalVotes == 0 ? 0 : (candidat.nombreVotes / totalVotes);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 16,
                      height: 16,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        '${candidat.nom} - ${candidat.nombreVotes} vote(s)',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  Text('${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: fraction.toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _generateDistinctColor(int index) {
    List<Color> colors = [
      const Color(0xFF2FB364),
      //
      Color(0xFF48BE78),
      //Color(0xFF61C88C),
      Color(0xFF7AD2A0),
      //Color(0xFF94DCB4),
      Color(0xFFAEE6C8),
      //Color(0xFFC7F0DC),
      //const Color(0xFF1D7128),
      const Color(0xFF66CDAA),
      const Color(0xFF9ACD32),
      const Color(0xFF32CD32),
      const Color(0xFF228B22),
      const Color.fromARGB(255, 110, 120, 124),
      const Color.fromARGB(255, 131, 129, 125),
    ];
    return colors[index % colors.length];
  }
}
