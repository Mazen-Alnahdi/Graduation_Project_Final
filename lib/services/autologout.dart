import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class AutoLogout {
  Timer? _timer;
  final Duration _inactivityDuration = Duration(
      // minutes: ,
      hours: 10);
  // TODO:Fix your inactivity duration

  void startTimer() {
    _timer = Timer(_inactivityDuration, () {
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


