import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceCommandService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Say something...";
  Function(String)? onCommand; // Callback for custom commands

  VoiceCommandService() {
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  String get text => _text;

  void _initSpeech() async {
    bool available = await _speech.initialize(onStatus: _onStatus);
    if (available) {
      _startListening();
    } else {
      _text = "Speech recognition unavailable";
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(minutes: 30),
      pauseFor: Duration(seconds: 30),
      onSoundLevelChange: _onSoundLevelChange,
      localeId: "en_US",
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      ),
    );
    _isListening = true;
  }

  void _onSoundLevelChange(double level) {
    if (!_speech.isListening) {
      _startListening();
    }
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    _text = result.recognizedWords;

    // Only call handleCommand if the result is final
    if (result.finalResult) {
      handleCommand(result.recognizedWords);
    }
  }

  void _onStatus(String status) {
    if (status == 'notListening') {
      // Microphone has stopped listening
      handleCommand("");
      _isListening = false;
    } else if (status == 'listening') {
      _isListening = true;
    }
  }

  void handleCommand(String command) {
    _text = "Current Text: $command";
    print(_text);

    // Call custom command handler if set
    if (onCommand != null) {
      onCommand!(command);
    }
  }
}
