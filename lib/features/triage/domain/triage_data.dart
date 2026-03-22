import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';
import 'triage_engine.dart';

/// Static clinical data for START triage.
class TriageData {
  TriageData._();

  static const String startNodeId = 'walk';

  static const triageNodes = <String, TriageNode>{
    'walk': TriageNode(
      question: '¿Puede caminar?',
      yesNode: 'green',
      noNode: 'breathe',
    ),
    'green': TriageNode(
      question: '',
      result: TriageColor.green,
    ),
    'breathe': TriageNode(
      question: '¿Respira?',
      yesNode: 'resp_rate',
      noNode: 'open_airway',
    ),
    'open_airway': TriageNode(
      question: '¿Respira tras abrir vía aérea?',
      action: 'Abrir vía aérea (maniobra frente-mentón)',
      yesNode: 'red_immediate',
      noNode: 'black',
    ),
    'black': TriageNode(
      question: '',
      result: TriageColor.black,
    ),
    'resp_rate': TriageNode(
      question: '¿Frecuencia respiratoria < 30 rpm?',
      yesNode: 'perfusion',
      noNode: 'red_immediate',
    ),
    'perfusion': TriageNode(
      question: '¿Relleno capilar < 2 segundos?\n(o pulso radial presente)',
      yesNode: 'mental_status',
      noNode: 'red_immediate',
    ),
    'mental_status': TriageNode(
      question: '¿Obedece órdenes simples?',
      yesNode: 'yellow',
      noNode: 'red_immediate',
    ),
    'yellow': TriageNode(
      question: '',
      result: TriageColor.yellow,
    ),
    'red_immediate': TriageNode(
      question: '',
      result: TriageColor.red,
    ),
  };

  static const infoSections = <String, String>{
    '¿Qué es?': 'El triage START (Simple Triage and Rapid Treatment) es un sistema de clasificación '
        'de víctimas diseñado para incidentes con múltiples víctimas (IMV). Permite una valoración '
        'rápida en menos de 60 segundos por paciente, priorizando la atención según la gravedad.',
    'Cuándo utilizarlo': 'Incidentes con múltiples víctimas (IMV)\n'
        'Catástrofes y desastres\n'
        'Situaciones con recursos sanitarios limitados\n'
        'Cuando es necesario priorizar la atención de múltiples pacientes',
    'Interpretación de colores':
        'VERDE (Leve): Paciente que puede caminar. Atención demorable.\n\n'
            'AMARILLO (Urgente): Respira, tiene perfusión adecuada y obedece órdenes. '
            'Requiere atención urgente pero puede esperar.\n\n'
            'ROJO (Inmediato): Compromiso de vía aérea, respiración (FR >= 30) o '
            'circulación (relleno capilar >= 2s) o no obedece órdenes. Atención inmediata.\n\n'
            'NEGRO (Fallecido): No respira ni siquiera tras apertura de vía aérea.',
  };

  static const references = <ClinicalReference>[
    ClinicalReference(
      'Simple Triage and Rapid Treatment (START). Newport Beach Fire Department, 1983.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 9th Edition. Jones & Bartlett, 2020.',
    ),
  ];
}
