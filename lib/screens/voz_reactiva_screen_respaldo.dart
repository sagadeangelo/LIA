import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
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
  late AudioPlayer _audioPlayer;
  bool _listening = false;
  bool _mostroInicio = false;
  String _textoReconocido = '';
  String? _efectoActivado;
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
  };

  final Map<String, List<String>> aliasNombres = {
    'angelo': ['ángelo', 'anghelo', 'angel'],
    'lindsay': ['lindsey', 'linsay', 'lincy'],
    'gibran': ['gibrán', 'jibran', 'gibraán'],
    'khoorx': ['corox', 'corux', 'jorux', 'jorox', 'khorux','corks', 'khorox'],
    'medallon': ['medallón', 'medayon', 'medajon', 'medajón'],
    'abelard': ['abelard', 'abelar', 'avelard', 'abelart', 'abelardo', 'abelhar', 'abelarh'],
    'darien': ['darien', 'darién', 'darian', 'daryen', 'daryan', 'darían'],
    'rachel': ['rachel', 'raquel', 'rashal', 'reichel', 'rashel', 'racheal'],
    'akineanos': ['akineanos', 'akineano', 'aquineanos', 'aquineano', 'akinenos', 'akineros', 'akinianos', 'akimeanos'],
    'akinae': ['akinae', 'akina', 'akinaé', 'aquinae', 'akinaéx', 'akinea', 'akinai', 'akináe'],
    'gadianes': ['gadianes', 'guardianes', 'gallianes', 'gadienes', 'gadrianes','gavianes', 'gadiánes'],
    'doce': ['doce', 'dose', 'dóce', 'doze'],
  };

  final Map<String, String> romanos = {
    'i': '1', 'ii': '2', 'iii': '3', 'iv': '4', 'v': '5',
    'vi': '6', 'vii': '7', 'viii': '8', 'ix': '9', 'x': '10',
    'xi': '11', 'xii': '12', 'xiii': '13', 'xiv': '14', 'xv': '15',
    'xvi': '16', 'xvii': '17', 'xviii': '18', 'xix': '19', 'xx': '20',
    'doce': '12'
  };

  List<String> _palabras = [];
  int _palabraActual = 0;
  String? libroId;
  int? capituloIndex;
  int _palabrasPorPagina = 60;

  int get _paginaActual => (_palabraActual / _palabrasPorPagina).floor();
  int get _totalPaginas => (_palabras.length / _palabrasPorPagina).ceil();

  void _paginaSiguiente() {
    setState(() {
      _palabraActual = ((_paginaActual + 1) * _palabrasPorPagina).clamp(0, _palabras.length);
    });
  }

  void _paginaAnterior() {
    setState(() {
      _palabraActual = ((_paginaActual - 1) * _palabrasPorPagina).clamp(0, _palabras.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioPlayer = AudioPlayer();

    _speech.statusListener = (status) {
      if ((status == 'notListening' || status == 'done') && _listening) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _iniciarEscucha();
        });
      }
    };

    _palabras = widget.contenido
        .replaceAll(RegExp(r'[-–—]'), '')
        .split(RegExp(r'\s+'));

    Future.microtask(() {
      final modalArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      libroId = modalArgs?['libroId'];
      capituloIndex = modalArgs?['capituloIndex'];

      if (libroId != null && capituloIndex != null) {
        final prov = Provider.of<ProgresoProvider>(context, listen: false);
        _palabraActual = prov.obtenerPalabraActual(libroId!, capituloIndex!);
        setState(() {});
      }
    });
  }

  void _iniciarEscucha() async {
    final disponible = await _speech.initialize();

    if (disponible) {
      setState(() {
        _listening = true;
        _efectoActivado = null;
        _opacidadImagen = 0;
      });

      _speech.listen(
        onResult: (val) {
          if (val.recognizedWords.trim().isEmpty) return;

          setState(() {
            _textoReconocido = val.recognizedWords.toLowerCase();

            final clavesOrdenadas = efectos.keys.toList()
              ..sort((a, b) => b.length.compareTo(a.length));

            for (var palabra in clavesOrdenadas) {
              final contiene = _textoReconocido.contains(palabra) ||
                  (aliasNombres[palabra]?.any((alias) => _textoReconocido.contains(alias)) ?? false);

              if (contiene && _puedeActivar(palabra)) {
                _activarEfecto(palabra);
                _forzarAvanceKaraoke(palabra);
                break;
              }
            }

            _resaltarPalabra();
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
            duration: Duration(seconds: 2),
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
        _efectoActivado = null;
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

  void _forzarAvanceKaraoke(String palabraDetectada) {
    final normalizada = normalizarPalabra(palabraDetectada);

    for (int i = _palabraActual; i < (_palabraActual + 5) && i < _palabras.length; i++) {
      final actual = normalizarPalabra(_palabras[i]);
      String combinacion = '';
      if (i + 1 < _palabras.length) {
        final siguiente = normalizarPalabra(_palabras[i + 1]);
        combinacion = '$actual $siguiente';
      }

      if (actual == normalizada || combinacion == normalizada) {
        setState(() {
          _palabraActual = (combinacion == normalizada) ? i + 2 : i + 1;
        });

        if (libroId != null && capituloIndex != null) {
          Provider.of<ProgresoProvider>(context, listen: false)
              .actualizarPalabra(libroId!, capituloIndex!, _palabraActual);
        }

        if (_palabraActual >= _palabras.length) {
          _guardarProgresoFinal();
        }
        break;
      }
    }
  }

  void _activarEfecto(String palabra) async {
    setState(() {
      _efectoActivado = palabra;
      _opacidadImagen = 1;
    });

    final archivo = efectos[palabra] ?? 'placeholder';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.0);
      await _audioPlayer.play(AssetSource('sounds/$archivo.mp3'));
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 40));
        _audioPlayer.setVolume(i / 10);
      }
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }

    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _audioPlayer.stop();
      setState(() {
        _opacidadImagen = 0;
        _efectoActivado = null;
      });
    });
  }

  String normalizarPalabra(String palabra) {
    final limpio = palabra
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáéíóúüñ]'), '')
        .trim();

    if (romanos.containsKey(limpio)) return romanos[limpio]!;

    for (final entrada in aliasNombres.entries) {
      if (entrada.value.contains(limpio)) return entrada.key;
    }

    return limpio;
  }

  void _resaltarPalabra() {
    if (_palabraActual >= _palabras.length) return;

    final textoDetectado = _textoReconocido.toLowerCase();
    int avance = 0;

    for (int i = _palabraActual; i < _palabraActual + 5 && i < _palabras.length; i++) {
      final palabra = normalizarPalabra(_palabras[i]);
      final coincidencias = textoDetectado.split(' ').where((palabraDetectada) {
        final normalizada = normalizarPalabra(palabraDetectada);
        return StringSimilarity.compareTwoStrings(normalizada, palabra) > 0.75;
      });

      if (coincidencias.isNotEmpty) {
        avance = i - _palabraActual + 1;
      }
    }

    if (avance > 0) {
      setState(() => _palabraActual += avance);

      if (_palabraActual >= _palabras.length) {
        _guardarProgresoFinal();
      }

      if (libroId != null && capituloIndex != null) {
        Provider.of<ProgresoProvider>(context, listen: false)
            .actualizarPalabra(libroId!, capituloIndex!, _palabraActual);
      }
    }
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.cyan[900],
      ),
      body: Stack(
        children: [
          if (_efectoActivado != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.85,
              child: AnimatedOpacity(
                opacity: _opacidadImagen,
                duration: const Duration(milliseconds: 400),
                child: Image.asset(
                  'assets/animaciones/${efectos[_efectoActivado!] ?? 'placeholder'}.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Column(
            children: [
              SizedBox(
                height: screenHeight * 0.7,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    text: TextSpan(
                      children: _palabras.asMap().entries
                          .where((entry) =>
                              entry.key >= _paginaActual * _palabrasPorPagina &&
                              entry.key < (_paginaActual + 1) * _palabrasPorPagina)
                          .map((entry) {
                        int i = entry.key;
                        String palabra = entry.value;
                        final esDicha = i < _palabraActual;
                        final esActual = i == _palabraActual;

                        return TextSpan(
                          text: '$palabra ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: esDicha
                                ? Colors.greenAccent
                                : esActual
                                    ? Colors.yellowAccent
                                    : Colors.white,
                            decoration: esActual
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _paginaAnterior,
                  ),
                  Text(
                    'Página ${_paginaActual + 1} / $_totalPaginas',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _paginaSiguiente,
                  ),
                ],
              ),
              Container(
                color: Colors.grey[850],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Modo clásico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _listening ? _detenerEscucha : _iniciarEscucha,
                      icon: Icon(_listening ? Icons.mic_off : Icons.mic),
                      label: Text(_listening ? 'Detener voz' : 'Activar voz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[700],
                      ),
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
