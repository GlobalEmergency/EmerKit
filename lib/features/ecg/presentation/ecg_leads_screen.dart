import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/ecg_data.dart';

class EcgLeadsScreen extends StatelessWidget {
  const EcgLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ToolScreenBase(
        title: 'Electrodos ECG',
        infoBody: const ToolInfoPanel(
          sections: EcgData.infoSections,
          references: EcgData.references,
        ),
        toolBody: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.primary,
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Europeo'),
                  Tab(text: 'Americano (AHA)'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEuropean(),
                  _buildAmerican(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEuropean() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Código de colores europeo (IEC)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildImageCard('assets/images/ecg_pinzas.png',
            'Derivaciones de extremidades (EU)'),
        const SizedBox(height: 16),
        _buildSection('Monitor 3 derivaciones', [
          _lead('Rojo', 'Hombro derecho (RA)', Colors.red),
          _lead('Amarillo', 'Hombro izquierdo (LA)', Colors.amber),
          _lead('Verde', 'Costilla izquierda inferior (LL)', Colors.green),
        ]),
        const SizedBox(height: 16),
        _buildImageCard('assets/images/ecg_base_usa.png',
            'Colocación de electrodos precordiales'),
        const SizedBox(height: 12),
        _buildSection('ECG 12 derivaciones - Precordiales', [
          _lead('V1 (Rojo)', '4º espacio intercostal, borde esternal derecho',
              Colors.red),
          _lead('V2 (Amarillo)',
              '4º espacio intercostal, borde esternal izquierdo', Colors.amber),
          _lead('V3 (Verde)', 'Entre V2 y V4', Colors.green),
          _lead(
              'V4 (Marrón)',
              '5º espacio intercostal, línea medioclavicular izq.',
              Colors.brown),
          _lead('V5 (Negro)', 'Mismo nivel V4, línea axilar anterior',
              Colors.black),
          _lead('V6 (Violeta)', 'Mismo nivel V4-V5, línea axilar media',
              Colors.purple),
        ]),
        const SizedBox(height: 16),
        _buildImageCard(
            'assets/images/ecg_posterior.png', 'Derivaciones posteriores'),
        const SizedBox(height: 12),
        _buildSection('Derivaciones posteriores', [
          _lead('V7', 'Línea axilar posterior izquierda', Colors.blue),
          _lead('V8', 'Punta de escápula izquierda', Colors.blue),
          _lead('V9', 'Borde vertebral izquierdo', Colors.blue),
        ]),
      ],
    );
  }

  Widget _buildAmerican() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Código de colores americano (AHA)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildImageCard('assets/images/ecg_pinzas_usa.png',
            'Derivaciones de extremidades (AHA)'),
        const SizedBox(height: 16),
        _buildSection('Monitor 3 derivaciones', [
          _lead('Blanco (RA)', 'Hombro derecho', Colors.grey.shade300),
          _lead('Negro (LA)', 'Hombro izquierdo', Colors.black),
          _lead('Verde (LL)', 'Costilla izquierda inferior', Colors.green),
        ]),
        const SizedBox(height: 16),
        _buildImageCard('assets/images/ecg_base_usa.png',
            'Colocación de electrodos precordiales (AHA)'),
        const SizedBox(height: 16),
        _buildSection('Mnemotecnia', [
          const ListTile(
            dense: true,
            leading: Icon(Icons.lightbulb_outline, color: Colors.amber),
            title: Text('"White is right, smoke over fire"'),
            subtitle: Text(
              'Blanco a la derecha, Negro sobre Verde\n'
              '(humo sobre fuego)',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildImageCard(String assetPath, String caption) {
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _lead(String label, String position, Color color) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(backgroundColor: color, radius: 12),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(position, style: const TextStyle(fontSize: 12)),
    );
  }
}
