import 'package:digit_vote/frontend/screens/succespage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../../backend/models/candidat.dart';
import '../../backend/models/vote.dart';
import '../../backend/services/vote_service.dart';
import '../../backend/providers/user_provider.dart';
import 'package:animate_do/animate_do.dart';

import '../utils/getImage_widget.dart';

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
            color: Colors.white,
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: getImage(widget.candidat.image),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.candidat.nom,
                    style: GoogleFonts.lobster(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.candidat.biographie,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitVote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Choisir",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
