import 'dart:io';


import 'package:flutter/material.dart';
import 'package:MyBank/services/PicovoiceSetup.dart';
import 'package:MyBank/services/VoiceCommandService.dart';
import 'package:MyBank/services/firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';



class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<StatefulWidget> createState() {
    return SignupState();
  }
}

class SignupState extends State<SignUp> {


  final _accNumtext = TextEditingController();
  final _emailtext = TextEditingController();
  final _passwordtext = TextEditingController();
  final _confpasswordtext = TextEditingController();
  final _phrase1text = TextEditingController();
  final _phrase2text = TextEditingController();
  final _phrase1hint = TextEditingController();
  final _phrase2hint = TextEditingController();
  bool _validateacc = false;
  bool _validatename = false;
  bool _validatuser = false;
  bool _validatpass = false;
  bool _validatconfpass = false;
  bool _validatephrase1 = false;
  bool _validatephrase2 = false;
  String errorMessage = "";
  int position = 0;
  String word = "";

  late PicovoiceSetup picovoiceSetup;
  late VoiceCommandService _voiceCommandService;

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/credentials.txt';
  }

  Future<void> _saveCredentials(String Phrase1, String Phrase2) async {
    final file = File(await _getFilePath());
    await file.writeAsString('$Phrase1\n$Phrase2');
  }

  void _enterText(String text) async {
    switch (position) {
      case 0:
        {
          _accNumtext.text = _accNumtext.text + text;
          await picovoiceSetup.enablePico();
          word = _accNumtext.text.replaceAll(" ", "");
          _accNumtext.text = word;
          break;
        }
      case 1:
        {
          _emailtext.text = _emailtext.text + text;
          await picovoiceSetup.enablePico();
          word = _emailtext.text.replaceAll(" ", "");
          _emailtext.text = word;
          break;
        }
      case 4:
        {
          _phrase1hint.text = _phrase1hint.text + text;
          await picovoiceSetup.enablePico();
          word = _phrase1hint.text.replaceAll(" ", "");
          _phrase1hint.text = word;
          break;
        }
      case 5:
        {
          _phrase1text.text = _phrase1text.text + text;
          await picovoiceSetup.enablePico();
          word = _phrase1text.text.replaceAll(" ", "");
          _phrase1text.text = word;
          break;
        }
      case 6:
        {
          _phrase2hint.text = _phrase2hint.text + text;
          await picovoiceSetup.enablePico();
          word = _phrase2hint.text.replaceAll(" ", "");
          _phrase2hint.text = word;
          break;
        }
      case 7:
        {
          _phrase2text.text = _phrase2text.text + text;
          await picovoiceSetup.enablePico();
          word = _phrase2text.text.replaceAll(" ", "");
          _phrase2text.text = word;
          break;
        }
    }
  }

  void _handleCustomCommands(RhinoInference inference) async {
    if (inference.intent! == 'enterAcc') {
      position = 0;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == 'enterEmail') {
      print(inference.intent);
      position = 1;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == "enterHint1") {
      position = 4;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == 'EnterPhrase1') {
      position = 5;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == "enterHint2") {
      position = 6;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == "EnterPhrase2") {
      position = 7;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent! == "clearPhrase1") {
      _phrase1text.text="";
    } else if (inference.intent! == "clearHint1") {
      _phrase1hint.text="";
    } else if (inference.intent! == "clearPhrase2") {
      _phrase2text.text="";
    } else if (inference.intent! == "cearHint2") {
      _phrase2hint.text="";
    } else if(inference.intent! == "clearAcc"){
      _accNumtext.text="";
    } else if(inference.intent! == "clearEmail") {
      _emailtext.text="";
    }
  }

  void signup() async {
    final FireStoreService fireStoreService = FireStoreService();
    setState(() {
      _accNumtext.text.isEmpty ? _validateacc = true : _validateacc = false;
      _emailtext.text.isEmpty ? _validatuser = true : _validatuser = false;
      if (_passwordtext.text.isEmpty && _confpasswordtext.text.isEmpty) {
        _phrase1text.text.isEmpty ? _validatephrase1 = true : _validatephrase1 = false;
        _phrase2text.text.isEmpty ? _validatephrase2 = true : _validatephrase2 = false;
      } else {
        _passwordtext.text.isEmpty ? _validatpass = true : _validatpass = false;
        _confpasswordtext.text.isEmpty ? _validatconfpass = true : _validatconfpass = false;
      }
    });
    if (
    _validateacc == false || _validatename == false || _validatuser == false
        || _validatpass == false || _validatconfpass == false)
    {
      if ((_passwordtext.text == _confpasswordtext.text) ||
          (_phrase1text.text.isNotEmpty && _phrase2text.text.isNotEmpty))
      {
        if (_passwordtext.text == "")
        {
          _passwordtext.text = _phrase1text.text.trim() + _phrase2text.text.trim();
        }

        final register =
        await fireStoreService.registerAndAddToFirestore(
            email: _emailtext.text,
            password: _passwordtext.text,
            accNum: _accNumtext.text);

        // fireStoreService.addUser(_accNumtext.text,_emailtext.text, _passwordtext.text);
        if (register == "Successfully Created") {
          _saveCredentials(
              _phrase1hint.text.trim(),
              _phrase2hint.text.trim());
          Navigator.pop(
              context,
              MaterialPageRoute(
                  builder: (context) => SignUp()));
        } else {
          setState(() {
            errorMessage = register!;
          });
        }
      } else {
        errorMessage = "The password doesn't match";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = _handleCustomCommands;
  }

  @override
  void dispose() {
    _accNumtext.dispose();
    _emailtext.dispose();
    _passwordtext.dispose();
    _confpasswordtext.dispose();
    _phrase1hint.dispose();
    _phrase1text.dispose();
    _phrase2hint.dispose();
    _phrase2text.dispose();

    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _accNumtext,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Account Number',
                    hintText: "Enter your Existing Account Number",
                    errorText:
                        _validateacc ? 'Account Number cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailtext,
                  decoration: InputDecoration(
                    labelText: 'Create Email',
                    hintText: "Enter your New Email",
                    errorText: _validatuser ? 'Email cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),

              // SizedBox(height: 100),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordtext,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    hintText: "Enter your New Password",
                    errorText: _validatpass ? 'Username cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _confpasswordtext,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: "Confirm your New Password",
                    errorText:
                        _validatconfpass ? 'Username cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _phrase1hint,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'First Hint',
                    hintText: "Say your First Hint",
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  readOnly: true,
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _phrase1text,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'First Phrase',
                    hintText: "Say your First Phrase",
                    errorText:
                        _validatephrase1 ? 'Username cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  readOnly: true,
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _phrase2hint,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Second Hint',
                    hintText: "Say your Second Hint",
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  readOnly: true,
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _phrase2text,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Second Phrase',
                    hintText: "Say your Second Phrase",
                    errorText:
                        _validatephrase2 ? 'Phrase cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  readOnly: true,
                ),
              ),

              SizedBox(height: 80),
              Text(errorMessage),
              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    child: Text("Signup"),
                    onPressed: signup,
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
