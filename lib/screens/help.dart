import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MyBank/services/PicovoiceSetup.dart';
import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final ScrollController _scrollController=ScrollController();
  late PicovoiceSetup picovoiceSetup;

  @override
  void initState() {
    super.initState();
    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = _handleCustomCommands;
  }

  @override
  void dispose() {
    super.dispose();
    picovoiceSetup.onCommand = null;
    _scrollController.dispose();
  }

  void _handleCustomCommands (RhinoInference inference) async {
    if(inference.intent == "scrollUp"){
      _scrollUp();
    } else if (inference.intent == "scrollDown") {
      _scrollDown();
    }
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF0575A5),
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // IconButton(
                //   icon: Icon(Icons.person),
                //   onPressed: () {},
                //   color: Colors.white,),
                SizedBox(width: MediaQuery.of(context).size.width*.5),
                IconButton(icon: Icon(Icons.notifications),onPressed: () {},color: Colors.white),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Help',
                style: TextStyle(fontSize: 50,color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                HelpBox(
                    headline: "How to open my main page",
                    content: "To open the main page, press the Home Icon at the bottom on the left side."),
                HelpBox(
                    headline: "I want to see my list of credit and debit cards",
                    content: "To display your cards, press the Card icon at the center bottom."),
                HelpBox(
                    headline: "I want to see my list of transactions",
                    content: "To see you list of transactions, press the clock icon at the bottom."),
                HelpBox(
                    headline: "Can i wire money to another account?",
                    content: "The Feature to transfer funds is unavailable right now "
                        "as it will be implemented in the foreseeable future"),
                HelpBox(
                    headline: "I noticed that there is a Scan QR button, can i use it?",
                    content: "The Feaure Scan QR is unavailable right now as it's "
                        "feature will be implmented in the foreseeable future."),
                HelpBox(
                    headline: "There was an Bell Icon at the top right, whats that for?",
                    content: "Its used to display any notifications if anyone "
                        "transferred money to you. This feature is not yet implemented as it"
                        " will be usable in the near future"),
                HelpBox(
                    headline: "What does the buttons that says Physical and Virtual do?",
                    content: "The buttons allows to send a request from the bank to create "
                        "a new physical card as debit or credit or virtual card as "
                        "prepaid cards but this feature is for aesthetic purposes as its not"
                        " part of my scope to implement the actual feature")
              ],
            )
          ),
          ),
          ),
    );
  }
}

class HelpBox extends StatelessWidget {
  final String headline;
  final String content;

  HelpBox({
    super.key,
    required this.headline,
    required this.content,
    });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: Container(
          padding: EdgeInsets.only(top: 10,bottom: 10),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(headline),
              children: <Widget>[
                Container(alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16),
                    child: Text(content)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


