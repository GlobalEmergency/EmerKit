import 'package:flutter/material.dart';
import '../../domain/entities/clinical_reference.dart';
import 'info_card.dart';

/// Panel de información para el BottomSheet de info de cada herramienta.
/// Renderiza las secciones de info + referencias bibliográficas.
class ToolInfoPanel extends StatelessWidget {
  final Map<String, String> sections;
  final List<ClinicalReference> references;

  const ToolInfoPanel({
    super.key,
    required this.sections,
    required this.references,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sections.entries.map((e) => InfoCard(title: e.key, content: e.value)),
          if (references.isNotEmpty)
            InfoCard(
              title: 'Referencias',
              content: references.map((r) => r.citation).join('\n\n'),
            ),
        ],
      ),
    );
  }
}
