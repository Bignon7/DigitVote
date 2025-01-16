import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Text(
          "Home Page",
          style: TextStyle(fontSize: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}
