import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gp_v2/screens/signup.dart';
import 'package:gp_v2/services/PicovoiceSetup.dart';

import 'package:gp_v2/services/VoiceCommandService.dart';

//file management
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phrase1Controller = TextEditingController();
  final _phrase2Controller = TextEditingController();

  // stt.SpeechToText _speech = stt.SpeechToText();
  late PicovoiceSetup picovoiceSetup;
  late VoiceCommandService _voiceCommandService;

  String phrasehint1="";
  String phrasehint2="";

  @override
  void initState() {
    super.initState();
    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = _handleCustomCommands;
    _loadCredentials();
    //final voiceCommandService = Provider.of<VoiceCommandService>(context, listen: false);
  }

  @override
  void dispose() {
    // final voiceCommandService = Provider.of<VoiceCommandService>(context, listen: false);
    // voiceCommandService.onCommand = null; // Clean up callback
    picovoiceSetup.onCommand = null;

    _emailController.dispose();
    _passwordController.dispose();
    _phrase1Controller.dispose();
    _phrase2Controller.dispose();
    super.dispose();
  }


  void _enterEmail(String text) async {
    print(text);
    _emailController.text = _emailController.text + text;
    await picovoiceSetup.enablePico();
    String word = _emailController.text.replaceAll(" ", "");
    _emailController.text = word;
  }

  void _enterPhrase1(String text) async {
    print(text);
    _phrase1Controller.text = _phrase1Controller.text + text;
    await picovoiceSetup.enablePico();
    String word = _phrase1Controller.text.replaceAll(" ", "");
    _phrase1Controller.text = word;
  }

  void _enterPhrase2(String text) async {
    print(text);
    _phrase2Controller.text = _phrase2Controller.text + text;
    await picovoiceSetup.enablePico();
    String word = _phrase2Controller.text.replaceAll(" ", "");
    _phrase2Controller.text = word;
  }

  void _handleCustomCommands(RhinoInference inference) async {
    if (inference.intent! == 'enterEmail') {
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterEmail;

      // await picovoiceSetup.enablePico();
    } else if (inference.intent! == 'clearEmail') {
      _emailController.text = "";

    } else if (inference.intent! == 'EnterPhrase1') {


      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterPhrase1;
    } else if (inference.intent! == 'EnterPhrase2') {


      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterPhrase2;
    } else if (inference.intent! == 'login') {

      if (_phrase1Controller.text.isNotEmpty&&_phrase2Controller.text.isNotEmpty){
      _passwordController.text = _phrase1Controller.text.trim() + _phrase2Controller.text.trim();
      }
      signIn();
    } else if (inference.intent! == 'endApp') {
      print(inference.intent);
    } else if (inference.intent! == 'openSignUp') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUp()));
    } else if (inference.intent == 'clearPhrase1') {
      _phrase1Controller.text="";
    } else if(inference.intent == "clearPhrase2") {
      _phrase2Controller.text="";
    }
  }

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/credentials.txt';
  }


  Future<void> _loadCredentials() async {
    try {
      final file = File(await _getFilePath());
      if (await file.exists()) {
        final contents = await file.readAsString();
        final lines = contents.split('\n');
        if (lines.length == 2) {
          setState(() {
            phrasehint1 = lines[0];
            phrasehint2 = lines[1];
          });
        }
      }
    } catch (e) {
      print("Error in Reading Credentials $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final voiceCommandService = Provider.of<VoiceCommandService>(context);
    final picovoicesetup = Provider.of<PicovoiceSetup>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0575A5),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              // Email textfield
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.white),

                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                // password textfield
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                // Phrase 1 textfield
                child: TextField(
                  controller: _phrase1Controller,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Hint for Phrase 1: $phrasehint1',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                // password textfield
                child: TextField(
                  controller: _phrase2Controller,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Hint for Phrase 2: $phrasehint2',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    child: Text("Login"),
                    onPressed: () async {
                      signIn();
                    },
                  ),
                  ElevatedButton(
                    child: Text("Signup"),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
