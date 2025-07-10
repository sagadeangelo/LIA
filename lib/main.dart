import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/intro_animacion_screen.dart';
import 'screens/intro_splash_screen.dart';
import 'screens/biblioteca_screen.dart';
import 'screens/capitulos_screen.dart';
import 'screens/lector_screen.dart';
import 'screens/voz_reactiva_screen.dart';
import 'screens/selector_modo_lectura_screen.dart';
import 'screens/pantalla_bienvenida.dart';
import 'screens/pantalla_resena_libros.dart'; // ✅ NUEVA IMPORTACIÓN
import 'screens/resena_libro_screen.dart';
import 'pages/lector_por_voz.dart'; // ✅ Escenas activadas por voz

import 'providers/progreso_provider.dart';
import 'contenidos/indice_capitulos.dart';

void main() {
  runApp(const LIAApp());
}

class LIAApp extends StatelessWidget {
  const LIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProgresoProvider())],
      child: MaterialApp(
        title: 'LIA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 16),
          ),
        ),
       initialRoute: '/intro', // 🔄 vuelve a iniciar con la intro animada
routes: {
  '/intro': (context) => const IntroAnimacionScreen(),
  '/splash': (context) => const IntroSplashScreen(),
  '/bienvenida': (context) => const PantallaBienvenida(),
  '/': (context) => const BibliotecaScreen(),
  '/biblioteca': (context) => const BibliotecaScreen(),
  '/capitulos': (context) => const CapitulosScreen(),

  '/resena': (context) => PantallaResenaLibros(), // 👈 sigue disponible si la usas como catálogo completo
  '/resena-libro': (context) => const ResenaLibroScreen(), // ✅ nueva ruta para reseña individual

  '/lector': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final libroId = args?['libroId'] ?? 'angelo_ditox';
    final capituloIndex = args?['capituloIndex'] ?? 0;
    final titulo = args?['titulo'] ?? 'Capítulo';

    return LectorScreen(
      libroId: libroId,
      capituloIndex: capituloIndex,
      titulo: titulo,
    );
  },

  '/voz': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final libroId = args?['libroId'] ?? 'angelo_ditox';
    final capituloIndex = args?['capituloIndex'] ?? 0;

    final capitulos = indiceCapitulos[libroId]?['capitulos'] as List<dynamic>;
    final titulo = capitulos[capituloIndex]['titulo'];
    final contenido = capitulos[capituloIndex]['contenido'];

    return VozReactivaScreen(titulo: titulo, contenido: contenido);
  },

  '/lector-selector': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return SelectorModoLecturaScreen(
      libroId: args?['libroId'] ?? 'angelo_ditox',
      capituloIndex: args?['capituloIndex'] ?? 0,
      titulo: args?['titulo'] ?? 'Capítulo',
    );
          },

          '/voz-demo': (context) => const LectorPorVoz(),
        },
      ),
    );
  }
}
