import 'package:emerkit/shared/domain/entities/clinical_reference.dart';

class GpsConverterData {
  GpsConverterData._();

  static const Map<String, String> infoSections = {
    'Coordenadas en emergencias':
        'Comunicar la ubicacion exacta es critico en emergencias sanitarias. '
            'Las coordenadas GPS permiten localizar al paciente con precision, '
            'especialmente en zonas rurales, montanas o donde no hay direccion postal.',
    'Grados decimales (DD)':
        'Formato mas simple: latitud y longitud como numeros decimales. '
            'Ejemplo: 40.524722°, -3.891667°. '
            'Es el formato nativo del GPS y el mas usado en aplicaciones digitales.',
    'Grados y minutos (DM)': 'Divide cada grado en 60 minutos con decimales. '
        'Ejemplo: 40° 31.4833\' N, 3° 53.5000\' W. '
        'Usado habitualmente en navegacion maritima y aeronautica.',
    'Grados, minutos y segundos (DMS)':
        'Formato tradicional de cartografia. Divide cada minuto en 60 segundos. '
            'Ejemplo: 40° 31\' 29.00" N, 3° 53\' 30.00" W. '
            'Es el formato mas comun en comunicaciones de emergencia por radio.',
    'UTM (Universal Transverse Mercator)':
        'Sistema metrico que divide la Tierra en 60 zonas. '
            'Ejemplo: 30T 424472E 4486380N. '
            'Usado por servicios de emergencia, ejercito y cartografia oficial '
            'porque permite medir distancias directamente en metros.',
    'MGRS (Military Grid Reference System)':
        'Extension del UTM usado por la OTAN y fuerzas de seguridad. '
            'Anade una referencia de cuadricula de 100km al formato UTM. '
            'Ejemplo: 30T VK 24472 86380.',
    'Navegacion':
        'Al pulsar "Navegar", se abrira la aplicacion de mapas configurada '
            'en el dispositivo (Google Maps, Waze, etc.) con las coordenadas como destino.',
  };

  static const references = [
    ClinicalReference(
      'Defense Mapping Agency. The Universal Grids: Universal Transverse '
      'Mercator (UTM) and Universal Polar Stereographic (UPS). DMA TM 8358.2. 1989.',
    ),
    ClinicalReference(
      'National Geospatial-Intelligence Agency. Military Map Reading 200. 2024.',
    ),
    ClinicalReference(
      'Instituto Geografico Nacional. Sistema de referencia geodesico ETRS89. 2023.',
    ),
  ];
}
