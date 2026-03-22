import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/utils/external_app_launcher.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_card.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/section_header.dart';
import 'package:navaja_suiza_sanitaria/shared/domain/entities/tool_category.dart';
import 'tool_registry.dart';

/// Maps each ToolCategory to its brand color.
const _categoryColors = <ToolCategory, Color>{
  ToolCategory.soporteVital: AppColors.soporteVital,
  ToolCategory.valoracion: AppColors.valoracion,
  ToolCategory.signosValores: AppColors.signosValores,
  ToolCategory.oxigenoterapia: AppColors.oxigenoterapia,
  ToolCategory.tecnicas: AppColors.tecnicas,
  ToolCategory.proteccion: AppColors.proteccion,
  ToolCategory.comunicacion: AppColors.comunicacion,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  Map<ToolCategory, List<ToolEntry>> get _filteredGroups {
    final all = ToolRegistry.groupByCategory();
    if (_searchQuery.isEmpty) return all;
    final query = _searchQuery.toLowerCase();
    final filtered = <ToolCategory, List<ToolEntry>>{};
    for (final entry in all.entries) {
      final matching = entry.value
          .where((t) => t.name.toLowerCase().contains(query))
          .toList();
      if (matching.isNotEmpty) {
        filtered[entry.key] = matching;
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filteredGroups;
    final categories = groups.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EmerKit'),
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
            // Tools grid
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No se encontraron herramientas',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, sectionIndex) {
                        final category = categories[sectionIndex];
                        final tools = groups[category]!;
                        final color =
                            _categoryColors[category] ?? AppColors.primary;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: category.label, color: color),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.9,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: tools.length,
                                itemBuilder: (context, toolIndex) {
                                  final tool = tools[toolIndex];
                                  return ToolCard(
                                    title: tool.name,
                                    icon: tool.icon,
                                    color: color,
                                    isExternal: tool.isExternal,
                                    onTap: () {
                                      if (tool.isExternal &&
                                          tool.externalPackage != null) {
                                        ExternalAppLauncher.launchOrStore(
                                            packageName: tool.externalPackage!);
                                      } else {
                                        context.push(tool.route);
                                      }
                                    },
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
