import '../contenidos/indice_capitulos.dart';

String? obtenerContenidoCapitulo(String capituloID) {
  final partes = capituloID.split('_cap_');
  if (partes.length != 2) return null;

  final libroKey = partes[0];
  final capIndex = int.tryParse(partes[1]);
  if (capIndex == null) return null;

  final libro = indiceCapitulos[libroKey];
  if (libro == null) return null;

  final capitulos = libro['capitulos'] as List<dynamic>;
  if (capIndex < 1 || capIndex > capitulos.length) return null;

  return capitulos[capIndex - 1]['contenido'];
}

String? obtenerTituloCapitulo(String capituloID) {
  final partes = capituloID.split('_cap_');
  if (partes.length != 2) return null;

  final libroKey = partes[0];
  final capIndex = int.tryParse(partes[1]);
  if (capIndex == null) return null;

  final libro = indiceCapitulos[libroKey];
  if (libro == null) return null;

  final capitulos = libro['capitulos'] as List<dynamic>;
  if (capIndex < 1 || capIndex > capitulos.length) return null;

  return capitulos[capIndex - 1]['titulo'];
}
