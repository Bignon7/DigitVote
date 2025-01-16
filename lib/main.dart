// main.dart
import 'package:flutter/material.dart';
import './frontend/utils/colors.dart';
import './frontend/screens/home_page.dart';
import './frontend/screens/vote_page.dart';
import './frontend/screens/notifications_page.dart';
import './frontend/screens/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    HomePage(),
    VotePage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _pages[index];
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Couleur de l'ombre
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, -2), // Ombre vers le haut
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondary,
          backgroundColor: AppColors.background,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
          },
          items: [
            _buildBottomNavItem(Icons.home, 'Home', 0),
            _buildBottomNavItem(Icons.how_to_vote, 'Vote', 1),
            _buildBottomNavItem(Icons.notifications, 'Notifications', 2),
            _buildBottomNavItem(Icons.person, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          if (_currentIndex == index)
            Container(
              margin: const EdgeInsets.only(bottom: 4), // Espace sous la barre
              height: 3,
              width: 28,
              color: AppColors.primary,
            ),
          Icon(icon),
        ],
      ),
      label: label,
    );
  }
}
