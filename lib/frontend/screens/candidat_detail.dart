import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../../backend/models/candidat.dart';
import 'package:digit_vote/frontend/utils/custom_loader.dart';

class CandidatDetailsPage extends StatelessWidget {
  final Candidat candidat;

  const CandidatDetailsPage({Key? key, required this.candidat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          candidat.nom,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            SizedBox(
              height: 30,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: candidat.image.isNotEmpty
                  ? Image.network(
                      candidat.image,
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
                        return CustomLoader();
                      },
                    )
                  : Image.asset(
                      'assets/images/default2.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 20),
            Text(
              candidat.nom,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              candidat.poste,
              style: TextStyle(fontSize: 18, color: Colors.grey[900]),
            ),
            SizedBox(height: 20),
            Text(
              candidat.biographie,
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Candidat sélectionné: ${candidat.nom}, ID: ${candidat.id}'),
                  ),
                );
                Navigator.pushNamed(context, '/success');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
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
