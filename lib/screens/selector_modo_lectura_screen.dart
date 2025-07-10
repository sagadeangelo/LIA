import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progreso_provider.dart';

class SelectorModoLecturaScreen extends StatelessWidget {
  final String libroId;
  final int capituloIndex;
  final String titulo;

  const SelectorModoLecturaScreen({
    super.key,
    required this.libroId,
    required this.capituloIndex,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Selecciona el modo de lectura'),
        backgroundColor: Colors.cyan[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<ProgresoProvider>(
            builder: (context, progreso, _) {
              final estaLeido = progreso.estaLeido(libroId, capituloIndex);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    estaLeido ? Icons.check_circle : Icons.lock_open,
                    size: 80,
                    color: estaLeido ? Colors.greenAccent : Colors.cyanAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    estaLeido ? '✅ Este capítulo ya fue leído.' : '🔓 Capítulo pendiente.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Elige entre una lectura clásica con música relajante o una experiencia inmersiva que reacciona a tu voz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Botón modo clásico
                  ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Lectura Clásica'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/lector',
                        arguments: {
                          'libroId': libroId,
                          'capituloIndex': capituloIndex,
                          'titulo': titulo,
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Botón modo inmersivo
                  ElevatedButton.icon(
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text('Lectura Inmersiva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/voz',
                        arguments: {
                          'libroId': libroId,
                          'capituloIndex': capituloIndex,
                          'titulo': titulo,
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
