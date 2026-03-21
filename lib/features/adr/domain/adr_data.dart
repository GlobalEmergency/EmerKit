import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class AdrData {
  AdrData._();

  static const Map<String, String> infoSections = {
    'Acuerdo ADR':
        'El ADR (Accord relatif au transport international des marchandises Dangereuses '
        'par Route) es el acuerdo europeo que regula el transporte internacional de '
        'mercancías peligrosas por carretera. Clasifica las sustancias en 9 clases '
        'según su peligrosidad y establece las normas de señalización, embalaje y transporte.',
    'Actuación ante incidentes HAZMAT':
        '- Mantener distancia de seguridad (mínimo 100 m, 300 m si hay incendio).\n'
        '- Aproximación desde barlovento (a favor del viento).\n'
        '- Identificar el producto: panel naranja (Kemler/ONU), rombos de peligro.\n'
        '- No tocar, oler ni probar sustancias desconocidas.\n'
        '- Establecer zonas de intervención (caliente, templada, fría).',
    'Uso de la Guía de Respuesta (GRE/ERG)':
        'La Guía de Respuesta en Caso de Emergencia (GRE) permite identificar '
        'rápidamente los riesgos de las sustancias involucradas. Se puede buscar por '
        'número ONU, nombre del producto o tipo de placa/panel. Proporciona distancias '
        'de aislamiento y acciones protectoras inmediatas.',
  };

  static const references = [
    ClinicalReference(
      'ADR 2023 - Acuerdo Europeo sobre Transporte de Mercancías Peligrosas por Carretera. UNECE.',
    ),
    ClinicalReference(
      'Guía de Respuesta en Caso de Emergencia (GRE/ERG). 2020.',
    ),
  ];
}
