import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gp_v2/services/PicovoiceSetup.dart';
import 'package:picovoice_flutter/picovoice.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:picovoice_flutter/picovoice_manager.dart';
import 'package:picovoice_flutter/picovoice_error.dart';

class PicovoiceSetup extends ChangeNotifier {

  final String accessKey="Om9v7gw/KIDctuCh7uANFNB3wes0WVWlzRh9r8O7WmGmoVeYpr/Jbw==";
  String _errorMessage="";
  PicovoiceManager? _picovoiceManager;
  Function(RhinoInference)? onCommand; // Callback for custom commands

  PicovoiceSetup(){
    _initPicovoice();
  }

  void _initPicovoice() async {
    String keywordAsset="assets/Hey-Bank_en_android_v3_0_0.ppn";
    String contextAsset="assets/Bank-Commands_en_android_v3_0_0.rhn";

    try {
      _picovoiceManager = await PicovoiceManager.create(
          accessKey,
          keywordAsset,
          _wakeWordCallback,
          contextAsset,
          _inferenceCallback,
          processErrorCallback: _errorCallback);
      enablePico();
    } on PicovoiceActivationException {
      _errorCallback(
          PicovoiceActivationException("AccessKey activation error."));
    } on PicovoiceActivationLimitException {
      _errorCallback(PicovoiceActivationLimitException(
          "AccessKey reached its device limit."));
    } on PicovoiceActivationRefusedException {
      _errorCallback(PicovoiceActivationRefusedException("AccessKey refused."));
    } on PicovoiceActivationThrottledException {
      _errorCallback(PicovoiceActivationThrottledException(
          "AccessKey has been throttled."));
    } on PicovoiceException catch (ex) {
      _errorCallback(ex);
    }

  }

  void _errorCallback(PicovoiceException error) {
    _errorMessage = error.message!;
    print(_errorMessage);
  }

  void _wakeWordCallback() {
    print("wake word detected!");
    Fluttertoast.showToast(
        msg: "I'm Listening...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor:Color.fromRGBO(0, 0, 0, 0.5),
        textColor: Colors.white,
        fontSize: 16.0
    );
    notifyListeners();
  }

  void _inferenceCallback(RhinoInference inference) {

    if (inference.isUnderstood!) {
      Map<String, String> slots = inference.slots!;
      if(onCommand!=null){
        onCommand!(inference);
      }
      // if (inference.intent == 'clock') {
      //   // setState(() {
      //   //   _selectedIndex = 0;
      //   // });
      // } else if (inference.intent! == 'openHome') {
      //   // _performTimerCommand(slots);
      // } else if (inference.intent! == 'openAccount') {
      //   // _setTimer(slots);
      // } else if (inference.intent! == 'openHelp') {
      //   // _performAlarmCommand(slots);
      // } else if (inference.intent! == 'openHistory') {
      //   // _setAlarm(slots);
      // } else if (inference.intent! == 'openLogin') {
      //   // _performStopwatchCommand(slots);
      // } else if (inference.intent! == 'openSignup') {
      //
      // }
    } else {
      print("Cannot recognize Command");
      Fluttertoast.showToast(
          msg: "Didn't Understand Command!\n" +
              "Try Again",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
          textColor: Colors.white,
          fontSize: 16.0);
    }
    notifyListeners();

    //Call custom command handler if set
  }

  @override
  void dispose() async{
    await _picovoiceManager?.stop();
    await _picovoiceManager?.delete();

    super.dispose();
  }

  Future<void> disablePico() async {
    await _picovoiceManager?.stop();

    print("PicoVoice is Disabled");
  }

  Future<void> enablePico() async {
    await _picovoiceManager?.start();
    print("PicoVoice is Enabled");
  }
}
