import 'package:flutter/material.dart';
import 'package:emerkit/shared/presentation/widgets/screen_info_helper.dart';

class EcgLeadsScreen extends StatelessWidget {
  const EcgLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Electrodos ECG'),
          actions: [
            Builder(
              builder: (context) => buildInfoAction(context, 'Electrodos ECG', [
                buildInfoCard(
                  'Importancia de la colocación',
                  'La correcta colocación de los electrodos es fundamental para obtener un trazado ECG fiable. Una colocación incorrecta puede simular patologías inexistentes (como infartos o bloqueos) o enmascarar alteraciones reales, llevando a diagnósticos erróneos y tratamientos inadecuados.',
                ),
                buildInfoCard(
                  'Errores comunes',
                  '- Inversión de electrodos de miembros: genera trazados confusos.\n'
                      '- Colocación de V1-V2 demasiado altas: simula patología (patrón Brugada).\n'
                      '- Electrodos sobre hueso o músculo: artefactos y bajo voltaje.\n'
                      '- Piel húmeda o vellosa: mala adherencia y artefactos.\n'
                      '- Cables mal conectados: derivaciones intercambiadas.',
                ),
                buildInfoCard(
                  'Sistema Europeo (IEC) vs Americano (AHA)',
                  'Existen dos sistemas de codificación por colores para los electrodos de ECG. El sistema europeo (IEC) utiliza los colores rojo, amarillo, verde y negro, mientras que el americano (AHA) utiliza blanco, negro, verde y rojo. Es esencial conocer ambos sistemas para evitar errores en la colocación.',
                ),
                buildReferencesCard([
                  'AHA/ACC Guidelines for Electrocardiography. Circulation. 2007.',
                  'IEC 60601 Medical Electrical Equipment Standards.',
                ]),
              ]),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Europeo'),
              Tab(text: 'Americano (AHA)'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _buildEuropean(context),
              _buildAmerican(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEuropean(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Código de colores europeo (IEC)',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildImageCard(context, 'assets/images/ecg_pinzas.png',
            'Derivaciones de extremidades (EU)'),
        const SizedBox(height: 16),
        _buildSection(context, 'Monitor 3 derivaciones', [
          _lead(context, 'Rojo', 'Hombro derecho (RA)', Colors.red),
          _lead(context, 'Amarillo', 'Hombro izquierdo (LA)', Colors.amber),
          _lead(context, 'Verde', 'Costilla izquierda inferior (LL)',
              Colors.green),
        ]),
        const SizedBox(height: 16),
        _buildImageCard(context, 'assets/images/ecg_base_usa.png',
            'Colocación de electrodos precordiales'),
        const SizedBox(height: 12),
        _buildSection(context, 'ECG 12 derivaciones - Precordiales', [
          _lead(context, 'V1 (Rojo)',
              '4º espacio intercostal, borde esternal derecho', Colors.red),
          _lead(context, 'V2 (Amarillo)',
              '4º espacio intercostal, borde esternal izquierdo', Colors.amber),
          _lead(context, 'V3 (Verde)', 'Entre V2 y V4', Colors.green),
          _lead(
              context,
              'V4 (Marrón)',
              '5º espacio intercostal, línea medioclavicular izq.',
              Colors.brown),
          _lead(context, 'V5 (Negro)', 'Mismo nivel V4, línea axilar anterior',
              Colors.black),
          _lead(context, 'V6 (Violeta)',
              'Mismo nivel V4-V5, línea axilar media', Colors.purple),
        ]),
        const SizedBox(height: 16),
        _buildImageCard(context, 'assets/images/ecg_posterior.png',
            'Derivaciones posteriores'),
        const SizedBox(height: 12),
        _buildSection(context, 'Derivaciones posteriores', [
          _lead(context, 'V7', 'Línea axilar posterior izquierda', Colors.blue),
          _lead(context, 'V8', 'Punta de escápula izquierda', Colors.blue),
          _lead(context, 'V9', 'Borde vertebral izquierdo', Colors.blue),
        ]),
      ],
    );
  }

  Widget _buildAmerican(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Código de colores americano (AHA)',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildImageCard(context, 'assets/images/ecg_pinzas_usa.png',
            'Derivaciones de extremidades (AHA)'),
        const SizedBox(height: 16),
        _buildSection(context, 'Monitor 3 derivaciones', [
          _lead(context, 'Blanco (RA)', 'Hombro derecho', Colors.grey.shade300),
          _lead(context, 'Negro (LA)', 'Hombro izquierdo', Colors.black),
          _lead(context, 'Verde (LL)', 'Costilla izquierda inferior',
              Colors.green),
        ]),
        const SizedBox(height: 16),
        _buildImageCard(context, 'assets/images/ecg_base_usa.png',
            'Colocación de electrodos precordiales (AHA)'),
        const SizedBox(height: 16),
        _buildSection(context, 'Mnemotecnia', [
          ListTile(
            dense: true,
            leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            title: const Text('"White is right, smoke over fire"'),
            subtitle: Text(
              'Blanco a la derecha, Negro sobre Verde\n'
              '(humo sobre fuego)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildImageCard(
      BuildContext context, String assetPath, String caption) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              assetPath,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              caption,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _lead(
      BuildContext context, String label, String position, Color color) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(backgroundColor: color, radius: 12),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(position, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
