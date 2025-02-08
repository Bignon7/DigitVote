import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './login_page.dart';
import '../utils/colors.dart';
import 'main_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({Key? key, required this.email})
      : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _emailVerified = false;
  bool _isLoading = false;
  bool _emailSent = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _timer;
  StreamSubscription? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateSubscription =
        FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user!.emailVerified) {
          if (!mounted) return;
          setState(() => _emailVerified = true);

          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    int retryCount = 5;

    for (int i = 0; i < retryCount; i++) {
      await user?.reload();
      await Future.delayed(Duration(seconds: 2));
      if (user?.emailVerified ?? false) {
        setState(() => _emailVerified = true);
        break;
      }
    }
    setState(() => _isLoading = false);
    if (_emailVerified) {
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        User? updatedUser = FirebaseAuth.instance.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
            (route) => false,
          );
        }
      } catch (e) {
        print("Erreur lors du rafraîchissement de l'utilisateur : $e");
      }
    } else {
      _showAlertDialog(
          "Échec", "Votre email n'est pas encore vérifié. Veuillez réessayer.");
    }
  }

  void _resendVerificationEmail() async {
    try {
      setState(() => _isResending = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        setState(() {
          _emailSent = true;
          _resendCooldown = 30;
          _isResending = false;
        });

        _showAlertDialog(
            "Email envoyé", "Un nouvel email de vérification a été envoyé.");

        _timer?.cancel();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            if (_resendCooldown > 0) {
              _resendCooldown--;
            } else {
              _timer?.cancel();
              _emailSent = false;
            }
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isResending = false);
      if (e.code == "too-many-requests") {
        _showAlertDialog("Erreur",
            "Vous avez demandé trop d'emails en peu de temps.\nVeuillez réessayer plus tard.");
      } else {
        _showAlertDialog("Erreur", "Une erreur s'est produite : ${e.message}");
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text("Vérification de l'email",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage())),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Center(
                child: Image.asset(
                  'assets/illustrations/email_verif2.png',
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              Text("Un email de vérification a été envoyé à :",
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(widget.email,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(
                  "Veuillez vérifier votre boîte mail et cliquer sur le lien de confirmation.",
                  textAlign: TextAlign.center),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: (_emailSent || _resendCooldown > 0)
                    ? null
                    : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
                child: _isResending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Envoi en cours...",
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : _resendCooldown > 0
                        ? Text("Attendez ($_resendCooldown) s",
                            style: TextStyle(color: Colors.white))
                        : Text("Renvoyer l'email",
                            style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkEmailVerified,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Vérification...",
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : Text("J'ai vérifié mon email",
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
