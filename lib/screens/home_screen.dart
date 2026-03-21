import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tool_card.dart';

class _ToolItem {
  final String title;
  final IconData icon;
  final String route;

  const _ToolItem(this.title, this.icon, this.route);
}

class _Section {
  final String title;
  final Color color;
  final List<_ToolItem> tools;

  const _Section(this.title, this.color, this.tools);
}

final _sections = [
  _Section('Soporte Vital', AppColors.soporteVital, [
    _ToolItem('Metrónomo RCP', Icons.monitor_heart, '/rcp-rithm'),
    _ToolItem('Algoritmo SVB', Icons.account_tree, '/plan-rcp'),
  ]),
  _Section('Valoración', AppColors.valoracion, [
    _ToolItem('Glasgow', Icons.psychology, '/glasgow'),
    _ToolItem('Triage START', Icons.priority_high, '/triage'),
    _ToolItem('TEP', Icons.child_care, '/tep'),
    _ToolItem('Ictus', Icons.emergency, '/ictus'),
    _ToolItem('NIHSS', Icons.assessment, '/nihss'),
    _ToolItem('Rankin', Icons.accessibility_new, '/rankin'),
  ]),
  _Section('Signos y Valores', AppColors.signosValores, [
    _ToolItem('Constantes Vitales', Icons.favorite, '/vital-signs'),
    _ToolItem('Frecuencia Cardíaca', Icons.heart_broken, '/heart-rate'),
    _ToolItem('Glucemia', Icons.bloodtype, '/glucemia'),
    _ToolItem('Hipotermia', Icons.ac_unit, '/hipotermia'),
    _ToolItem('Hipertermia', Icons.thermostat, '/hipertermia'),
  ]),
  _Section('Oxigenoterapia', AppColors.oxigenoterapia, [
    _ToolItem('Calculadora O₂', Icons.calculate, '/o2-calculator'),
    _ToolItem('Dispositivos O₂', Icons.air, '/oxigenoterapia'),
  ]),
  _Section('Técnicas', AppColors.tecnicas, [
    _ToolItem('Electrodos ECG', Icons.monitor, '/ecg-leads'),
    _ToolItem('Lund-Browder', Icons.local_fire_department, '/lund-browder'),
    _ToolItem('Vendajes', Icons.healing, '/vendajes'),
    _ToolItem('Heridas', Icons.personal_injury, '/heridas'),
    _ToolItem('Posiciones', Icons.airline_seat_recline_extra, '/posiciones'),
  ]),
  _Section('Protección', AppColors.proteccion, [
    _ToolItem('EPI', Icons.shield, '/epi'),
    _ToolItem('ADR', Icons.warning_amber, '/adr'),
  ]),
  _Section('Comunicación', AppColors.comunicacion, [
    _ToolItem('SBAR', Icons.forum, '/comm'),
  ]),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  List<_Section> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    final query = _searchQuery.toLowerCase();
    return _sections
        .map((s) => _Section(
              s.title,
              s.color,
              s.tools.where((t) => t.title.toLowerCase().contains(query)).toList(),
            ))
        .where((s) => s.tools.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _filteredSections;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navaja Suiza Sanitaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Sugerencias',
            onPressed: () => context.push('/feedback'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Acerca de',
            onPressed: () => context.push('/about'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar herramienta...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
            // Tools grid
            Expanded(
              child: sections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No se encontraron herramientas',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: sections.length,
                      itemBuilder: (context, sectionIndex) {
                        final section = sections[sectionIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: section.title, color: section.color),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.9,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: section.tools.length,
                                itemBuilder: (context, toolIndex) {
                                  final tool = section.tools[toolIndex];
                                  return ToolCard(
                                    title: tool.title,
                                    icon: tool.icon,
                                    color: section.color,
                                    onTap: () => context.push(tool.route),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
