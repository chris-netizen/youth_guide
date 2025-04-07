import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, paused, stopped }

class TtsProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  List<String> _texts = [];
  int _currentIndex = 0;
  TtsState _state = TtsState.stopped;

  TtsState get state => _state;

  TtsProvider() {
    _flutterTts.setCompletionHandler(() {
      _state = TtsState.stopped;
      notifyListeners();
      _speakNext();
    });
  }

  void setTexts(List<String> texts) {
    _texts = texts;
    _currentIndex = 0;
  }

  Future<void> start() async {
    if (_texts.isEmpty) return;

    _currentIndex = 0;
    _state = TtsState.playing;
    notifyListeners();

    await _speakNext();
  }

  Future<void> _speakNext() async {
    if (_currentIndex < _texts.length) {
      _state = TtsState.playing;
      notifyListeners();

      await _flutterTts.speak(_texts[_currentIndex]);
      _currentIndex++;
    } else {
      _state = TtsState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    _flutterTts.pause();
    _state = TtsState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentIndex < _texts.length) {
      _state = TtsState.playing;
      notifyListeners();

      await _flutterTts.speak(_texts[_currentIndex]);
      _currentIndex++;
    } else {
      _state = TtsState.stopped;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _state = TtsState.stopped;
    _currentIndex = 0;
    notifyListeners();
  }
}
