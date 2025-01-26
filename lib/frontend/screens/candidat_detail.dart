import 'package:flutter/material.dart';
import '../utils/colors.dart';

class Candidat {
  final String id;
  final String name;
  final String poste;
  final String imageUrl;

  Candidat({
    required this.id,
    required this.name,
    required this.poste,
    required this.imageUrl,
  });
}

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
              child: Image.asset(
                candidat.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              candidat.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              candidat.poste,
              style: TextStyle(fontSize: 18, color: Colors.grey[900]),
            ),
            SizedBox(height: 20),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras facilisis, ornare est "
              "et volutpat gravida, urna purus bibendum libero, eu efficitur sapien lectus ut "
              "dolor. Integer a nisi turpis. Vivamus eleifend nisi ut turpis lacinia id dignissim "
              "quam ultricies. Mauris tempus libero at orci quis vulputate ut, amet lobortis "
              "sapien.",
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Candidat sélectionné: ${candidat.name}, ID: ${candidat.id}'),
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
