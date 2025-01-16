import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: MainPage(), // Ton widget MainPage avec navigation
    );
  }
}
