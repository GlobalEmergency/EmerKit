import 'clinical_reference.dart';

/// Contiene la información educativa de cualquier herramienta.
/// Reutilizable por todas las features para estandarizar la info.
class ToolInfo {
  final Map<String, String> sections;
  final List<ClinicalReference> references;

  const ToolInfo({required this.sections, required this.references});
}
