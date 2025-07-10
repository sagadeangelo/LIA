// ✅ voz_reactiva_screen.dart completo y limpio

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_similarity/string_similarity.dart';
import '../providers/progreso_provider.dart';

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
  bool _listening = false;
  bool _mostroInicio = false;
  String _textoReconocido = '';
  double _opacidadImagen = 0;
  Timer? _reinicioPorInactividad;
  Timer? _timerOcultarEscena;
  final Map<String, DateTime> _tiempoUltimaReproduccion = {};
  List<String> _paginas = [];
  int _paginaActual = 0;
  String? libroId;
  int? capituloIndex;
  String? _escenaActiva;
  List<Map<String, dynamic>> _elementosEscena = [];
  Map<String, dynamic> _escenas = {};

  static const Duration _delayEntreActivaciones = Duration(seconds: 4);
  final List<String> _efectosActivos = [];

  final Map<String, String> efectos = {
    'angelo': 'angelo_boutov',
    'abuelo': 'abuelo_abelard',
    'abelard': 'abuelo_abelard',
    'akinae': 'jefe_akinae',
    'auto': 'auto_convertible',
    'convertible': 'auto_convertible',
    'el_resguardo': 'el_resguardo',
    'reliquias': 'reliquias_familiares',
    'artefacto': 'artefacto',
    'toxina': 'toxina',
    'laboratorio': 'laboratorio',
    'sombra': 'sombra',
    'brazalete': 'brazalete',
    'cristal': 'cristal',
    'daga': 'daga',
    'diario': 'diario',
    'khoorx': 'khoorx',
    'khimm': 'khimm',
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
    'sargento': 'sargento_silvano',
    'doce': 'doce_artefactos',
    'gibran': 'gibran',
    'lindsay': 'lindsay',
    'anastasia': 'anastasia',
    'augusto': 'augusto'
  };

  final Map<String, List<String>> aliasNombres = {
  'abuelo': ['abuelo', 'abuelito', 'el abuelo', 'abelar'],
  'akineanos': ['akineanos', 'akinianos', 'akinenos', 'aquineanos'],
  'anastasia': ['anastasia', 'anastacia', 'anastasya', 'anastasha', 'anastazya', 'mamá', 'mama', 'madre'],
  'angelo': ['angelo', 'ángelo', 'anghelo', 'angel', 'angello'],
  'artefacto': ['artefacto', 'artefakto', 'artefato', 'artefacto mágico'],
  'artefactos': ['artefactos', 'los artefactos', 'doce objetos', 'reliquias', 'esferas mágicas'],
  'augusto': ['augusto', 'agusto', 'augus', 'mi papá', 'papá', 'papa', 'padre', 'el viejo'],
  'auto': ['auto', 'carro', 'convertible', 'coche', 'vehículo', 'auto rojo'],
  'brazalete': ['brazalete', 'brasalete', 'bracelete', 'pulsera', 'brasaleta', 'reloj mágico', 'brasalete mágico'],
  'cristal': ['cristal', 'cristales', 'cristal azul', 'piedra azul', 'gema', 'cristal brillante', 'cristao', 'cristian', 'criztal', 'criztal azul', 'criztal brillante'],
  'daga': ['daga', 'espada corta', 'cuchillo', 'puñal', 'daca', 'daqa', 'dara', 'espada chica', 'cuchillo ceremonial', 'arma sagrada'],
  'darien': ['darien', 'darién', 'darian', 'daryen', 'daryan'],
  'diario': ['diario', 'libro', 'bitácora', 'cuaderno', 'agenda'],
  'doce': ['doce', 'los doce', 'doce objetos', 'docena', 'dose', 'dozze', 'los objetos'],
  'el_resguardo': ['el resguardo', 'resguardo', 'el escondite', 'refugio'],
  'gadianes': ['gadianes', 'guardianes', 'gallianes', 'gadienes'],
  'gibran': ['gibrán', 'gibran', 'jibran', 'yibrán', 'mi hermano', 'hermano'],
  'imagen_misma_de_los_cielos': ['imagen de los cielos', 'los cielos', 'cielo', 'paisaje', 'atardecer', 'puesta de sol'],
  'jefe_akinae': ['jefe akinae', 'jefe', 'akinae', 'líder', 'jefe del clan', 'el anciano', 'el sabio'],
  'khoorx': ['khoorx', 'corox', 'jorox', 'jorux', 'khorux', 'curux', 'corks', 'corux', 'corx', 'el oscuro', 'criatura oscura'],
  'khimm': ['khimm', 'quim', 'kim', 'khim', 'guerrero', 'caballero', 'guerrero con casco', 'el caballero', 'khin', 'kilm'],
  'laboratorio': ['laboratorio', 'laboratorio secreto', 'experimento', 'tubo', 'ciencia'],
  'lindsay': ['lindsay', 'lindsey', 'linsay', 'linsey', 'hermana', 'mi hermana'],
  'mascara': ['máscara', 'mascara antigas', 'antigás', 'máscara de gas', 'máscara roja'],
  'medallon': ['medallón', 'medallon', 'medayon', 'medajon', 'medalla'],
  'obras_de_teatro': ['obras de teatro', 'teatro', 'máscaras', 'actores', 'drama', 'actor', 'máscaras del teatro'],
  'rachel': ['rachel', 'raquel', 'rashal', 'reichel', 'rashiel'],
  'rayo': ['rayo', 'relámpago', 'trueno', 'descarga', 'rallo', 'rayito', 'electricidad'],
  'reliquia': ['reliquia', 'reliquias', 'reliquias familiares', 'reliquia mágica', 'reliquias antiguas', 'objeto antiguo', 'artefacto antiguo', 'objeto mágico'],
  'sargento': ['sargento', 'silvano', 'el sargento', 'oficial', 'militar'],
  'sombra': ['sombra', 'silueta', 'fantasma', 'criatura', 'figura oscura'],
  'toxina': ['toxina', 'veneno', 'frasco', 'poción', 'líquido morado'],
};


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _paginas = _dividirEnPaginas(widget.contenido);
    Future.microtask(() async {
      _cargarArgumentos();
      await _cargarEscenas();
      _iniciarEscucha();
    });
  }

  void _iniciarEscucha() async {
    final disponible = await _speech.initialize(
      onError: (val) => print('Error: $val'),
    );
    if (!disponible) return;

    setState(() => _listening = true);

    _speech.listen(
      onResult: (val) {
        if (val.recognizedWords.trim().isEmpty) return;
        _procesarReconocimiento(val.recognizedWords.toLowerCase());
        _reiniciarPorInactividad();
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 60),
    );
  }

  void _toggleEscucha() {
    _listening ? _speech.stop() : _iniciarEscucha();
    setState(() => _listening = !_listening);
  }

  void _reiniciarPorInactividad() {
    _reinicioPorInactividad?.cancel();
    _reinicioPorInactividad = Timer(const Duration(seconds: 4), () {
      if (mounted && _listening) {
        _speech.stop();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _iniciarEscucha();
        });
      }
    });
  }

  void _cargarArgumentos() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    libroId = args?['libroId'];
    capituloIndex = args?['capituloIndex'];
  }

  Future<void> _cargarEscenas() async {
    final texto = await rootBundle.loadString('lib/data/escenas.json');
    final json = jsonDecode(texto);
    setState(() => _escenas = Map<String, dynamic>.from(json));
  }

  List<String> _dividirEnPaginas(String texto) {
    final palabras = texto.split(RegExp(r'\s+'));
    const palabrasPorPagina = 300;
    final paginas = <String>[];
    for (int i = 0; i < palabras.length; i += palabrasPorPagina) {
      final pagina = palabras.skip(i).take(palabrasPorPagina).join(' ');
      paginas.add(pagina.trim());
    }
    return paginas;
  }

  bool coincide(String texto, String clave, List<String>? alias) {
    if (texto.contains(clave)) return true;
    if (alias != null && alias.any((a) => texto.contains(a))) return true;
    for (final palabra in texto.split(' ')) {
      if (palabra.similarityTo(clave) > 0.75) return true;
      if (alias != null && alias.any((a) => palabra.similarityTo(a) > 0.75)) return true;
    }
    return false;
  }

  bool _puedeActivar(String palabra) {
    final ahora = DateTime.now();
    final ultimo = _tiempoUltimaReproduccion[palabra];
    if (ultimo == null || ahora.difference(ultimo) > _delayEntreActivaciones) {
      _tiempoUltimaReproduccion[palabra] = ahora;
      return true;
    }
    return false;
  }

  void _procesarReconocimiento(String texto) {
    setState(() {
      _textoReconocido = texto;
      final clavesOrdenadas = efectos.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
      final detectadas = <String>{};

      for (final palabra in clavesOrdenadas) {
        final alias = aliasNombres[palabra];
        if (coincide(texto, palabra, alias) && !detectadas.contains(palabra) && _puedeActivar(palabra)) {
          detectadas.add(palabra);
          _activarEfecto(palabra);
          _activarEscenaDesdeJson(palabra);
        }
      }

      _escenas.forEach((clave, escena) {
        if (detectadas.contains(clave)) return;
        final palabrasClave = List<String>.from(escena['palabras_clave'] ?? []);
        for (final frase in palabrasClave) {
          if (texto.contains(frase.toLowerCase()) && _puedeActivar(clave)) {
            _activarEscenaDesdeJson(clave);
            break;
          }
        }
      });
    });
  }

  void _activarEfecto(String palabra) async {
    final archivo = efectos[palabra];
    if (archivo == null) return;

    final player = AudioPlayer();
    _efectosActivos.add(archivo);
    setState(() => _opacidadImagen = 1);

    try {
      await player.setSource(AssetSource('sounds/$archivo.mp3'));
      await player.resume();
    } catch (e) {
      print('Error al reproducir $archivo: $e');
    }

    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      await player.stop();
      setState(() {
        _efectosActivos.remove(archivo);
        if (_efectosActivos.isEmpty) _opacidadImagen = 0;
      });
    });
  }

  void _activarEscenaDesdeJson(String clave) {
    final escena = _escenas[clave];
    if (escena == null) return;

    setState(() {
      _escenaActiva = clave;
      _elementosEscena = List<Map<String, dynamic>>.from(escena['elementos'] ?? []);
    });

    final sonido = escena['sonido_ambiente'];
    if (sonido != null) {
      final player = AudioPlayer();
      player.setSource(AssetSource(sonido)).then((_) => player.resume());
      Future.delayed(const Duration(seconds: 7), () => player.stop());
    }

    _timerOcultarEscena?.cancel();
    _timerOcultarEscena = Timer(const Duration(seconds: 7), () {
      setState(() {
        _escenaActiva = null;
        _elementosEscena.clear();
      });
    });
  }

  void _mostrarDialogoPruebaTexto() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Prueba sin voz'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Ingresa texto'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Activar'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _procesarReconocimiento(controller.text.toLowerCase());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.cyan[900],
      ),
      body: Stack(
        children: [
          if (_elementosEscena.isNotEmpty)
            Positioned.fill(
              child: Stack(
                children: _elementosEscena.map((elemento) {
                  final src = elemento['src'];
                  return AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 500),
                    child: src.toString().endsWith('.json')
                        ? Lottie.network(src, fit: BoxFit.cover)
                        : Image.asset(src, fit: BoxFit.cover),
                  );
                }).toList(),
              ),
            ),
          if (_efectosActivos.isNotEmpty)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _opacidadImagen,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: _efectosActivos.map((archivo) {
                    return Positioned.fill(
                      child: Image.asset(
                        'assets/animaciones/$archivo.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _paginas[_paginaActual],
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: _paginaActual > 0 ? () => setState(() => _paginaActual--) : null,
                    color: Colors.white,
                  ),
                  Text(
                    'Página ${_paginaActual + 1}/${_paginas.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: _paginaActual < _paginas.length - 1 ? () => setState(() => _paginaActual++) : null,
                    color: Colors.white,
                  ),
                ],
              ),
              Container(
                color: Colors.grey[900],
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 20),
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
                      onPressed: _toggleEscucha,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoPruebaTexto,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.bug_report),
        tooltip: 'Probar escena o efecto',
      ),
    );
  }
}
