import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/tool_category.dart';

class ToolEntry {
  final String id;
  final String name;
  final IconData icon;
  final String route;
  final ToolCategory category;
  final bool isExternal;
  final String? externalPackage;

  const ToolEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.category,
    this.isExternal = false,
    this.externalPackage,
  });
}

class ToolRegistry {
  static const tools = [
    // Soporte Vital
    ToolEntry(
        id: 'rcp_rithm',
        name: 'RCP',
        icon: Icons.monitor_heart,
        route: '/rcp-rithm',
        category: ToolCategory.soporteVital),
    ToolEntry(
        id: 'plan_rcp',
        name: 'Algoritmo SVB',
        icon: Icons.account_tree,
        route: '/plan-rcp',
        category: ToolCategory.soporteVital),
    ToolEntry(
        id: 'deamap',
        name: 'DEA Cercano',
        icon: Icons.location_on,
        route: '',
        category: ToolCategory.soporteVital,
        isExternal: true,
        externalPackage: 'es.deamap.mobile'),
    // Valoración
    ToolEntry(
        id: 'glasgow',
        name: 'Glasgow',
        icon: Icons.psychology,
        route: '/glasgow',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'triage',
        name: 'Triage START',
        icon: Icons.priority_high,
        route: '/triage',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'tep',
        name: 'TEP',
        icon: Icons.child_care,
        route: '/tep',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'cincinnati',
        name: 'Cincinnati',
        icon: Icons.favorite,
        route: '/cincinnati',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'madrid_direct',
        name: 'Madrid-DIRECT',
        icon: Icons.local_hospital,
        route: '/madrid-direct',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'nihss',
        name: 'NIHSS',
        icon: Icons.assessment,
        route: '/nihss',
        category: ToolCategory.valoracion),
    ToolEntry(
        id: 'rankin',
        name: 'Rankin',
        icon: Icons.accessibility_new,
        route: '/rankin',
        category: ToolCategory.valoracion),
    // Signos y Valores
    ToolEntry(
        id: 'vital_signs',
        name: 'Constantes Vitales',
        icon: Icons.favorite,
        route: '/vital-signs',
        category: ToolCategory.signosValores),
    ToolEntry(
        id: 'heart_rate',
        name: 'Frecuencia Cardíaca',
        icon: Icons.heart_broken,
        route: '/heart-rate',
        category: ToolCategory.signosValores),
    ToolEntry(
        id: 'glucemia',
        name: 'Glucemia',
        icon: Icons.bloodtype,
        route: '/glucemia',
        category: ToolCategory.signosValores),
    ToolEntry(
        id: 'hipotermia',
        name: 'Hipotermia',
        icon: Icons.ac_unit,
        route: '/hipotermia',
        category: ToolCategory.signosValores),
    ToolEntry(
        id: 'hipertermia',
        name: 'Hipertermia',
        icon: Icons.thermostat,
        route: '/hipertermia',
        category: ToolCategory.signosValores),
    // Oxigenoterapia
    ToolEntry(
        id: 'o2_calculator',
        name: 'Calculadora O\u2082',
        icon: Icons.calculate,
        route: '/o2-calculator',
        category: ToolCategory.oxigenoterapia),
    ToolEntry(
        id: 'oxigenoterapia',
        name: 'Dispositivos O\u2082',
        icon: Icons.air,
        route: '/oxigenoterapia',
        category: ToolCategory.oxigenoterapia),
    // Técnicas
    ToolEntry(
        id: 'ecg',
        name: 'Electrodos ECG',
        icon: Icons.monitor,
        route: '/ecg-leads',
        category: ToolCategory.tecnicas),
    ToolEntry(
        id: 'lund_browder',
        name: 'Lund-Browder',
        icon: Icons.local_fire_department,
        route: '/lund-browder',
        category: ToolCategory.tecnicas),
    ToolEntry(
        id: 'vendajes',
        name: 'Vendajes',
        icon: Icons.healing,
        route: '/vendajes',
        category: ToolCategory.tecnicas),
    ToolEntry(
        id: 'heridas',
        name: 'Heridas',
        icon: Icons.personal_injury,
        route: '/heridas',
        category: ToolCategory.tecnicas),
    ToolEntry(
        id: 'posiciones',
        name: 'Posiciones',
        icon: Icons.airline_seat_recline_extra,
        route: '/posiciones',
        category: ToolCategory.tecnicas),
    // Protección
    ToolEntry(
        id: 'epi',
        name: 'EPI',
        icon: Icons.shield,
        route: '/epi',
        category: ToolCategory.proteccion),
    ToolEntry(
        id: 'adr',
        name: 'ADR',
        icon: Icons.warning_amber,
        route: '/adr',
        category: ToolCategory.proteccion),
    // Comunicación
    ToolEntry(
        id: 'comm',
        name: 'SBAR',
        icon: Icons.forum,
        route: '/comm',
        category: ToolCategory.comunicacion),
    ToolEntry(
        id: 'glosario',
        name: 'Glosario',
        icon: Icons.menu_book,
        route: '/glosario',
        category: ToolCategory.comunicacion),
  ];

  static List<ToolEntry> search(String query) {
    final q = query.toLowerCase();
    return tools.where((t) => t.name.toLowerCase().contains(q)).toList();
  }

  static Map<ToolCategory, List<ToolEntry>> groupByCategory() {
    final map = <ToolCategory, List<ToolEntry>>{};
    for (final tool in tools) {
      map.putIfAbsent(tool.category, () => []).add(tool);
    }
    return map;
  }
}
