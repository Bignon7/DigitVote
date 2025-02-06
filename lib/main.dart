import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './frontend/utils/colors.dart';
import '../../backend/providers/user_provider.dart';
import 'dart:async';
import './frontend/screens/welcome_page.dart';
import '../../backend/services/notification_service.dart';
import '../../backend/services/scrutin_notification_manager.dart';
import 'dart:core';

void main() async {
  const supabaseUrl = 'https://aazzaadoagikcnvicxll.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhenphYWRvYWdpa2NudmljeGxsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgwNDYyMDgsImV4cCI6MjA1MzYyMjIwOH0.2XP2W-TBUk0rjXXbK9Q5LXwX8raJqO0Z_F5WzE5Sae8';
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(seconds: 1));
  await NotificationService.initializeOneSignal();
  await Firebase.initializeApp();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final userProvider = UserProvider();
            userProvider.fetchUserData(context);
            userProvider.listenScrutins(); // Utiliser le listener en temps réel
            return userProvider;
          },
        ),
      ],
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            },
          ),
          fontFamily: 'Nunito',
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ScrutinNotificationManager? _scrutinNotificationManager;
  bool _monitoringStarted = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.addListener(() {
        if (!_monitoringStarted && userProvider.scrutins.isNotEmpty) {
          _monitoringStarted = true;
          _scrutinNotificationManager =
              ScrutinNotificationManager(userProvider);
          _scrutinNotificationManager!.startMonitoring(userProvider.scrutins);
          print(
              "Monitoring démarré avec ${userProvider.scrutins.length} scrutins.");
        }
      });

      if (userProvider.scrutins.isNotEmpty) {
        _monitoringStarted = true;
        _scrutinNotificationManager = ScrutinNotificationManager(userProvider);
        _scrutinNotificationManager!.startMonitoring(userProvider.scrutins);
        print(
            "Monitoring démarré immédiatement avec ${userProvider.scrutins.length} scrutins.");
      } else {
        print("Aucun scrutin à surveiller pour le moment.");
      }
    });
  }

  @override
  void dispose() {
    _scrutinNotificationManager?.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          'Votify',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
