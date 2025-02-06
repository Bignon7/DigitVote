import 'dart:async';
import '../../backend/providers/user_provider.dart';
import '../../backend/models/scrutin.dart';
import './notification_service.dart';

class ScrutinNotificationManager {
  Timer? _timer;
  final UserProvider _userProvider;

  ScrutinNotificationManager(this._userProvider);

  void startMonitoring(List<Scrutin> scrutins) {
    // Vérifier immédiatement
    _checkScrutins(scrutins);

    // Puis vérifier toutes les 5 minutes
    _timer = Timer.periodic(Duration(minutes: 5), (_) {
      _checkScrutins(scrutins);
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkScrutins(List<Scrutin> scrutins) async {
    for (var scrutin in scrutins) {
      await NotificationService.checkAndNotifyScrutinTermine(
        scrutin,
        _userProvider,
      );
    }
  }
}