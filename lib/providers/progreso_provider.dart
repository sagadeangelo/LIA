import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgresoProvider extends ChangeNotifier {
  final Map<String, List<bool>> _capitulosLeidos = {};
  final Map<String, Map<int, int>> _progresoPalabras = {}; // libroId → {capitulo → palabra}

  ProgresoProvider() {
    _cargarProgresoDesdeStorage();
  }

  void inicializarLibro(String libroId, int totalCapitulos) {
    if (!_capitulosLeidos.containsKey(libroId)) {
      _capitulosLeidos[libroId] = List.generate(totalCapitulos, (_) => false);
    }
    _progresoPalabras.putIfAbsent(libroId, () => {});
  }

  void marcarComoLeido(String libroId, int capituloIndex) {
    if (_capitulosLeidos.containsKey(libroId)) {
      if (capituloIndex >= 0 && capituloIndex < _capitulosLeidos[libroId]!.length) {
        _capitulosLeidos[libroId]![capituloIndex] = true;
        notifyListeners();
        _guardarProgresoEnStorage();
      }
    }
  }

  void reiniciarLibro(String libroId) {
    if (_capitulosLeidos.containsKey(libroId)) {
      _capitulosLeidos[libroId] = List.filled(_capitulosLeidos[libroId]!.length, false);
    }
    _progresoPalabras[libroId]?.clear();
    notifyListeners();
    _guardarProgresoEnStorage();
  }

  void reiniciarCapitulo(String libroId, int capituloIndex) {
    if (_capitulosLeidos.containsKey(libroId)) {
      if (capituloIndex >= 0 && capituloIndex < _capitulosLeidos[libroId]!.length) {
        _capitulosLeidos[libroId]![capituloIndex] = false;
        _progresoPalabras[libroId]?[capituloIndex] = 0;
        notifyListeners();
        _guardarProgresoEnStorage();
      }
    }
  }

  bool estaLeido(String libroId, int capituloIndex) {
    return _capitulosLeidos[libroId]?[capituloIndex] ?? false;
  }

  double obtenerProgreso(String libroId) {
    final capitulos = _capitulosLeidos[libroId];
    if (capitulos == null || capitulos.isEmpty) return 0.0;
    final leidos = capitulos.where((c) => c).length;
    return leidos / capitulos.length;
  }

  void actualizarPalabra(String libroId, int capituloIndex, int palabraIndex) {
    _progresoPalabras[libroId] ??= {};
    _progresoPalabras[libroId]![capituloIndex] = palabraIndex;
    notifyListeners();
    _guardarProgresoEnStorage();
  }

  int obtenerPalabraActual(String libroId, int capituloIndex) {
    return _progresoPalabras[libroId]?[capituloIndex] ?? 0;
  }

  Future<void> _guardarProgresoEnStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCapitulos = jsonEncode(_capitulosLeidos.map(
      (key, value) => MapEntry(key, value.map((e) => e ? 1 : 0).toList()),
    ));
    final jsonPalabras = jsonEncode(_progresoPalabras.map(
      (key, map) => MapEntry(key, map.map((k, v) => MapEntry(k.toString(), v))),
    ));
    await prefs.setString('progreso', jsonCapitulos);
    await prefs.setString('palabras', jsonPalabras);
  }

  Future<void> _cargarProgresoDesdeStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCapitulos = prefs.getString('progreso');
    final jsonPalabras = prefs.getString('palabras');

    if (jsonCapitulos != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonCapitulos);
      _capitulosLeidos.clear();
      jsonMap.forEach((key, value) {
        final list = (value as List).map((e) => e == 1).toList();
        _capitulosLeidos[key] = List<bool>.from(list);
      });
    }

    if (jsonPalabras != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonPalabras);
      _progresoPalabras.clear();
      jsonMap.forEach((libroId, mapa) {
        _progresoPalabras[libroId] = (mapa as Map).map((k, v) => MapEntry(int.parse(k), v as int));
      });
    }

    notifyListeners();
  }
}
