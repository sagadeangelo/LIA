import 'package:lia_lectura_inmersiva/contenidos/libro_ditox_capitulos.dart' as ditox;
import 'package:lia_lectura_inmersiva/contenidos/angelo_gadianes_capitulos.dart' as gadianes;
import 'package:lia_lectura_inmersiva/contenidos/angelo_artefactos_capitulos.dart' as artefactos;

/// Mapa con títulos y contenidos completos desde manuscritos originales
final Map<String, Map<String, dynamic>> indiceCapitulos = {
  'angelo_ditox': {
    'tituloLibro': 'Ángelo y el Proyecto Ditóx',
    'capitulos': [
      {
        'titulo': 'CAPÍTULO I – LA VIDA DE ÁNGELO',
        'contenido': ditox.capitulo1,
      },
      {
        'titulo': 'CAPÍTULO II – EL SARGENTO SILVANO',
        'contenido': ditox.capitulo2,
      },
      {
        'titulo': 'CAPÍTULO III – LAS VACACIONES DE ÁNGELO',
        'contenido': ditox.capitulo3,
      },
    ],
  },
  'angelo_gadianes': {
    'tituloLibro': 'Ángelo & Los Gadianes',
    'capitulos': [
      {
        'titulo': 'CAPÍTULO I – EL DIARIO DEL ABUELO',
        'contenido': gadianes.capitulo1,
      },
      {
        'titulo': 'CAPÍTULO II – LOS SECRETOS DEL CUARTO ESCONDIDO',
        'contenido': gadianes.capitulo2,
      },
      {
        'titulo': 'CAPÍTULO III – LOS GUARDIANES',
        'contenido': gadianes.capitulo3,
      },
    ],
  },
  'angelo_artefactos': {
    'tituloLibro': 'Ángelo y los Artefactos Misteriosos',
    'capitulos': [
      {
        'titulo': 'CAPÍTULO I – LOS ARTEFACTOS',
        'contenido': artefactos.capitulo1,
      },
      {
        'titulo': 'CAPÍTULO II – UN RIVAL IGNOTO',
        'contenido': artefactos.capitulo2,
      },
      {
        'titulo': 'CAPÍTULO III – ESCENA III',
        'contenido': artefactos.capitulo3,
      },
    ],
  },
};
