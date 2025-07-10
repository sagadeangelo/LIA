import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VozProvider with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final List<String> _palabrasClave = ['la toxina', 'toxina'];

  // Callbacks para notificar cuando se detecta una palabra clave
  void Function(String)? onPalabraClaveDetectada;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<void> iniciarEscucha() async {
    bool disponible = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (disponible) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords.toLowerCase();
          _verificarClave();
          notifyListeners();
        },
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        pauseFor: Duration(seconds: 5), // configurable
      );
    }
  }

  void detenerEscucha() {
    _isListening = false;
    _speech.stop();
    notifyListeners();
  }

  void _verificarClave() {
    for (var clave in _palabrasClave) {
      if (_lastWords.contains(clave)) {
        print("🔑 Palabra clave detectada: $clave");
        if (onPalabraClaveDetectada != null) {
          onPalabraClaveDetectada!(clave);
        }
      }
    }
  }
}
