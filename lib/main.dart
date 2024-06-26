import 'dart:async';
import 'package:rename/rename.dart';
import 'package:flutter/material.dart';
import 'package:dcdg/dcdg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:MyBank/screens/Help.dart';
import 'package:MyBank/screens/account.dart';
import 'package:MyBank/screens/dashboard.dart';
import 'package:MyBank/screens/history.dart';
import 'package:MyBank/screens/home.dart';
import 'package:MyBank/screens/login.dart';
import 'package:MyBank/screens/profile.dart';
import 'package:MyBank/screens/signup.dart';
import 'package:MyBank/services/PicovoiceSetup.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:MyBank/screens/main_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>PicovoiceSetup(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context)=>MyHomePage(),
          '/account':(context) {
            final User? user = FirebaseAuth.instance.currentUser;
            return Accounts(user: user);
            },
          '/dash':(context) {
            final User? user = FirebaseAuth.instance.currentUser;
            return DashBoard(user: user);
          },
          '/help':(context)=>Help(),
          '/history':(context) {
            final User? user = FirebaseAuth.instance.currentUser;
            return History(user: user);
          },
          '/home':(context) {
            final User? user = FirebaseAuth.instance.currentUser;
            return Home(user: user);
          },
          '/login':(context) => Login(),
          '/mainpage':(context) => MainPage(),
          '/profile':(context) {
            final User? user = FirebaseAuth.instance.currentUser;
            return profilePage(user: user);
          },
          '/signup':(context) => SignUp(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainPage()
            )
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0575A5),
      child: Center(
        child: SizedBox(
          width: 512,
          height: 512,
          child: Image.asset(
            'assets/logo.png', // Specify the file path to the image
            fit: BoxFit.contain,

          ),
        ),
      ),
    );
  }
}
