// lib/screens/voz_reactiva_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';

class VozReactivaScreen extends StatefulWidget {
  final String titulo;
  final String contenido;

  const VozReactivaScreen({
    super.key,
    required this.titulo,
    required this.contenido,
  });

  @override
  State<VozReactivaScreen> createState() => _VozReactivaScreenState();
}

class _VozReactivaScreenState extends State<VozReactivaScreen> {
  late stt.SpeechToText _speech;
  late AudioPlayer _audioPlayer;
  final AudioPlayer _paginaPlayer = AudioPlayer();

  bool _listening = false;
  bool _mostroInicio = false;
  String _textoReconocido = '';
  String? _efectoActivado;
  double _opacidadImagen = 0;
  Timer? _reinicioPorInactividad;

  List<String> _paginas = [];
  int _paginaActual = 0;

  final Map<String, DateTime> _tiempoUltimaReproduccion = {};

  final Map<String, String> efectos = {
    'angelo': 'angelo_boutov',
    'abuelo': 'abuelo_abelard',
    'artefacto': 'artefacto',
    'toxina': 'toxina',
    'laboratorio': 'laboratorio',
    'sombra': 'sombra',
    'brazalete': 'brazalete',
    'cristal': 'cristal',
    'daga': 'daga',
    'diario': 'diario',
    'khoorx': 'khoorx',
    'medallon': 'medallon',
    'rayo': 'rayo',
    'reliquia': 'reliquia',
    'darien': 'darien',
    'rachel': 'rachel',
    'akineanos': 'akineanos',
    'jefe': 'jefe_akinae',
    'gadianes': 'gadianes',
    'cielos': 'imagen_misma_de_los_cielos',
    'mascara': 'mascara_antigas',
    'obras': 'obras_de_teatro',
    'reliquias': 'reliquia_familiares',
    'sargento': 'sargento_silvano',
    'doce': 'doce_artefactos',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioPlayer = AudioPlayer();
    _paginas = _dividirEnPaginas(widget.contenido);
    _speech.statusListener = (status) {
      if ((status == 'notListening' || status == 'done') && _listening) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _iniciarEscucha();
        });
      }
    };
  }

  List<String> _dividirEnPaginas(String texto, {int caracteresPorPagina = 800}) {
    texto = texto.replaceAll(RegExp(r'[\n\r]'), ' ').trim();
    final palabras = texto.split(RegExp(r'\s+'));
    List<String> paginas = [];
    String buffer = '';

    for (var palabra in palabras) {
      if ((buffer + palabra).length > caracteresPorPagina) {
        paginas.add(buffer.trim());
        buffer = '';
      }
      buffer += '$palabra ';
    }
    if (buffer.isNotEmpty) paginas.add(buffer.trim());

    return paginas;
  }

  void _iniciarEscucha() async {
    final disponible = await _speech.initialize();
    if (!disponible) return;

    setState(() {
      _listening = true;
      _efectoActivado = null;
      _opacidadImagen = 0;
    });

    _speech.listen(
      onResult: (val) {
        if (val.recognizedWords.trim().isEmpty) return;

        _textoReconocido = val.recognizedWords.toLowerCase();
        for (var palabra in efectos.keys) {
          if (_textoReconocido.contains(palabra)) {
            if (_puedeActivar(palabra)) _activarEfecto(palabra);
          }
        }
        _verificarUltimaPalabra();
        _reiniciarPorInactividad();
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 60),
      cancelOnError: false,
    );

    if (!_mostroInicio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎙️ Micrófono activo – comienza a leer...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _mostroInicio = true;
    }
  }

  void _verificarUltimaPalabra() async {
    final pagina = _paginas[_paginaActual];
    final ultima = pagina.split(RegExp(r'\s+')).last.toLowerCase().replaceAll(RegExp(r'[^\wáéíóúüñ]'), '');

    final palabrasDichas = _textoReconocido
        .split(RegExp(r'\s+'))
        .map((p) => p.toLowerCase().replaceAll(RegExp(r'[^\wáéíóúüñ]'), ''))
        .toList();

    if (palabrasDichas.contains(ultima) && _paginaActual < _paginas.length - 1) {
      await _paginaPlayer.play(AssetSource('sounds/siguiente_pagina.mp3'));
      setState(() => _paginaActual++);
    }
  }

  bool _puedeActivar(String palabra) {
    final ahora = DateTime.now();
    final ultimo = _tiempoUltimaReproduccion[palabra];
    if (ultimo == null || ahora.difference(ultimo) > const Duration(seconds: 3)) {
      _tiempoUltimaReproduccion[palabra] = ahora;
      return true;
    }
    return false;
  }

  void _activarEfecto(String palabra) async {
    if (_efectoActivado != null) return;

    setState(() {
      _efectoActivado = palabra;
      _opacidadImagen = 0;
    });

    final archivo = efectos[palabra] ?? 'placeholder';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.0);
      await _audioPlayer.play(AssetSource('sounds/$archivo.mp3'));

      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        setState(() => _opacidadImagen = i / 10);
        _audioPlayer.setVolume(i / 10);
      }

      await Future.delayed(const Duration(seconds: 3));

      for (int i = 10; i >= 1; i--) {
        await Future.delayed(const Duration(milliseconds: 60));
        if (!mounted) return;
        setState(() => _opacidadImagen = i / 10);
        _audioPlayer.setVolume(i / 10);
      }

      await _audioPlayer.stop();

      if (!mounted) return;
      setState(() {
        _efectoActivado = null;
        _opacidadImagen = 0;
      });
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  void _detenerEscucha() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
    }
  }

  void _reiniciarPorInactividad() {
    _reinicioPorInactividad?.cancel();
    _reinicioPorInactividad = Timer(const Duration(seconds: 3), () {
      if (mounted && _listening) {
        _speech.stop();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _iniciarEscucha();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.cyan[900],
      ),
      body: Stack(
        children: [
          if (_efectoActivado != null)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _opacidadImagen,
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  'assets/animaciones/${efectos[_efectoActivado!] ?? 'placeholder'}.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Column(
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _paginaActual < _paginas.length
                        ? _paginas[_paginaActual]
                        : '🎉 Capítulo terminado.',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _paginaActual > 0
                          ? () => setState(() => _paginaActual--)
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                    ),
                    Text(
                      'Página ${_paginaActual + 1} de ${_paginas.length}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    IconButton(
                      onPressed: _paginaActual < _paginas.length - 1
                          ? () => setState(() => _paginaActual++)
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[850],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Modo clásico'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                    ),
                    ElevatedButton.icon(
                      onPressed: _listening ? _detenerEscucha : _iniciarEscucha,
                      icon: Icon(_listening ? Icons.mic_off : Icons.mic),
                      label: Text(_listening ? 'Detener voz' : 'Activar voz'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
