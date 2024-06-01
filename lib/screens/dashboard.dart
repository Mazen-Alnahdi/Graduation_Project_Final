import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp_v2/screens/Help.dart';
import 'package:gp_v2/screens/account.dart';
import 'package:gp_v2/screens/history.dart';
import 'package:gp_v2/screens/home.dart';
import 'package:gp_v2/services/PicovoiceSetup.dart';
import 'package:gp_v2/services/VoiceCommandService.dart';
import 'package:gp_v2/services/autologout.dart';
import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';


class DashBoard extends StatefulWidget {
  final User? user;

  const DashBoard({Key? key, this.user}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late PicovoiceSetup picovoiceSetup;
  final AutoLogout _autoLogout = AutoLogout();
  int _currentIndex = 0;



  @override
  void initState() {
    super.initState();
    _autoLogout.startTimer();
    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = _handleCustomCommands;
  }

  @override
  void dispose() {
    picovoiceSetup.onCommand = null;
    super.dispose();
  }

  void _handleCustomCommands(RhinoInference inference) async {
    setState(() {
      if(inference.intent! == "openHome"){
        _currentIndex=0;
      } else if (inference.intent! == "openAccount"){
        _currentIndex=1;
      } else if (inference.intent! == "openHistory"){
        _currentIndex=2;
      } else if (inference.intent! == "openHelp"){
        _currentIndex=3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final voiceCommandService = Provider.of<VoiceCommandService>(context);

    final List<Widget> _pages = [
      Home(user: widget.user),
      Accounts(user: widget.user),
      History(user: widget.user),
      const Help(),
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



  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
