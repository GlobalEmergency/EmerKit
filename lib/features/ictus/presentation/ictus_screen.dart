import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import '../domain/cincinnati_calculator.dart';
import '../domain/madrid_direct_calculator.dart';
import '../domain/ictus_data.dart';

class IctusScreen extends StatefulWidget {
  const IctusScreen({super.key});

  @override
  State<IctusScreen> createState() => _IctusScreenState();
}

class _IctusScreenState extends State<IctusScreen> {
  static const _cincinnatiCalculator = CincinnatiCalculator();
  static const _madridDirectCalculator = MadridDirectCalculator();

  // Cincinnati
  bool? _facialDroop;
  bool? _armDrift;
  bool? _speech;

  // Madrid-DIRECT - clinical items (+1 each)
  bool _armNoGravity = false;
  bool _legNoGravity = false;
  bool _gazeDeviation = false;
  bool _noObeyOrders = false;
  bool _noRecognizeDeficit = false;
  // Modifiers
  int _tas = 140;
  int _age = 65;

  bool get _cincinnatiComplete =>
      _facialDroop != null && _armDrift != null && _speech != null;

  CincinnatiResult? get _cincinnatiResult {
    if (!_cincinnatiComplete) return null;
    return _cincinnatiCalculator.calculate(
      facialDroop: _facialDroop!,
      armDrift: _armDrift!,
      speech: _speech!,
    );
  }

  MadridDirectResult get _madridDirectResult =>
      _madridDirectCalculator.calculate(
        armNoGravity: _armNoGravity,
        legNoGravity: _legNoGravity,
        gazeDeviation: _gazeDeviation,
        noObeyOrders: _noObeyOrders,
        noRecognizeDeficit: _noRecognizeDeficit,
        tas: _tas,
        age: _age,
      );

  void _resetCincinnati() => setState(() {
        _facialDroop = null;
        _armDrift = null;
        _speech = null;
      });

