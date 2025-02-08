import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './login_page.dart';
import '../utils/colors.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "type": "image",
      "title": "Bienvenue sur Votify",
      "subtitle": "L'application de vote simple et sécurisée.",
      "asset": "assets/illustrations/welcome_screen.png",
    },
    {
      "type": "image",
      "title": "Créez vos scrutins",
      "subtitle": "Organisez des scrutins en quelques clics.",
      "asset": "assets/illustrations/create_screen.png",
    },
    {
      "type": "image",
      "title": "Participez aux scrutins",
      "subtitle": "Exprimez votre voix avec simplicité.",
      "asset": "assets/illustrations/vote_screen1.png",
    },
    {
      "type": "image",
      "title": "Consultez les résultats",
      "subtitle": "Visualisez les résultats de manière claire.",
      "asset": "assets/illustrations/chart_screen1.png",
    },
  ];

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _onNext() {
    if (_currentPage == _slides.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    slide["type"] == "image"
                        ? Image.asset(slide["asset"]!, height: 300)
                        : Container(
                            height: 300,
                            child: Lottie.asset(slide["asset"]!),
                          ),
                    SizedBox(height: 20),
                    Text(
                      slide["title"]!,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      slide["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index ? AppColors.primary : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkip,
                  child: Text("Passer", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: _onNext,
                  child: Text(_currentPage == _slides.length - 1
                      ? "Commencer"
                      : "Suivant"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
