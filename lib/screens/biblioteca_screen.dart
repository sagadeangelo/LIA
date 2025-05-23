import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progreso_provider.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> libros = const [
    {
      'titulo': 'Ángelo y el Proyecto Ditóx',
      'portada': 'assets/images/portada_ditox.png',
      'id': 'angelo_ditox',
    },
    {
      'titulo': 'Ángelo & Los Gadianes',
      'portada': 'assets/images/portada_gadianes.png',
      'id': 'angelo_gadianes',
    },
    {
      'titulo': 'Ángelo y los Artefactos Misteriosos',
      'portada': 'assets/images/portada_artefactos.png',
      'id': 'angelo_artefactos',
    },
  ];

  late final AnimationController _controller;
  late final Animation<double> _animacionLuz;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animacionLuz = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo claro y nítido
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_lector1.2.png',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.05), // fondo claro
              colorBlendMode: BlendMode.lighten,
            ),
          ),

          // Animación tipo loop de luz (halo suave)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animacionLuz,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.8),
                      radius: 1.4,
                      colors: [
                        Colors.cyanAccent.withOpacity(
                          _animacionLuz.value * 0.1,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Contenido de la biblioteca
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: libros.length,
                    itemBuilder: (context, index) {
                      final libro = libros[index];
                      final libroId = libro['id']!;

                      return Card(
                        color: Colors.grey[900]!.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Image.asset(
                                libro['portada']!,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      libro['titulo']!,
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Consumer<ProgresoProvider>(
                                    builder: (context, progreso, _) {
                                      final porcentaje =
                                          progreso.obtenerProgreso(libroId) *
                                          100;
                                      return Text(
                                        '${porcentaje.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              subtitle: const Text(
                                'Autor: Miguel Tovar A.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white38,
                              ),
                              onTap: () {
                             Navigator.pushNamed(
                             context,
                            '/resena-libro',
                           arguments: {'libroId': libroId},
                           );
                           },

                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: Consumer<ProgresoProvider>(
                                builder: (context, progreso, _) {
                                  final avance = progreso.obtenerProgreso(
                                    libroId,
                                  );
                                  final porcentaje = avance * 100;

                                  Color getColor() {
                                    if (porcentaje <= 30)
                                      return Colors.redAccent;
                                    if (porcentaje <= 70) return Colors.amber;
                                    return Colors.greenAccent;
                                  }

                                  return LinearProgressIndicator(
                                    value: avance,
                                    backgroundColor: Colors.white12,
                                    color: getColor(),
                                    minHeight: 6,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
