import 'package:MyBank/services/VoiceCommandService.dart';
import 'package:flutter/material.dart';
import 'package:MyBank/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MyBank/services/PicovoiceSetup.dart';
import 'package:MyBank/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';

class profilePage extends StatefulWidget {
  final User? user;
  const profilePage({super.key, this.user});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  final ScrollController _scrollController=ScrollController();
  late PicovoiceSetup picovoiceSetup;
  late VoiceCommandService _voiceCommandService;
  int position=0;

  final _oldPasswordController=TextEditingController();
  final _newPasswordController=TextEditingController();
  final _confPasswordController=TextEditingController();

  final _phraseold1Controller=TextEditingController();
  final _phraseold2Controller=TextEditingController();
  final _phrasehint1Controller=TextEditingController();
  final _phrasehint2Controller=TextEditingController();
  final _phrasetext1Controller=TextEditingController();
  final _phrasetext2Controller=TextEditingController();

  bool _validateOldPass=false;
  bool _validateNewPass=false;
  bool _validateConfPass=false;

  bool _validatephraseold1=false;
  bool _validatephraseold2=false;
  bool _validatephrasehint1=false;
  bool _validatephrasehint2=false;
  bool _validatephrasetext1=false;
  bool _validatephrasetext2=false;

  String _message="";
  String word="";

  Future<String> changePassword(String email,String oldPass, String newPass, String confPass) async {
    _message= await fireStoreService.changePassword(
        email: email,
        currentPassword: oldPass,
        newPassword: newPass);

    return _message;
  }


  List<Map<String,dynamic>> _UserData=[];
  final FireStoreService fireStoreService = FireStoreService();
  bool _isVisiblePass=true;
  bool _isVisibleInfo=true;

  Future<void> _fetchUserData(String email) async {
    List<Map<String,dynamic>> document=await fireStoreService.getUserData(email);
    setState(() {
      _UserData=document;
    });
  }

  @override
  void initState() {
    super.initState();
    if(widget.user != null) {
      String? userEmail = widget.user!.email;
      if(userEmail != null) {
        _fetchUserData(userEmail);
      }
    }
    picovoiceSetup = Provider.of<PicovoiceSetup>(context, listen: false);
    picovoiceSetup.onCommand = _handleCustomCommands;
  }

  @override
  void dispose(){
    picovoiceSetup.onCommand = null;
    _scrollController.dispose();
     _oldPasswordController.dispose();
     _newPasswordController.dispose();
     _confPasswordController.dispose();
     _phrasehint1Controller.dispose();
     _phrasehint2Controller.dispose();
     _phrasetext1Controller.dispose();
     _phrasetext2Controller.dispose();
     super.dispose();
  }

  void _enterText(String text) async {
    switch(position){
      case 0:{
        _phraseold1Controller.text=_phraseold1Controller.text+text;
        await picovoiceSetup.enablePico();
        word = _phraseold1Controller.text.replaceAll(" ", "");
        _phraseold1Controller.text=word;
        break;
      }
      case 1: {
        _phrasetext2Controller.text=_phrasetext2Controller.text+text;
        await picovoiceSetup.enablePico();
        word = _phrasetext2Controller.text.replaceAll(" ", "");
        _phrasetext2Controller.text=word;
        break;
      }
      case 2: {
        _phrasetext2Controller.text=_phrasetext2Controller.text+text;
        await picovoiceSetup.enablePico();
        word = _phrasetext2Controller.text.replaceAll(" ", "");
        _phrasetext2Controller.text=word;
        break;
      }
      case 3: {
        _phraseold1Controller.text=_phraseold1Controller.text+text;
        await picovoiceSetup.enablePico();
        word = _phraseold1Controller.text.replaceAll(" ", "");
        _phraseold1Controller.text=word;
        break;
      }
    }
  }

  void _handleCustomCommands (RhinoInference inference) async {
    if(inference.intent == "scrollUp"){
      _scrollUp();
    } else if (inference.intent == "scrollDown") {
      _scrollDown();
    } else if (inference.intent == "enterPhrase1"){
      position=2;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent == "enterPhrase2"){
      position=3;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if (inference.intent == "enterOldPhrase1"){
      position=0;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if(inference.intent == "enterOldPhrase2"){
      position=1;
      await picovoiceSetup.disablePico();
      _voiceCommandService = VoiceCommandService();
      _voiceCommandService.onCommand = _enterText;
    } else if(inference.intent == "clearPhrase1"){
      _phrasetext1Controller.text="";
    } else if(inference.intent == "clearPhrase2") {
      _phrasetext2Controller.text="";
    } else if (inference.intent == "clearOldPhrase1"){
      _phraseold1Controller.text="";
    } else if(inference.intent == "clearOldPhrase2"){
      _phraseold2Controller.text="";
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
    final FireStoreService fireStoreService = FireStoreService();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Color(0xFF0575A5),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: () {
                      Navigator.pop(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashBoard(user: widget.user,))
                      );
                    }, color: Colors.white,),
                    SizedBox(width: MediaQuery
                        .of(context)
                        .size
                        .width * .5),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            shrinkWrap: false,
            children: [

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Reset Password",
                  style: TextStyle(
                    fontSize: 25
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Create your new Password so you can login into your account",
                  style: TextStyle(
                      fontSize: 15
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isVisiblePass=!_isVisiblePass;
                      });
                    },child: const Text("Expand to Update"),),
              ),

