import 'package:flutter/material.dart';

class ResenaLibroScreen extends StatelessWidget {
  const ResenaLibroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final libroId = args?['libroId'] ?? 'angelo_ditox';
    final datos = _datosLibro(libroId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(datos['titulo']),
        backgroundColor: Colors.cyan[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(datos['portada'], fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              datos['titulo'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 12),
            Text(
              datos['resumen'],
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Volver a biblioteca', style: TextStyle(color: Colors.cyanAccent)),
                ),
              ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/capitulos',
      arguments: libroId,
    );
  },
  child: const Text('Ver capítulos'),
),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _datosLibro(String id) {
    switch (id) {
      case 'angelo_ditox':
        return {
          'titulo': 'Ángelo & El Proyecto Ditox',
          'portada': 'assets/images/portada_ditox.png',
          'resumen': 'Ángelo descubre una conspiración biotecnológica que podría cambiar el futuro de la humanidad. Su lucha contra los efectos de un proyecto toxicológico experimental lo lleva a redefinir su identidad y propósito.'
        };
      case 'angelo_gadianes':
        return {
          'titulo': 'Ángelo y Los Gadianes',
          'portada': 'assets/images/portada_gadianes.png',
          'resumen': 'Cuando Ángelo es convocado por los Gadianes, protectores de secretos ancestrales, deberá enfrentar su pasado y unir fuerzas con aliados insospechados en una batalla por el equilibrio del conocimiento.'
        };
      case 'angelo_artefactos':
        return {
          'titulo': 'Ángelo & Los Artefactos Misteriosos',
          'portada': 'assets/images/portada_artefactos.png',
          'resumen': 'Antiguos artefactos han sido activados, y sólo Ángelo posee la clave para descifrar su poder. En una carrera contra el tiempo, se enfrenta a enemigos invisibles y desafíos que lo llevarán más allá de los límites de la lógica.'
        };
      default:
        return {
          'titulo': 'Libro desconocido',
          'portada': 'assets/images/portada_ditox.png',
          'resumen': 'No se encontró información para este libro.'
        };
    }
  }
}
