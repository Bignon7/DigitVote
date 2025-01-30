import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import 'package:digit_vote/backend/services/candidat_service.dart';
import 'package:digit_vote/backend/services/vote_service.dart';
import 'package:digit_vote/backend/providers/user_provider.dart';
import 'package:digit_vote/backend/models/vote.dart';
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
  StreamSubscription<List<Candidat>>? _candidatsSubscription;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final VoteService _voteService = VoteService();

  Future<void> _submitVote() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user == null) {
        throw Exception("Utilisateur non authentifié !");
      }

      // Créer un objet Vote
      final vote = Vote(
        id: "",
        electeurId: userProvider.user!.uid,
        scrutinId: widget.scrutinId,
        candidatId: selectedCandidatId!,
        dateVote: DateTime.now(),
      );

      await _voteService.createVote(vote, userProvider.user!.uid);

      setState(() {
        _isSubmitting = false;
      });
      Navigator.pushNamed(context, '/success');
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Une erreur est survenue',
            style: TextStyle(
                fontSize: 19, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "${e.toString().contains(':') ? e.toString().split(':').last.trim() : e.toString()}",
            style: const TextStyle(
                fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCandidats();
  }

  void _fetchCandidats() {
    _candidatsSubscription = candidatService
        .getCandidatsByScrutin(widget.scrutinId)
        .listen((candidats) {
      setState(() {
        allCandidats = candidats;
        filteredCandidats = _searchController.text.isEmpty
            ? allCandidats
            : allCandidats
                .where((c) =>
                    c.nom
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()) ||
                    c.poste
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                .toList();
        _isLoading = false;
      });
    });
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
  void dispose() {
    _candidatsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
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
              child: _isLoading
                  ? const Center(child: CustomLoader())
                  : allCandidats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_data.png",
                                height: 150,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Aucun candidat trouvé",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : filteredCandidats.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no_data.png",
                                    height: 150,
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    "Aucun candidat ne correspond à votre recherche",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
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
                                        backgroundImage: candidat.image.isEmpty
                                            ? const AssetImage(
                                                "assets/images/default2.png")
                                            : NetworkImage(candidat.image)
                                                as ImageProvider<Object>,
                                      ),
                                    ),
                                    title: GestureDetector(
                                      onTap: () =>
                                          _navigateToDetails(context, candidat),
                                      child: Text(
                                        candidat.nom,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    subtitle: Text(
                                      candidat.poste,
                                      style:
                                          const TextStyle(color: Colors.grey),
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
                onPressed: selectedCandidatId == null
                    ? null
                    : () {
                        if (selectedCandidatId != null) {
                          setState(() {
                            _isSubmitting = true;
                          });
                          _submitVote();
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
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
    );
  }
}
