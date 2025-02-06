import 'package:digit_vote/frontend/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../backend/services/services.dart';
import './login_page.dart';
import '../../backend/services/notification_service.dart';
import 'email_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  final BackendService _backendService = BackendService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isEmailValid(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    // Minimum 8 caractères, au moins une majuscule, une minuscule, un chiffre, et un caractère spécial
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Déclencher le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un credential Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inscription avec Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        //je gere ca dans mon backend
        await _backendService.inscrireUtilisateurGoogle(
          userCredential.user!.email!,
          userCredential.user!.displayName ?? 'Utilisateur Google',
        );
        await NotificationService.sendWelcomeNotification(
          userCredential.user!.email!,
          userCredential.user!.displayName ?? 'Utilisateur Google',
        );

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginPage()),
        // );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Une erreur s'est produite lors de l'inscription avec Google.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await _backendService.inscrireUtilisateur(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (user != null) {
        await NotificationService.sendWelcomeNotification(
          _emailController.text.trim(),
          _usernameController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "L'inscription a échoué. Essayez à nouveau.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur s'est produite : $e.toString()";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2FB364),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 40),
                  Text(
                    'Bienvenue,',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Inscrivez-vous !',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: "Nom d'utilisateur",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _usernameController.text.isNotEmpty
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le nom d'utilisateur est requis.";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _isEmailValid(_emailController.text)
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "L'email est requis.";
                              }
                              if (!_isEmailValid(value)) {
                                return "Veuillez entrer un email valide.";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le mot de passe est requis.";
                              }
                              if (!_isPasswordValid(value)) {
                                return "Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre, et un caractère spécial.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Error Message
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2FB364),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "S'inscrire",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          // Séparateur "OU"
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[400])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OU',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Google Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _signUpWithGoogle,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_logo.jpg',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continuer avec Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Login Link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Déjà inscrit(e) ? ",
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Connectez-vous !",
                                      style: TextStyle(
                                        color: const Color(0xFF2FB364),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