              if (_isVisiblePass)
                Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(10),
                      child:  TextField(
                        controller: _oldPasswordController,
                        decoration: InputDecoration(
                          label: Text("Current Password: "),
                            hintText: "Enter your Old Password: ",
                            border: InputBorder.none,
                            errorText: _validateOldPass? 'This Field cannot be empty' : null,
                            ),
                        scrollPadding: EdgeInsets.all(10.0),
                        obscureText: true,
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller:  _newPasswordController,
                        decoration: InputDecoration(
                            label: Text("New Password: "),
                            errorText: _validateNewPass? 'This Field cannot be empty' : null,
                            hintText: "Enter your New Password: ",
                            border: InputBorder.none),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller:  _confPasswordController,
                        decoration: InputDecoration(
                            label: Text("Confirm Password: "),
                            errorText: _validateConfPass? 'This Field cannot be empty' : null,
                            hintText: "Enter your New Password: ",
                            border: InputBorder.none),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("If you have used phrases as a password, leave the previous fields as blanks and enter your old and new phrases below",
                        style: TextStyle(
                            fontSize: 15
                        ),),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      child:  TextField(
                        controller: _phraseold1Controller,
                        decoration: InputDecoration(
                          label: Text("Current Phrase 1: "),
                          hintText: "Enter your Old First Phrase: ",
                          border: InputBorder.none,
                          errorText: _validatephraseold1? 'This Field cannot be empty' : null,
                        ),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child:  TextField(
                        controller: _phraseold2Controller,
                        decoration: InputDecoration(
                          label: Text("Current Phrase 2: "),
                          hintText: "Enter your Old Second Phrase: ",
                          border: InputBorder.none,
                          errorText: _validatephraseold2? 'This Field cannot be empty' : null,
                        ),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      child:  TextField(
                        controller: _phrasetext1Controller,
                        decoration: InputDecoration(
                          label: Text("New Phrase 1: "),
                          hintText: "Enter your New First Phrase: ",
                          border: InputBorder.none,
                          errorText: _validatephrasetext1? 'This Field cannot be empty' : null,
                        ),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child:  TextField(
                        controller: _phrasetext2Controller,
                        decoration: InputDecoration(
                          label: Text("New Phrase 2: "),
                          hintText: "Enter your New Second Phrase: ",
                          border: InputBorder.none,
                          errorText: _validatephrasetext2? 'This Field cannot be empty' : null,
                        ),
                        scrollPadding: EdgeInsets.all(10.0),
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    Row(
                      children: [
                        ElevatedButton(
                            child: Text("Reset Password"),
                            onPressed: () async {

                              setState(() {

                                if (_oldPasswordController.text.isEmpty &&_newPasswordController.text.isEmpty &&_confPasswordController.text.isEmpty) {
                                  _phraseold1Controller.text.isEmpty? _validatephraseold1=true :_validatephraseold1=false;
                                  _phraseold2Controller.text.isEmpty? _validatephraseold2=true:_validatephraseold2=false;
                                  _phrasetext1Controller.text.isEmpty? _validatephrasetext1=true:_validatephrasetext1=false;
                                  _phrasetext2Controller.text.isEmpty? _validatephrasetext2=true: _validatephrasetext2=false;
                                } else {
                                  _oldPasswordController.text.isEmpty ? _validateOldPass = true: _validateOldPass=false;
                                  _newPasswordController.text.isEmpty ? _validateNewPass = true: _validateNewPass=false;
                                  _confPasswordController.text.isEmpty ? _validateConfPass=true: _validateOldPass= false;
                                }


                              });
                              if ((_validateNewPass==false && _validateNewPass==false && _validateConfPass==false)||
                                  _validatephraseold1==false&& _validatephraseold2==false && _validatephrasetext1==false && _validatephrasetext2==false){

                                if(_newPasswordController.text==_confPasswordController.text){
                                  _message = await fireStoreService.changePassword(
                                      email: widget.user!.email,
                                      currentPassword: _oldPasswordController.text,
                                      newPassword: _newPasswordController.text);
                                } else {
                                  _newPasswordController.text=_phraseold1Controller.text+_phraseold2Controller.text;
                                  _confPasswordController.text=_phrasetext1Controller.text+_phrasetext2Controller.text;

                                  _message = await fireStoreService.changePassword(
                                      email: widget.user!.email,
                                      currentPassword: _oldPasswordController.text,
                                      newPassword: _newPasswordController.text);
                                }
                              }
                            },
                        )],),
                    Text(_message,style: TextStyle(color: Colors.red),),

                  ],
                ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0,bottom: 8,left: 8),
                child: Text("Account Info",
                  style: TextStyle(
                      fontSize: 25
                  ),),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("You can view your account information",
                  style: TextStyle(
                      fontSize: 15
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isVisibleInfo=!_isVisibleInfo;
                    });
                  },child: const Text("Open Account"),),
              ),
              _isVisibleInfo
                  ? Column(
                children: _UserData.map((user) {
                  return Column(
                    children: [
                      ContentWidget(
                        title: "Name",
                        content: user['Name'].toString(),
                      ),
                      ContentWidget(
                          title: "Email",
                          content: user['email'].toString()),
                      ContentWidget(
                          title: "Date of Birth",
                          content: user['DOB'].toString()),
                    ],
                  );
                }).toList(),
              )
                  : Container(), // or any other widget as a fallback
                ],
          ),
        )
    );
  }
}


class ContentWidget extends StatelessWidget {
  final String title;
  final String content;

  const ContentWidget({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 7.5), // Adjust padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 7.5),
            child: Text(
              "$title: ",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)), // Only bottom border
            ),
            child: SizedBox(
              height: 35, // Adjust height as needed
              child: TextFormField(
                initialValue: content,
                readOnly: true,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  border: InputBorder.none, // Hide the default border
                  contentPadding: EdgeInsets.symmetric(horizontal: 7), // Adjust content padding if needed
                ),
              ),
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
