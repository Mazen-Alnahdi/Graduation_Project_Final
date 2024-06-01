






import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:gp_v2/screens/Help.dart';
import 'package:gp_v2/screens/account.dart';
import 'package:gp_v2/screens/dashboard.dart';
import 'package:gp_v2/screens/history.dart';
import 'package:gp_v2/screens/home.dart';
import 'package:gp_v2/screens/login.dart';
import 'package:gp_v2/screens/profile.dart';
import 'package:gp_v2/screens/signup.dart';
import 'package:gp_v2/services/PicovoiceSetup.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:gp_v2/screens/main_page.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 512,
          height: 512,
          child: Image.asset(
            'assets/logo.png', // Specify the file path to the image
            fit: BoxFit.contain, // Adjust the image to contain within the specified size
          ),
        ),
      ),
    );
  }
}
