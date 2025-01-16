import 'package:flutter/material.dart';
import './home_page.dart';
import './vote_page.dart';
import './notifications_page.dart';
import './profile_page.dart';
import '../utils/colors.dart';

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
        itemBuilder: (context, index) => _pages[index],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
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

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          if (_currentIndex == index)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
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