  void _resetMadridDirect() => setState(() {
        _armNoGravity = false;
        _legNoGravity = false;
        _gazeDeviation = false;
        _noObeyOrders = false;
        _noRecognizeDeficit = false;
        _tas = 140;
        _age = 65;
      });

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  const Text('Ictus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: const ToolInfoPanel(
                  sections: IctusData.infoSections,
                  references: IctusData.references,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ictus'),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Info',
              onPressed: () => _showInfo(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Cincinnati'),
              Tab(text: 'Madrid-DIRECT'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _buildCincinnati(),
              _buildMadridDirect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCincinnati() {
    final result = _cincinnatiResult;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Escala Cincinnati',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCincinnati),
          ],
        ),
        const SizedBox(height: 8),
        _buildCincinnatiItem(
          'Asimetría facial',
          Icons.face,
          'Pida al paciente que sonría',
          'Ambos lados se mueven igual',
          'Un lado no se mueve',
          _facialDroop,
          (v) => setState(() => _facialDroop = v),
        ),
        const SizedBox(height: 8),
        _buildCincinnatiItem(
          'Fuerza en brazos',
          Icons.front_hand,
          'Extienda brazos 10 segundos',
          'Ambos brazos se mueven igual',
          'Un brazo cae o no se mueve',
          _armDrift,
          (v) => setState(() => _armDrift = v),
        ),
        const SizedBox(height: 8),
        _buildCincinnatiItem(
          'Habla',
          Icons.record_voice_over,
          'Repita una frase',
          'Pronuncia correctamente',
          'Arrastra palabras o no habla',
          _speech,
          (v) => setState(() => _speech = v),
        ),
        const SizedBox(height: 16),
        if (result != null)
          Card(
            color: (result.suspectedStroke ? AppColors.severitySevere : AppColors.severityMild)
                .withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    result.suspectedStroke ? Icons.warning : Icons.check_circle,
                    size: 48,
                    color: result.suspectedStroke
                        ? AppColors.severitySevere
                        : AppColors.severityMild,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.suspectedStroke ? 'SOSPECHA DE ICTUS' : 'SIN SOSPECHA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: result.suspectedStroke
                          ? AppColors.severitySevere
                          : AppColors.severityMild,
                    ),
                  ),
                  if (result.suspectedStroke)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Activar Código Ictus\nAnotar hora de inicio de síntomas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCincinnatiItem(
    String title,
    IconData icon,
    String instruction,
    String normalText,
    String abnormalText,
    bool? value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(instruction, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _optionButton(
                  'Normal',
                  normalText,
                  value == false,
                  AppColors.severityMild,
                  () => onChanged(false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _optionButton(
                  'Anormal',
                  abnormalText,
                  value == true,
                  AppColors.severitySevere,
                  () => onChanged(true),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(
    String label,
    String description,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontWeight: FontWeight.bold, color: selected ? color : Colors.grey)),
            Text(description, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMadridDirect() {
    final result = _madridDirectResult;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Madrid-DIRECT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _resetMadridDirect),
          ],
        ),
        const Text(
          'Detección prehospitalaria de oclusión de gran vaso\n'
          '(Plan de Atención al Ictus - Comunidad de Madrid)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        // Clinical items (+1 each)
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text('Items clínicos (+1 punto cada uno)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        _buildMadridDirectItem(
          'Brazo - No vence gravedad',
          Icons.front_hand,
          'Balance muscular 0-2 (NIHSS 3-4 en este ítem)',
          _armNoGravity,
          (v) => setState(() => _armNoGravity = v),
        ),
        _buildMadridDirectItem(
          'Pierna - No vence gravedad',
          Icons.directions_walk,
          'Balance muscular 0-2 (NIHSS 3-4 en este ítem)',
          _legNoGravity,
          (v) => setState(() => _legNoGravity = v),
        ),
        _buildMadridDirectItem(
          'Desviación de la mirada',
          Icons.visibility,
          'Parcial o forzada (NIHSS 1-2 en este ítem)',
          _gazeDeviation,
          (v) => setState(() => _gazeDeviation = v),
        ),
        _buildMadridDirectItem(
          'No obedece órdenes',
          Icons.record_voice_over,
          'No obedece la mitad o más de órdenes sencillas (NIHSS 1-2)',
          _noObeyOrders,
          (v) => setState(() {
            _noObeyOrders = v;
            if (v) _noRecognizeDeficit = false; // Mutually exclusive
          }),
        ),
        _buildMadridDirectItem(
          'No reconoce déficit',
          Icons.blur_on,
          'Preguntar: "¿De quién es este brazo?" y "¿Puede mover bien los brazos?"',
          _noRecognizeDeficit,
          (v) => setState(() {
            _noRecognizeDeficit = v;
            if (v) _noObeyOrders = false; // Mutually exclusive
          }),
        ),
        const SizedBox(height: 16),
        // TAS modifier
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text('Modificadores (restan puntos)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('TAS: $_tas mmHg', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_tas >= 180)
                      Text(
                        '-${((_tas - 180) ~/ 10) + 1} pts',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                Slider(
                  value: _tas.toDouble(),
                  min: 80,
                  max: 250,
                  divisions: 34,
                  activeColor: _tas >= 180 ? Colors.orange : AppColors.primary,
                  onChanged: (v) => setState(() => _tas = v.round()),
                ),
                const Text('Restar 1 punto por cada 10 mmHg > 180',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cake, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text('Edad: $_age años', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_age >= 85)
                      Text(
                        '-${_age - 84} pts',
                        style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                Slider(
                  value: _age.toDouble(),
                  min: 18,
                  max: 100,
                  divisions: 82,
                  activeColor: _age >= 85 ? Colors.purple : AppColors.primary,
                  onChanged: (v) => setState(() => _age = v.round()),
                ),
                const Text('Restar 1 punto por cada año a partir de 85',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Result
        Card(
          color: (result.requiresThrombectomy ? AppColors.severitySevere : AppColors.severityMild)
              .withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${result.score}',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: result.requiresThrombectomy
                        ? AppColors.severitySevere
                        : AppColors.severityMild,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.requiresThrombectomy
                      ? 'TRASLADO DIRECTO A HOSPITAL CON TROMBECTOMÍA MECÁNICA'
                      : 'TRASLADO A UNIDAD DE ICTUS MÁS CERCANA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: result.requiresThrombectomy
                        ? AppColors.severitySevere
                        : AppColors.severityMild,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.requiresThrombectomy
                      ? '>=2 puntos: sospecha de oclusión de gran vaso'
                      : '<2 puntos: trasladar al hospital con UI más cercano',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                if (!result.requiresThrombectomy && _age >= 85)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Si la puntuación es <2 solo por la edad y el paciente tiene excelente situación basal, '
                      'valorar con neurólogo la posibilidad de traslado directo a TM.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMadridDirectItem(
    String title,
    IconData icon,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? AppColors.severitySevere : Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: const TextStyle(fontSize: 11)),
        value: value,
        activeThumbColor: AppColors.severitySevere,
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}
