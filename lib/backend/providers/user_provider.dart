import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/models/scrutin.dart';
import '../../backend/services/notification_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;
  Map<String, bool> _userVotes = {};

  // Ajout de la liste des scrutins
  List<Scrutin> _scrutins = [];
  List<Scrutin> get scrutins => _scrutins;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  Future<void> fetchUserData(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _user = currentUser;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          _userData = doc.data();
        } else {
          _userData = {};
        }
        notifyListeners();
      } catch (e) {
        debugPrint(
            "Erreur lors de la récupération des données utilisateur: $e");
        _showErrorDialog(context, e.toString());
        _userData = {};
        notifyListeners();
      }
    }
  }

  Future<void> fetchScrutins() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('scrutins').get();

      _scrutins = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Scrutin.fromMap(data);
      }).toList();

      print('Scrutins récupérés: ${_scrutins.length}');
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des scrutins: $e");
    }
  }

  void listenScrutins() {
    FirebaseFirestore.instance
        .collection('scrutins')
        .snapshots()
        .listen((snapshot) {
      _scrutins = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Scrutin.fromMap(data);
      }).toList();
      print('Scrutins mis à jour: ${_scrutins.length}');
      notifyListeners();

      _scrutins.forEach((scrutin) async {
        await NotificationService.checkAndNotifyScrutinTermine(scrutin, this);
      });
    });
  }

  Future<void> checkUserVoteStatus(String scrutinId) async {
    if (_user == null) return;

    try {
      final QuerySnapshot votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('electeur_id', isEqualTo: _user!.uid)
          .where('scrutin_id', isEqualTo: scrutinId)
          .get();

      _userVotes[scrutinId] = votesSnapshot.docs.isNotEmpty;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la récupération du vote utilisateur: $e");
      //_showErrorDialog(context, e.toString());
    }
  }

  Future<void> refreshUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      _userData = userDoc.data();
      notifyListeners();
    }
  }

  bool hasVoted(String scrutinId) {
    return _userVotes[scrutinId] ?? false;
  }

  bool canVote(String scrutinId, bool voteMultiple) {
    return !hasVoted(scrutinId) || voteMultiple;
  }

  void clearUserData() {
    _user = null;
    _userData = null;
    _userVotes.clear();
    notifyListeners();
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(
          "Une erreur est survenue lors de la récupération des données utilisateur: $errorMessage",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
