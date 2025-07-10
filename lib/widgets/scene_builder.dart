// scene_builder.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class SceneBuilder extends StatefulWidget {
  final String palabraClave;

  const SceneBuilder({super.key, required this.palabraClave});

  @override
  State<SceneBuilder> createState() => _SceneBuilderState();
}

class _SceneBuilderState extends State<SceneBuilder> {
  Map<String, dynamic>? escenas;
  Map<String, dynamic>? escenaActiva;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _cargarEscenas();
  }

  Future<void> _cargarEscenas() async {
    final String jsonStr = await rootBundle.loadString('assets/data/escenas_completas.json');
    final Map<String, dynamic> data = json.decode(jsonStr);

    for (var escena in data.entries) {
      final List claves = escena.value['palabras_clave'];
      if (claves.contains(widget.palabraClave.toLowerCase())) {
        setState(() {
          escenaActiva = escena.value;
        });
        _reproducirSonido(escena.value['sonido_ambiente']);
        break;
      }
    }

    setState(() {
      escenas = data;
    });
  }

  void _reproducirSonido(String? path) {
    if (path != null && path.isNotEmpty) {
      _audioPlayer.play(AssetSource(path));
    }
  }

  Widget _renderElemento(Map elemento) {
    String tipo = elemento['tipo'];
    String src = elemento['src'];

    Widget widgetAnim;
    if (src.endsWith('.json')) {
      widgetAnim = Lottie.network(src, repeat: true);
    } else if (src.startsWith('assets/')) {
      widgetAnim = Image.asset(src);
    } else {
      widgetAnim = const SizedBox();
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: 1,
      child: widgetAnim,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (escenaActiva == null) {
      return const SizedBox.shrink();
    }

    final elementos = escenaActiva!['elementos'] as List<dynamic>;

    return Stack(
      children: elementos.map((e) => _renderElemento(e)).toList(),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
