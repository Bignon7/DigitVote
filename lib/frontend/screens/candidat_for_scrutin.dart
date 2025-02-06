import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/custom_loader.dart';
import '../../backend/services/candidat_service.dart';
import '../../backend/models/candidat.dart';
import '../utils/getImage_widget.dart';
import './candidat_details.dart';
import './edit_candidats.dart';

class CandidatForScrutinPage extends StatefulWidget {
  final String scrutinId;
  final bool scrutinCommence;

  CandidatForScrutinPage(
      {required this.scrutinId, required this.scrutinCommence});

  @override
  _CandidatForScrutinPageState createState() => _CandidatForScrutinPageState();
}

class _CandidatForScrutinPageState extends State<CandidatForScrutinPage> {
  final TextEditingController _searchController = TextEditingController();
  final CandidatService _candidatService = CandidatService();

  List<Candidat> _allCandidats = [];
  List<Candidat> _filteredCandidats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupCandidatsStream();
  }

  void _setupCandidatsStream() {
    _candidatService
        .getCandidatsByScrutin(widget.scrutinId)
        .listen((candidats) {
      setState(() {
        _allCandidats = candidats;
        _filterCandidats(_searchController.text);
        _isLoading = false;
      });
    });
  }

  void _filterCandidats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCandidats = _allCandidats;
      } else {
        _filteredCandidats = _allCandidats
            .where((candidat) =>
                candidat.nom.toLowerCase().contains(query.toLowerCase()) ||
                candidat.biographie.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _showDeleteConfirmation(Candidat candidat) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer ce candidat ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _candidatService.deleteCandidat(candidat.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Candidat supprimé avec succès')),
                );
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Candidats du scrutin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                  onChanged: _filterCandidats,
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CustomLoader())
                  : _filteredCandidats.isEmpty
                      ? buildEmptyListMessage()
                      : ListView.builder(
                          itemCount: _filteredCandidats.length,
                          itemBuilder: (context, index) {
                            final candidat = _filteredCandidats[index];
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
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      getImageProvider(candidat.image),
                                ),
                                title: Text(
                                  candidat.nom,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  candidat.biographie,
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                trailing: widget.scrutinCommence
                                    ? IconButton(
                                        icon: Icon(Icons.visibility,
                                            color: AppColors.primary),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CandidatDetailsPage(
                                                        candidatId:
                                                            candidat.id)),
                                          );
                                        },
                                      )
                                    : PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'view') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CandidatDetailsPage(
                                                        candidatId:
                                                            candidat.id),
                                              ),
                                            );
                                          } else if (value == 'edit') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCandidatPage(
                                                        candidatId:
                                                            candidat.id),
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(candidat);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'view',
                                            child: ListTile(
                                              leading: Icon(Icons.visibility,
                                                  color: AppColors.primary),
                                              title: Text('Voir'),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit,
                                                  color: Colors.orange),
                                              title: Text('Modifier'),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete,
                                                  color: Colors.red),
                                              title: Text('Supprimer'),
                                            ),
                                          ),
                                        ],
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

  Widget buildEmptyListMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/illustrations/no_data2.png',
            height: 200,
          ),
          //SizedBox(height: 20),
          Text(
            "Aucun candidat trouvé",
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
}
