// utils/text_helpers.dart
String sinTildes(String texto) {
  const Map<String, String> reemplazos = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
    'ñ': 'n', 'Ñ': 'n',
  };
  return texto.split('').map((c) => reemplazos[c] ?? c).join();
}

bool coincideFuzzy(String reconocida, String objetivo) {
  reconocida = reconocida.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  objetivo = objetivo.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  return reconocida.contains(objetivo) || reconocida.contains(sinTildes(objetivo));
}
