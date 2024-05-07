import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AutoLogout {
  Timer? _timer;
  final Duration _inactivityDuration = Duration(minutes: 100);
  // TODO:Fix your inactivity duration

  void startTimer() {
    _timer = Timer(_inactivityDuration, () {
      print(_timer);
      // Trigger logout action
      FirebaseAuth.instance.signOut();
      print("User logged out due to inactivity");
    });
  }

  void resetTimer() {
    _timer?.cancel();
    startTimer();
  }
}