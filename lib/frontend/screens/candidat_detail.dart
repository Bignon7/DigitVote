import 'package:digit_vote/frontend/screens/succespage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../../backend/models/candidat.dart';
import '../../backend/models/vote.dart';
import '../../backend/services/vote_service.dart';
import '../../backend/providers/user_provider.dart';
import '../utils/custom_loader.dart';

class CandidatDetailsPage extends StatefulWidget {
  final Candidat candidat;
  final String scrutinId;

  const CandidatDetailsPage({
    Key? key,
    required this.candidat,
    required this.scrutinId,
  }) : super(key: key);

  @override
  _CandidatDetailsPageState createState() => _CandidatDetailsPageState();
}

class _CandidatDetailsPageState extends State<CandidatDetailsPage> {
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

      final vote = Vote(
        id: "",
        electeurId: userProvider.user!.uid,
        scrutinId: widget.scrutinId,
        candidatId: widget.candidat.id,
        dateVote: DateTime.now(),
      );

      await _voteService.createVote(vote, userProvider.user!.uid);

      setState(() {
        _isSubmitting = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Une erreur est survenue',
          style: TextStyle(
            fontSize: 19,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message.contains(':') ? message.split(':').last.trim() : message,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.candidat.nom,
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: widget.candidat.image.isNotEmpty
                  ? Image.network(
                      widget.candidat.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default2.png',
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const CustomLoader();
                      },
                    )
                  : Image.asset(
                      'assets/images/default2.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.candidat.nom,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.candidat.biographie,
              style: TextStyle(fontSize: 18, color: Colors.grey[900]),
            ),
            const SizedBox(height: 20),
            Text(
              widget.candidat.biographie,
              style: const TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitVote,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Choisir",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
