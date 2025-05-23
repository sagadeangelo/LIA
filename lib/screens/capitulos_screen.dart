import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progreso_provider.dart';
import '../contenidos/indice_capitulos.dart';

class CapitulosScreen extends StatefulWidget {
  const CapitulosScreen({super.key});

  @override
  State<CapitulosScreen> createState() => _CapitulosScreenState();
}

class _CapitulosScreenState extends State<CapitulosScreen> {
  late String libroId;
  late List<Map<String, String>> capitulos = [];
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      libroId = ModalRoute.of(context)!.settings.arguments as String? ?? 'angelo_ditox';

      final dataLibro = indiceCapitulos[libroId];
      if (dataLibro != null) {
        final rawCaps = dataLibro['capitulos'] as List<dynamic>;
        capitulos = rawCaps.cast<Map<String, String>>();
      }

      final progresoProvider = Provider.of<ProgresoProvider>(context, listen: false);
      progresoProvider.inicializarLibro(libroId, capitulos.length);

      _inicializado = true;
    }
  }

  void _confirmarRestauracionLibro(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Restablecer todo el libro?'),
        content: const Text('Esto reiniciará el progreso de todos los capítulos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProgresoProvider>(context, listen: false).reiniciarLibro(libroId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progreso del libro reiniciado')),
              );
              setState(() {});
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _confirmarRestauracionCapitulo(BuildContext context, int index, String titulo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Restablecer este capítulo?'),
        content: Text('Esto eliminará el progreso del capítulo:\n"$titulo"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProgresoProvider>(context, listen: false)
                  .reiniciarCapitulo(libroId, index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Capítulo reiniciado')),
              );
              setState(() {});
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capítulos'),
        backgroundColor: Colors.cyan[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Restablecer todo el libro',
            onPressed: () => _confirmarRestauracionLibro(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Opacity(
              opacity: 0.25, // Ajusta la opacidad según desees
              child: Image.asset(
                'assets/images/fondo_saga_blur.png', // ✅ Imagen que subiste
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido encima del fondo
          Column(
            children: [
              // Barra de progreso
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<ProgresoProvider>(
                  builder: (context, progreso, _) {
                    final porcentaje = progreso.obtenerProgreso(libroId) * 100;
                    return LinearProgressIndicator(
                      value: porcentaje / 100,
                      backgroundColor: Colors.grey[300],
                      color: Colors.cyan,
                    );
                  },
                ),
              ),

              // Lista de capítulos
              Expanded(
                child: Consumer<ProgresoProvider>(
                  builder: (context, progreso, _) {
                    return ListView.builder(
                      itemCount: capitulos.length,
                      itemBuilder: (context, index) {
                        final cap = capitulos[index];
                        final titulo = cap['titulo'] ?? 'Sin título';
                        final estaLeido = progreso.estaLeido(libroId, index);

                        return ListTile(
                          title: Text(
                            titulo,
                            style: TextStyle(
                              color: estaLeido ? Colors.grey : Colors.white,
                              decoration: estaLeido ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (estaLeido)
                                IconButton(
                                  icon: const Icon(Icons.restart_alt, color: Colors.orangeAccent),
                                  tooltip: 'Restablecer lectura',
                                  onPressed: () => _confirmarRestauracionCapitulo(
                                    context,
                                    index,
                                    titulo,
                                  ),
                                ),
                              Icon(
                                estaLeido ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: estaLeido ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            progreso.marcarComoLeido(libroId, index);
                            Navigator.pushNamed(
                              context,
                              '/lector-selector',
                              arguments: {
                                'libroId': libroId,
                                'capituloIndex': index,
                                'titulo': titulo,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
