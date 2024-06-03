import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MyBank/screens/dashboard.dart';
import 'package:MyBank/screens/home.dart';
import 'login.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}); // Fixed the constructor signature

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?> (
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User? userData = snapshot.data; // Fixed the variable name
            return DashBoard(user: userData); // Fixed the parameter name
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
