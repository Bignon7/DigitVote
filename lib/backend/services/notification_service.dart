import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/models/scrutin.dart';
import '../../backend/providers/user_provider.dart';

class NotificationService {
  static const String ONE_SIGNAL_APP_ID =
      '27027cfb-65c2-4f4b-9a8c-957f3b0abeef';
  static const String REST_API_KEY =
      'os_v2_app_e4bhz63fyjhuxgumsv7twcv657wwdfqatq7eztvicpiebfcnyorsufq4y5k3egaa4gzzt24tm36jyqbea7mo524ohmgynsbsy2hqfga';
  static Map<String, bool> _notificationsEnvoyees = {};

  static Future<void> initializeOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(ONE_SIGNAL_APP_ID);

    final permission = await OneSignal.Notifications.permission;
    if (permission == false) {
      await OneSignal.Notifications.requestPermission(true);
    }
  }

  static Future<void> sendWelcomeNotification(
      String email, String username) async {
    try {
      // Obtenir l'ID de l'appareil
      final userId = OneSignal.User.pushSubscription.id;

      if (userId != null) {
        // Ajouter des tags personnalisés à l'utilisateur
        await _addUserTags(email, username);

        // Envoyer la notification push de bienvenue
        await _sendNotificationViaRest(
          playerIds: [userId],
          title: 'Inscription réussie',
          content: 'Bienvenue sur Votify, $username !',
          data: {
            'type': 'welcome',
            'email': email,
            'username': username,
          },
        );
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
      rethrow;
    }
  }

  static Future<void> _addUserTags(String email, String username) async {
    try {
      final Map<String, Object> tags = {
        'email': email,
        'username': username,
        'last_login': DateTime.now().toIso8601String(),
      };

      await OneSignal.login(email);

      // Définir les tags sur l'utilisateur OneSignal
      OneSignal.User.addTagWithKey('email', email);
      OneSignal.User.addTagWithKey('username', username);
      OneSignal.User.addTagWithKey(
          'last_login', DateTime.now().toIso8601String());
    } catch (e) {
      print('Erreur lors de l\'ajout des tags: $e');
      rethrow;
    }
  }

  static Future<void> _sendNotificationViaRest({
    required List<String> playerIds,
    required String title,
    required String content,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = Uri.parse('https://onesignal.com/api/v1/notifications');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $REST_API_KEY',
      };

      final body = jsonEncode({
        'app_id': ONE_SIGNAL_APP_ID,
        'include_player_ids': playerIds,
        'headings': {'en': title},
        'contents': {'en': content},
        'data': data,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de l\'envoi de la notification: ${response.body}');
      }

      print('Notification envoyée avec succès: ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification via REST: $e');
      rethrow;
    }
  }

  static Future<void> sendScrutinTermineNotification({
    required String playerId,
    required String scrutinId,
    required String scrutinTitre,
    required String username,
  }) async {
    try {
      await _sendNotificationViaRest(
        playerIds: [playerId],
        title: 'Scrutin terminé',
        content:
            'Le scrutin "$scrutinTitre" pour lequel vous avez voté est maintenant terminé.',
        data: {
          'type': 'scrutin_termine',
          'scrutin_id': scrutinId,
          'username': username,
        },
      );
    } catch (e) {
      print(
          'Erreur lors de l\'envoi de la notification de scrutin terminé: $e');
      rethrow;
    }
  }

  static Future<void> checkAndNotifyScrutinTermine(
    Scrutin scrutin,
    UserProvider userProvider,
  ) async {
    try {
      final statut = scrutin.getStatut();
      print('Statut du scrutin ${scrutin.id} : $statut');
      print(
          'Date de clôture : ${scrutin.dateCloture}, Maintenant : ${DateTime.now()}');

      // Ne déclencher la notification que si le scrutin est terminé
      // et si une notification n'a pas déjà été envoyée pour ce scrutin.
      if (statut == "Terminé" && (_notificationsEnvoyees[scrutin.id] != true)) {
        // Vérifier si l'utilisateur a voté pour ce scrutin
        await userProvider.checkUserVoteStatus(scrutin.id);
        final voted = userProvider.hasVoted(scrutin.id);
        print('User hasVoted for scrutin ${scrutin.id} : $voted');

        if (voted) {
          final playerId = OneSignal.User.pushSubscription.id;
          print('OneSignal playerId: $playerId');

          if (playerId != null && userProvider.userData != null) {
            await sendScrutinTermineNotification(
              playerId: playerId,
              scrutinId: scrutin.id,
              scrutinTitre: scrutin.titre,
              username: userProvider.userData!['username'] ?? 'Utilisateur',
            );
            // Enregistrer dans la map que la notification a été envoyée pour ce scrutin.
            _notificationsEnvoyees[scrutin.id] = true;
            print('Notification envoyée pour le scrutin ${scrutin.id}');
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du scrutin terminé: $e');
    }
  }
}
