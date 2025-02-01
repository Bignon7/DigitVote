/*
///candidats_page

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'candidat_detail.dart';
//import 'package:digit_vote/backend/models/scrutin.dart';
//import 'candidats_page.dart';

class VoteCandidatsPage extends StatefulWidget {
  final String scrutinId;

  VoteCandidatsPage({required this.scrutinId});
  @override
  _VoteCandidatsPageState createState() => _VoteCandidatsPageState();
}

class _VoteCandidatsPageState extends State<VoteCandidatsPage> {
  List<Candidat> allCandidats = [
    Candidat(
        id: "1",
        name: "ADJE Erick",
        poste: "Poste de Directeur Générale",
        imageUrl: "assets/images/hees.jpg"),
    Candidat(
        id: "2",
        name: "Comlan Maurice",
        poste: "Poste de Directeur Générale",
        imageUrl: "assets/images/hees.jpg"),
    Candidat(
        id: "3",
        name: "ADANDE Teophile",
        poste: "Poste de Directeur Générale",
        imageUrl: "assets/images/hees.jpg"),
    Candidat(
        id: "4",
        name: "ADJIBIDJI Colette",
        poste: "Poste de Directeur Générale",
        imageUrl: "assets/images/hees.jpg"),
    Candidat(
        id: "5",
        name: "Lokonon Edouard",
        poste: "Poste de Directeur Générale",
        imageUrl: "assets/images/hees.jpg"),
  ];

  List<Candidat> filteredCandidats = [];
  String? selectedCandidatId;

  @override
  void initState() {
    super.initState();
    filteredCandidats = allCandidats;
  }

  void filterCandidats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCandidats = allCandidats;
      } else {
        filteredCandidats = allCandidats.where((candidat) {
          return candidat.name.toLowerCase().contains(query.toLowerCase()) ||
              candidat.poste.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToDetails(BuildContext context, Candidat candidat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatDetailsPage(candidat: candidat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des candidats',
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
            // Liste ou image si vide
            Expanded(
              child: filteredCandidats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/no_data.png",
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
                                backgroundImage: AssetImage(candidat.imageUrl),
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
                            trailing: Radio<String>(
                              value: candidat.id,
                              groupValue: selectedCandidatId,
                              onChanged: (value) {
                                setState(() {
                                  selectedCandidatId = value;
                                });
                              },
                              activeColor: const Color(0xFF2FB364),
                              toggleable: true,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCandidatId != null) {
                    final selectedCandidat = allCandidats
                        .firstWhere((c) => c.id == selectedCandidatId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Candidat sélectionné: ${selectedCandidat.name}, ID: ${selectedCandidat.id}'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FB364),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Envoyer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }
}







/*
class CandidatDetailsPage extends StatelessWidget {
  final Candidat candidat;

  const CandidatDetailsPage({Key? key, required this.candidat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          candidat.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(candidat.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              candidat.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              candidat.poste,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
*/


*/






//autre  sssssssssssssssssssssssssss recherceh reload

/*   

///candidats avec recherche load
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:digit_vote/backend/services/candidat_service.dart';
import 'candidat_detail.dart';
import '../utils/custom_loader.dart';
import '../../backend/models/candidat.dart';

class VoteCandidatsPage extends StatefulWidget {
  final String scrutinId;

  VoteCandidatsPage({required this.scrutinId});

  @override
  _VoteCandidatsPageState createState() => _VoteCandidatsPageState();
}

class _VoteCandidatsPageState extends State<VoteCandidatsPage> {
  List<Candidat> allCandidats = [];
  List<Candidat> filteredCandidats = [];
  String? selectedCandidatId;
  final CandidatService candidatService = CandidatService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void filterCandidats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCandidats = allCandidats;
      } else {
        filteredCandidats = allCandidats.where((candidat) {
          return candidat.nom.toLowerCase().contains(query.toLowerCase()) ||
              candidat.poste.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToDetails(BuildContext context, Candidat candidat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatDetailsPage(candidat: candidat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des candidats',
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
                  controller: _searchController,
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
            // Liste des candidats
            Expanded(
              child: StreamBuilder<List<Candidat>>(
                stream: candidatService.getCandidatsByScrutin(widget.scrutinId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoader());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/no_data.png",
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
                    );
                  }

                  allCandidats = snapshot.data!;
                  filteredCandidats = _searchController.text.isEmpty
                      ? allCandidats
                      : filteredCandidats;

                  if (_searchController.text.isNotEmpty &&
                      filteredCandidats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/no_data.png",
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Aucun candidat ne correspond à votre recherche",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredCandidats.length,
                    itemBuilder: (context, index) {
                      final candidat = filteredCandidats[index];
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
                            onTap: () => _navigateToDetails(context, candidat),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: candidat.image.isEmpty
                                  ? AssetImage("assets/images/hees.jpg")
                                  : NetworkImage(candidat.image)
                                      as ImageProvider<Object>,
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () => _navigateToDetails(context, candidat),
                            child: Text(
                              candidat.nom,
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
                          trailing: Radio<String>(
                            value: candidat.id,
                            groupValue: selectedCandidatId,
                            onChanged: (value) {
                              setState(() {
                                selectedCandidatId = value;
                              });
                            },
                            activeColor: const Color(0xFF2FB364),
                            toggleable: true,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCandidatId != null) {
                    final selectedCandidat = allCandidats
                        .firstWhere((c) => c.id == selectedCandidatId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Candidat sélectionné: ${selectedCandidat.nom}, ID: ${selectedCandidat.id}'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FB364),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Envoyer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }
}

/*
class CandidatDetailsPage extends StatelessWidget {
  final Candidat candidat;

  const CandidatDetailsPage({Key? key, required this.candidat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          candidat.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(candidat.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              candidat.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              candidat.poste,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
*/


*/


