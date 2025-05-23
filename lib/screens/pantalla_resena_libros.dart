import 'package:flutter/material.dart';

class PantallaResenaLibros extends StatelessWidget {
  const PantallaResenaLibros({super.key});

  final List<Map<String, String>> libros = const [
    {
      'id': 'libro1',
      'titulo': 'Ángelo & El Proyecto Ditox',
      'portada': 'assets/portadas/libro1.png',
      'resumen': 'Ángelo descubre una conspiración biotecnológica que podría cambiar el futuro de la humanidad. Su lucha contra los efectos de un proyecto toxicológico experimental lo lleva a redefinir su identidad y propósito.'
    },
    {
      'id': 'libro2',
      'titulo': 'Ángelo y Los Gadianes',
      'portada': 'assets/portadas/libro2.png',
      'resumen': 'Cuando Ángelo es convocado por los Gadianes, protectores de secretos ancestrales, deberá enfrentar su pasado y unir fuerzas con aliados insospechados en una batalla por el equilibrio del conocimiento.'
    },
    {
      'id': 'libro3',
      'titulo': 'Ángelo & Los Artefactos Misteriosos',
      'portada': 'assets/portadas/libro3.png',
      'resumen': 'Antiguos artefactos han sido activados, y sólo Ángelo posee la clave para descifrar su poder. En una carrera contra el tiempo, se enfrenta a enemigos invisibles y desafíos que lo llevarán más allá de los límites de la lógica.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Catálogo de libros'),
        backgroundColor: Colors.cyan[900],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: libros.length,
        itemBuilder: (context, index) {
          final libro = libros[index];
          return Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(libro['portada']!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    libro['titulo']!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    libro['resumen']!,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/lector-selector',
                          arguments: {
                            'libroId': libro['id'],
                            'capituloIndex': 0,
                            'titulo': 'Capítulo 1',
                          },
                        );
                      },
                      child: const Text('Comenzar lectura'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
