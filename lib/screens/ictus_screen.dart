import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class IctusScreen extends StatefulWidget {
  const IctusScreen({super.key});

  @override
  State<IctusScreen> createState() => _IctusScreenState();
}

class _IctusScreenState extends State<IctusScreen> {
  // Cincinnati
  bool? _facialDroop;
  bool? _armDrift;
  bool? _speech;

  // Madrid-DIRECT - items clínicos (1 punto cada uno)
  bool _armNoGravity = false;       // Brazo no vence gravedad
  bool _legNoGravity = false;       // Pierna no vence gravedad
  bool _gazeDeviation = false;      // Desviación de la mirada
  bool _noObeyOrders = false;       // No obedece órdenes
  bool _noRecognizeDeficit = false;  // No reconoce déficit / heminegligencia
  // Modificadores
  int _tas = 140;  // Tensión arterial sistólica
  int _age = 65;   // Edad del paciente

  int get _cincinnatiScore =>
      [_facialDroop, _armDrift, _speech].where((v) => v == true).length;

  bool get _cincinnatiComplete =>
      _facialDroop != null && _armDrift != null && _speech != null;

  int get _madridDirectScore {
    // Items clínicos: +1 cada uno (máx 5)
    int score = 0;
    if (_armNoGravity) score++;
    if (_legNoGravity) score++;
    if (_gazeDeviation) score++;
    if (_noObeyOrders) score++;
    if (_noRecognizeDeficit) score++;

    // TAS: restar 1 punto por cada 10 mmHg por encima de 180
    if (_tas >= 180) {
      score -= ((_tas - 180) ~/ 10) + 1;
    }

    // Edad: restar 1 punto por cada año a partir de 85
    if (_age >= 85) {
      score -= (_age - 84);
    }

    return score;
  }

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ictus'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Escala Cincinnati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCincinnati),
          ],
        ),
        const SizedBox(height: 8),
        _buildCincinnatiItem('Asimetría facial', Icons.face,
            'Pida al paciente que sonría', 'Ambos lados se mueven igual', 'Un lado no se mueve', _facialDroop, (v) => setState(() => _facialDroop = v)),
        const SizedBox(height: 8),
        _buildCincinnatiItem('Fuerza en brazos', Icons.front_hand,
            'Extienda brazos 10 segundos', 'Ambos brazos se mueven igual', 'Un brazo cae o no se mueve', _armDrift, (v) => setState(() => _armDrift = v)),
        const SizedBox(height: 8),
        _buildCincinnatiItem('Habla', Icons.record_voice_over,
            'Repita una frase', 'Pronuncia correctamente', 'Arrastra palabras o no habla', _speech, (v) => setState(() => _speech = v)),
        const SizedBox(height: 16),
        if (_cincinnatiComplete)
          Card(
            color: (_cincinnatiScore > 0 ? AppColors.severitySevere : AppColors.severityMild).withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(_cincinnatiScore > 0 ? Icons.warning : Icons.check_circle, size: 48,
                      color: _cincinnatiScore > 0 ? AppColors.severitySevere : AppColors.severityMild),
                  const SizedBox(height: 12),
                  Text(
                    _cincinnatiScore > 0 ? 'SOSPECHA DE ICTUS' : 'SIN SOSPECHA',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: _cincinnatiScore > 0 ? AppColors.severitySevere : AppColors.severityMild),
                  ),
                  if (_cincinnatiScore > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Activar Código Ictus\nAnotar hora de inicio de síntomas',
                          textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCincinnatiItem(String title, IconData icon, String instruction,
      String normalText, String abnormalText, bool? value, ValueChanged<bool> onChanged) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 4),
            Text(instruction, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _optionButton('Normal', normalText, value == false, AppColors.severityMild, () => onChanged(false))),
              const SizedBox(width: 8),
              Expanded(child: _optionButton('Anormal', abnormalText, value == true, AppColors.severitySevere, () => onChanged(true))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(String label, String description, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? color : Colors.grey)),
            Text(description, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMadridDirect() {
    final score = _madridDirectScore;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text('Madrid-DIRECT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _resetMadridDirect),
          ],
        ),
        const Text('Detección prehospitalaria de oclusión de gran vaso\n(Plan de Atención al Ictus - Comunidad de Madrid)',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),

        // Items clínicos (+1 punto cada uno)
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text('Items clínicos (+1 punto cada uno)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        _buildMadridDirectItem('Brazo - No vence gravedad', Icons.front_hand,
            'Balance muscular 0-2 (NIHSS 3-4 en este ítem)', _armNoGravity, (v) => setState(() => _armNoGravity = v)),
        _buildMadridDirectItem('Pierna - No vence gravedad', Icons.directions_walk,
            'Balance muscular 0-2 (NIHSS 3-4 en este ítem)', _legNoGravity, (v) => setState(() => _legNoGravity = v)),
        _buildMadridDirectItem('Desviación de la mirada', Icons.visibility,
            'Parcial o forzada (NIHSS 1-2 en este ítem)', _gazeDeviation, (v) => setState(() => _gazeDeviation = v)),
        _buildMadridDirectItem('No obedece órdenes', Icons.record_voice_over,
            'No obedece la mitad o más de órdenes sencillas (NIHSS 1-2)', _noObeyOrders, (v) => setState(() {
              _noObeyOrders = v;
              if (v) _noRecognizeDeficit = false; // Mutuamente excluyentes
            })),
        _buildMadridDirectItem('No reconoce déficit', Icons.blur_on,
            'Preguntar: "¿De quién es este brazo?" y "¿Puede mover bien los brazos?"', _noRecognizeDeficit, (v) => setState(() {
              _noRecognizeDeficit = v;
              if (v) _noObeyOrders = false; // Mutuamente excluyentes
            })),

        if (_noObeyOrders && _noRecognizeDeficit)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Nota: "No obedece órdenes" y "No reconoce déficit" son mutuamente excluyentes',
                style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic)),
          ),

        const SizedBox(height: 16),
        // TAS modifier
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text('Modificadores (restan puntos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    if (_tas >= 180) Text('-${((_tas - 180) ~/ 10) + 1} pts',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
                    if (_age >= 85) Text('-${_age - 84} pts',
                        style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
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
          color: (score >= 2 ? AppColors.severitySevere : AppColors.severityMild).withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('$score', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold,
                    color: score >= 2 ? AppColors.severitySevere : AppColors.severityMild)),
                const SizedBox(height: 8),
                Text(
                  score >= 2
                      ? 'TRASLADO DIRECTO A HOSPITAL CON TROMBECTOMÍA MECÁNICA'
                      : 'TRASLADO A UNIDAD DE ICTUS MÁS CERCANA',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: score >= 2 ? AppColors.severitySevere : AppColors.severityMild),
                ),
                const SizedBox(height: 8),
                Text(
                  score >= 2
                      ? '≥2 puntos: sospecha de oclusión de gran vaso'
                      : '<2 puntos: trasladar al hospital con UI más cercano',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                if (score < 2 && _age >= 85)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Si la puntuación es <2 solo por la edad y el paciente tiene excelente situación basal, '
                      'valorar con neurólogo la posibilidad de traslado directo a TM.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMadridDirectItem(String title, IconData icon, String description, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? AppColors.severitySevere : Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: const TextStyle(fontSize: 11)),
        value: value,
        activeColor: AppColors.severitySevere,
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}
