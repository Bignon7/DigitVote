import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Text(
          "Profil Page",
          style: TextStyle(fontSize: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}
