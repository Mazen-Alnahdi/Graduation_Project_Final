import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gp_v2/screens/Help.dart';
import 'package:gp_v2/screens/account.dart';
import 'package:gp_v2/screens/history.dart';
import 'package:gp_v2/screens/home.dart';
import 'package:gp_v2/services/autologout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class DashBoard extends StatefulWidget {
  final User? user;

  const DashBoard({super.key, this.user});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final AutoLogout _autoLogout = AutoLogout();
  int _currentIndex = 0;
  stt.SpeechToText _speech = stt.SpeechToText();

  void _listenForVoiceCommands() async {
    if (await _speech.initialize()) {
      _speech.listen(onResult: (result) {
        _handleVoiceCommand(result.recognizedWords);
      });
    } else {
      print('Failed to initialize speech recognition');
    }
  }

  void _handleVoiceCommand(String command) {
    setState(() {
      if (command.toLowerCase().contains('open home')) {
        _currentIndex = 0;
      } else if (command.toLowerCase().contains('open accounts')) {
        _currentIndex = 1;
      } else if (command.toLowerCase().contains('open history')) {
        _currentIndex = 2;
      } else if (command.toLowerCase().contains('open help')) {
        _currentIndex = 3;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _autoLogout.startTimer();
    _listenForVoiceCommands();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Home(user: widget.user), // Pass user data to Home widget
      Accounts(user: widget.user), // Pass user data to Accounts widget
      History(user: widget.user), // Pass user data to History widget
      const Help()
    ];

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            _autoLogout.resetTimer();
          },
          child: _pages[_currentIndex],
        ),
      ),
      floatingActionButton: Stack(
        children:[
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 -10,
            child: FloatingActionButton(
            onPressed: () {
              _startListening();
            },child: Icon(Icons.mic),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              hoverColor: Colors.grey,

                    ),
          ),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Account',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled),
            label: 'History',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic),
            label: 'Help',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  void _startListening() {
    _speech.listen(onResult: (result) {
      if (result.finalResult) {
        _handleVoiceCommand(result.recognizedWords);
      }
    });
  }
}



