import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../contenidos/indice_capitulos.dart';

class LectorScreen extends StatefulWidget {
  final String libroId;
  final int capituloIndex;
  final String titulo;

  const LectorScreen({
    super.key,
    required this.libroId,
    required this.capituloIndex,
    required this.titulo,
  });

  @override
  State<LectorScreen> createState() => _LectorScreenState();
}

class _LectorScreenState extends State<LectorScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _paginas = [];
  int _paginaActual = 0;
  bool _progresoGuardado = false;
  List<dynamic> _capitulos = [];

  @override
  void initState() {
    super.initState();
    _reproducirMusica();
  }

  Future<void> _reproducirMusica() async {
    await _audioPlayer.play(AssetSource('audio/musica_futurista.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<String> _dividirEnPaginas(String texto, {int caracteresPorPagina = 1000}) {
    texto = texto.replaceAll('\n', ' ').trim();
    List<String> paginas = [];
    for (int i = 0; i < texto.length; i += caracteresPorPagina) {
      int fin = i + caracteresPorPagina;
      if (fin > texto.length) fin = texto.length;
      paginas.add(texto.substring(i, fin).trim());
    }
    return paginas;
  }

  void _guardarProgresoSiEsUltimaPagina() {
    if (!_progresoGuardado && _paginaActual == _paginas.length - 1) {
      debugPrint("Lectura clásica finalizada (no se marca como leída)");
      setState(() {
        _progresoGuardado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataLibro = indiceCapitulos[widget.libroId];
    _capitulos = dataLibro?['capitulos'] as List<dynamic>? ?? [];

    final textoCompleto = _capitulos
        .map((c) => c['contenido']?.toString() ?? '')
        .join('\n\n');

    if (_paginas.isEmpty && textoCompleto.isNotEmpty) {
      _paginas = _dividirEnPaginas(textoCompleto);
      debugPrint("Total de páginas generadas: ${_paginas.length}");
      debugPrint("Longitud del texto combinado: ${textoCompleto.length}");
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.cyan[900],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.08,
            child: Image.asset(
              'assets/images/fondo_lector.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    key: ValueKey(_paginaActual),
                    child: Text(
                      _paginas[_paginaActual],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _paginaActual > 0
                          ? () => setState(() => _paginaActual--)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                    Text(
                      'Página ${_paginaActual + 1} de ${_paginas.length}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    ElevatedButton.icon(
                      onPressed: _paginaActual < _paginas.length - 1
                          ? () => setState(() {
                                _paginaActual++;
                                _guardarProgresoSiEsUltimaPagina();
                              })
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
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
