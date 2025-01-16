import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Indique si l'utilisateur est en mode connexion
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Connexion' : 'Inscription'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Champ pour l'email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Champ pour le mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe.';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit comporter au moins 6 caractères.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Message d'erreur
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              // Bouton pour valider
              ElevatedButton(
                onPressed: _isLogin ? _login : _register,
                child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
              ),
              SizedBox(height: 16),
              // Lien pour basculer entre connexion et inscription
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null; // Réinitialiser le message d'erreur
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Pas encore de compte ? Inscrivez-vous'
                      : 'Déjà un compte ? Connectez-vous',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
