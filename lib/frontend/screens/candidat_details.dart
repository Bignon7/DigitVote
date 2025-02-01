import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/custom_loader.dart';
import '../../backend/services/candidat_service.dart';
import '../../backend/models/candidat.dart';
import '../utils/getImage_widget.dart';

class CandidatDetailsPage extends StatefulWidget {
  final String candidatId;

  const CandidatDetailsPage({Key? key, required this.candidatId})
      : super(key: key);

  @override
  _CandidatDetailsPageState createState() => _CandidatDetailsPageState();
}

class _CandidatDetailsPageState extends State<CandidatDetailsPage> {
  final CandidatService _candidatService = CandidatService();
  bool _isLoading = true;
  late Candidat _candidat;

  @override
  void initState() {
    super.initState();
    _loadCandidatDetails();
  }

  Future<void> _loadCandidatDetails() async {
    try {
      final candidat =
          await _candidatService.getCandidatById(widget.candidatId);
      setState(() {
        _candidat = candidat;
        _isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          content: Text('Erreur lors du chargement des détails: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du candidat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: getImageProvider(_candidat.image),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    'Nom',
                    _candidat.nom,
                    Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Biographie',
                    _candidat.biographie,
                    Icons.article,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Nombre de votes',
                    _candidat.nombreVotes.toString(),
                    Icons.how_to_vote,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
