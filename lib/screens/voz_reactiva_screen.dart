import 'dart:async';
import '../widgets/animacion_tinta_desparramada.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
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
    'gibran': 'gibran',
    'lindsay': 'lindsay',
    'anastasia': 'anastasia',
    'augusto': 'augusto',
  };

  final Map<String, List<String>> aliasNombres = {
    'angelo': ['ángelo', 'anghelo', 'angel'],
    'khoorx': ['corox', 'corux', 'jorux', 'jorox', 'khorux', 'corks', 'khorox'],
    'medallon': ['medallón', 'medayon', 'medajon', 'medajón'],
    'abelard': ['abelard', 'abelar', 'avelard', 'abelart', 'abelardo', 'abelhar', 'abelarh'],
    'darien': ['darien', 'darién', 'darian', 'daryen', 'daryan', 'darían'],
    'rachel': ['rachel', 'raquel', 'rashal', 'reichel', 'rashel', 'racheal'],
    'akineanos': ['akineanos', 'akineano', 'aquineanos', 'aquineano', 'akinenos', 'akineros', 'akinianos', 'akimeanos'],
    'akinae': ['akinae', 'akina', 'akinaé', 'aquinae', 'akinaéx', 'akinea', 'akinai', 'akináe'],
    'gadianes': ['gadianes', 'guardianes', 'gallianes', 'gadienes', 'gadrianes', 'gavianes', 'gadiánes'],
    'doce': ['doce', 'dose', 'dóce', 'doze'],
    'lindsay': ['lindsay', 'lincy', 'linsay', 'linsey', 'mi hermana', 'hermana', 'lindsey', 'linsay'],
    'gibran': ['gibrán', 'gibran', 'mi hermano', 'hermano', 'gibraán'],
    'anastasia': ['anastasia', 'anastacia', 'mi mamá', 'mamá', 'mama', 'madre'],
    'augusto': ['augusto', 'papá', 'papa', 'mi papá', 'padre'],

  };

  final Map<String, String> romanos = {
    'i': '1', 'ii': '2', 'iii': '3', 'iv': '4', 'v': '5',
    'vi': '6', 'vii': '7', 'viii': '8', 'ix': '9', 'x': '10',
    'xi': '11', 'xii': '12', 'xiii': '13', 'xiv': '14', 'xv': '15',
    'xvi': '16', 'xvii': '17', 'xviii': '18', 'xix': '19', 'xx': '20',
    'doce': '12'
  };

  List<String> _paginas = [];
  int _paginaActual = 0;
  String? libroId;
  int? capituloIndex;
  final List<String> _efectosActivos = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        if (mounted && _listening) _iniciarEscucha();
      }
    };

    _paginas = _dividirEnPaginas(widget.contenido);

    Future.microtask(() {
      final modalArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      libroId = modalArgs?['libroId'];
      capituloIndex = modalArgs?['capituloIndex'];
    });
  }

  List<String> _dividirEnPaginas(String texto) {
    final palabras = texto.split(RegExp(r'\s+'));
    const palabrasPorPagina = 100;
    List<String> paginas = [];
    for (int i = 0; i < palabras.length; i += palabrasPorPagina) {
      paginas.add(palabras.skip(i).take(palabrasPorPagina).join(' '));
    }
    return paginas;
  }

  void _iniciarEscucha() async {
    final disponible = await _speech.initialize(
      onStatus: (val) => print('🟢 Estado: $val'),
      onError: (val) => print('❌ Error: $val'),
    );

    if (disponible) {
      setState(() {
        _listening = true;
        _efectosActivos.clear();
        _opacidadImagen = 0;
      });

      _speech.listen(
        onResult: (val) {
          if (val.recognizedWords.trim().isEmpty) return;

          setState(() {
            _textoReconocido = val.recognizedWords.toLowerCase();
            final clavesOrdenadas = efectos.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
            final Set<String> palabrasDetectadas = {};

            for (var palabra in clavesOrdenadas) {
              final contiene = _textoReconocido.contains(palabra) ||
                  (aliasNombres[palabra]?.any((alias) => _textoReconocido.contains(alias)) ?? false);

              if (contiene && !palabrasDetectadas.contains(palabra) && _puedeActivar(palabra)) {
                palabrasDetectadas.add(palabra);
                _activarEfecto(palabra);
              }
            }
          });

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
            duration: Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        _mostroInicio = true;
      }
    }
  }

  void _detenerEscucha() async {
    if (_listening) {
      await _speech.stop();
      setState(() {
        _listening = false;
        _textoReconocido = '';
        _efectosActivos.clear();
        _opacidadImagen = 0;
      });
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
    final archivo = efectos[palabra] ?? 'placeholder';
    final player = AudioPlayer();

    _efectosActivos.add(archivo);
    setState(() => _opacidadImagen = 1);

    await player.setSource(AssetSource('sounds/$archivo.mp3'));
    await player.resume();

    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      await player.stop();
      setState(() {
        _efectosActivos.remove(archivo);
        if (_efectosActivos.isEmpty) _opacidadImagen = 0;
      });
    });
  }

  void _guardarProgresoFinal() {
    if (libroId != null && capituloIndex != null) {
      Provider.of<ProgresoProvider>(context, listen: false)
          .marcarComoLeido(libroId!, capituloIndex!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Capítulo completado'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.cyan[900],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalHeight = constraints.maxHeight;
            final double alturaAnimacion = _efectosActivos.isNotEmpty ? totalHeight * 100 : 0.0;
            final alturaTexto = totalHeight - 160;

            return Stack(
              children: [
                if (_efectosActivos.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: alturaAnimacion,
                    child: AnimatedOpacity(
                      opacity: _opacidadImagen,
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        children: _efectosActivos.map((archivo) => Expanded(
                          child: AnimacionTintaDesparramada(
                            imagePath: 'assets/animaciones/$archivo.png',
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    SizedBox(
                      height: alturaTexto,
                      child: Center(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            );
          },
        ),
      ),
    );
  }
}
