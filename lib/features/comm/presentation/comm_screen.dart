import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/widgets/screen_info_helper.dart';

class CommScreen extends StatelessWidget {
  const CommScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicación SBAR'),
        actions: [
          buildInfoAction(context, 'Comunicación Estructurada', [
            buildInfoCard(
              'Importancia de la comunicación estructurada',
              'Los fallos de comunicación son la causa principal de eventos adversos en la atención sanitaria. La comunicación estructurada reduce errores, mejora la transferencia de información clínica entre profesionales y garantiza que la información relevante no se omita durante los traspasos de pacientes.',
            ),
            buildInfoCard(
              'SBAR vs ISBAR',
              'SBAR (Situation, Background, Assessment, Recommendation) es la herramienta más extendida. ISBAR añade una "I" inicial de Identificación, separando la presentación del profesional y del paciente de la situación clínica. Ambas son igualmente válidas; ISBAR es especialmente útil en comunicaciones telefónicas donde la identificación inicial es esencial.',
            ),
            buildInfoCard(
              'Beneficios en emergencias',
              '- Reduce el tiempo de transmisión de información.\n'
              '- Evita omisiones de datos relevantes.\n'
              '- Facilita la toma de decisiones por parte del receptor.\n'
              '- Estandariza la comunicación entre diferentes profesionales y niveles asistenciales.\n'
              '- Mejora la seguridad del paciente en situaciones de alto estrés.',
            ),
            buildReferencesCard([
              'Leonard M, Graham S, Bonacum D. The human factor: the critical importance of effective teamwork and communication in providing safe care. BMJ Quality & Safety. 2004.',
              'WHO: Communication During Patient Hand-Overs. Patient Safety Solutions. 2007.',
            ]),
          ]),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Técnica SBAR',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Herramienta de comunicación estructurada para transmisión de información clínica',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildSbarCard(
            'S',
            'Situation (Situación)',
            'Identificación y motivo de la comunicación',
            [
              'Identificarse: nombre y rol',
              'Identificar al paciente: nombre, edad',
              'Describir brevemente el problema actual',
              'Cuándo comenzó el problema',
            ],
            Colors.blue,
            '"Soy [nombre], TES de la ambulancia [X]. Le llamo por el paciente [nombre], varón de 65 años, con dolor torácico de 30 minutos de evolución."',
          ),
          _buildSbarCard(
            'B',
            'Background (Antecedentes)',
            'Contexto clínico relevante',
            [
              'Antecedentes médicos relevantes',
              'Medicación habitual',
              'Alergias conocidas',
              'Situación previa al evento',
            ],
            Colors.green,
            '"Antecedentes de HTA y diabetes tipo 2. Medicación: Enalapril, Metformina. Sin alergias conocidas. Estaba realizando esfuerzo físico."',
          ),
          _buildSbarCard(
            'A',
            'Assessment (Evaluación)',
            'Hallazgos de la valoración actual',
            [
              'Constantes vitales',
              'Hallazgos de la exploración',
              'Estado de consciencia',
              'Impresión clínica',
            ],
            Colors.orange,
            '"TA 160/90, FC 95, FR 20, SpO₂ 96%, Glasgow 15. Dolor opresivo centrotorácico irradiado a brazo izquierdo. Sudoración. ECG: elevación ST en II, III, aVF."',
          ),
          _buildSbarCard(
            'R',
            'Recommendation (Recomendación)',
            'Qué se necesita o se solicita',
            [
              'Qué se ha hecho hasta ahora',
              'Qué se necesita',
              'Tiempo estimado de llegada',
              'Solicitar instrucciones',
            ],
            Colors.red,
            '"Se ha administrado AAS 300mg y NTG sublingual. Solicitamos activación de Código Infarto. Llegada estimada en 15 minutos. ¿Alguna instrucción adicional?"',
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSbarCard(
    String letter,
    String title,
    String subtitle,
    List<String> points,
    Color color,
    String example,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color,
                  child: Text(letter, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...points.map((p) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(p, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ejemplo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
                  const SizedBox(height: 4),
                  Text(example, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
