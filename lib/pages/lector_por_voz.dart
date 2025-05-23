import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lia_lectura_inmersiva/widgets/scene_builder.dart';

class LectorPorVoz extends StatefulWidget {
  const LectorPorVoz({super.key});

  @override
  State<LectorPorVoz> createState() => _LectorPorVozState();
}

class _LectorPorVozState extends State<LectorPorVoz> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String palabraClave = '';
  bool _escuchando = false;

  Future<void> _iniciarEscucha() async {
    bool disponible = await _speech.initialize(
      onStatus: (status) => debugPrint('Status: $status'),
      onError: (error) => debugPrint('Error: $error'),
    );

    if (disponible) {
      setState(() => _escuchando = true);
      _speech.listen(
        onResult: (res) {
          final texto = res.recognizedWords.toLowerCase();
          debugPrint('Palabra detectada: $texto');
          setState(() {
            palabraClave = texto.trim();
          });
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        localeId: 'es_MX', // ajusta según tu región
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escena por Voz')),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Presiona el micrófono y habla una palabra clave'),
              const SizedBox(height: 20),
              IconButton(
                iconSize: 64,
                icon: Icon(_escuchando ? Icons.mic : Icons.mic_none),
                onPressed: _iniciarEscucha,
              ),
              const SizedBox(height: 20),
              Text(
                palabraClave.isEmpty ? '...' : 'Detectado: $palabraClave',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          if (palabraClave.isNotEmpty)
            SceneBuilder(palabraClave: palabraClave),
        ],
      ),
    );
  }
}
