import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'scrutin_form.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable pour suivre la page actuelle
  bool showHomeOne = true;

  // Méthode pour basculer entre HomeOne et HomeTwo
  void togglePage() {
    setState(() {
      showHomeOne = !showHomeOne;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showHomeOne ? HomeOne(togglePage) : HomeTwo(togglePage),
    );
  }
}

class HomeOne extends StatelessWidget {
  final VoidCallback onToggle;

  HomeOne(this.onToggle);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/illustrations/2.jpg', // Image principale
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Organisez vos scrutins avec ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextSpan(
                    text: "Votify",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                //Navigator.pushNamed(context, '/accueil');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateScrutinForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                "Créer un scrutin",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onTap: onToggle, // Basculer à HomeTwo
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Vous voulez participer à un vote ? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: "Cliquez ici !",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTwo extends StatelessWidget {
  final VoidCallback onToggle;

  HomeTwo(this.onToggle);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/illustrations/3.jpg', // Image principale
              height: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Votez en toute sécurité avec  ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextSpan(
                    text: "Votify",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action pour accéder à la liste des scrutins
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                "Liste des scrutins",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: onToggle, // Basculer à HomeTwo
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Vous voulez créer un scrutin ? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: "Cliquez ici !",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
