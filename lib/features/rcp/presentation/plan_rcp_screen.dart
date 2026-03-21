import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/screen_info_helper.dart';

class PlanRcpScreen extends StatelessWidget {
  const PlanRcpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Algoritmo SVB'),
          actions: [
            Builder(
              builder: (context) => buildInfoAction(context, 'Soporte Vital Básico', [
                buildInfoCard(
                  'Historia de la RCP',
                  'La reanimación cardiopulmonar moderna se desarrolló en la década de 1960 combinando la ventilación boca a boca (descrita por Elam y Safar) con las compresiones torácicas externas (descritas por Kouwenhoven, Jude y Knickerbocker). Desde entonces, las guías se actualizan periódicamente basándose en la evidencia científica.',
                ),
                buildInfoCard(
                  'Cadena de supervivencia',
                  'La cadena de supervivencia describe los eslabones críticos para la supervivencia de una parada cardíaca:\n\n'
                  '1. Reconocimiento precoz y pedir ayuda.\n'
                  '2. RCP precoz por testigos.\n'
                  '3. Desfibrilación precoz.\n'
                  '4. Soporte vital avanzado.\n'
                  '5. Cuidados post-resucitación.\n\n'
                  'Cada minuto sin RCP reduce la supervivencia un 7-10%.',
                ),
                buildInfoCard(
                  'Importancia de la RCP precoz',
                  'La RCP iniciada por testigos duplica o triplica la supervivencia de la parada cardíaca extrahospitalaria. Las compresiones torácicas de alta calidad (profundidad, frecuencia y mínimas interrupciones) son el factor más determinante. La combinación de RCP precoz con desfibrilación en los primeros 3-5 minutos puede alcanzar tasas de supervivencia del 50-70%.',
                ),
                buildReferencesCard([
                  'European Resuscitation Council Guidelines 2025.',
                  'Olasveengen TM, et al. European Resuscitation Council Guidelines 2025: Basic Life Support.',
                ]),
              ]),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Adultos'),
              Tab(text: 'Pediátrico'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _buildAlgorithm(
                'SVB Adultos (ERC 2025)',
              [
                _AlgorithmStep('Seguridad', 'Garantizar la seguridad del reanimador y la víctima', AppColors.proteccion),
                _AlgorithmStep('¿Responde?', 'Estimular: sacudir hombros y preguntar "¿Se encuentra bien?"', AppColors.valoracion),
                _AlgorithmStep('Pedir ayuda', 'Gritar pidiendo ayuda\nActivar altavoz del teléfono para llamar al 112 sin dejar de actuar', AppColors.comunicacion),
                _AlgorithmStep('Abrir vía aérea', 'Maniobra frente-mentón\n(Tracción mandibular si sospecha trauma)', AppColors.tecnicas),
                _AlgorithmStep('¿Respira normalmente?', 'Ver, oír, sentir (máximo 10 segundos)\nGasping = NO respira\nSi duda: actuar como si no respira', AppColors.valoracion),
                _AlgorithmStep('Llamar 112 + pedir DEA', 'Activar sistema de emergencias\nSolicitar DEA\nUsar función manos libres del teléfono\nSi solo hay un reanimador: iniciar RCP antes de llamar', AppColors.soporteVital),
                _AlgorithmStep('30 compresiones torácicas', 'Centro del pecho (mitad inferior del esternón)\nProfundidad: 5-6 cm\nFrecuencia: 100-120/min\nPermitir reexpansión torácica completa\nMinimizar interrupciones (<10s)', AppColors.soporteVital),
                _AlgorithmStep('2 ventilaciones de rescate', 'Insuflaciones de ~1 segundo cada una\nObservar elevación del tórax\nSi no se consigue: recolocar cabeza y reintentar\nSi no es posible ventilar: solo compresiones', AppColors.soporteVital),
                _AlgorithmStep('Continuar 30:2', 'No interrumpir hasta:\n- Llegada de profesionales\n- La víctima muestre signos de vida\n- Agotamiento del reanimador\n- Relevo cada 2 min si hay más reanimadores', AppColors.soporteVital),
                _AlgorithmStep('DEA', 'En cuanto esté disponible:\n- Encender y seguir instrucciones de voz\n- Colocar parches (esternal-apical)\n- No tocar al paciente durante análisis\n- Descarga si indicada\n- Reanudar RCP inmediatamente tras descarga\n- Continuar hasta que el DEA reanalice', AppColors.soporteVital),
              ],
            ),
            _buildAlgorithm(
              'SVB Pediátrico (ERC 2025)',
              [
                _AlgorithmStep('Seguridad', 'Garantizar seguridad', AppColors.proteccion),
                _AlgorithmStep('¿Responde?', 'Estimular suavemente y hablar\nLactante: estimular planta del pie', AppColors.valoracion),
                _AlgorithmStep('Pedir ayuda', 'Gritar pidiendo ayuda\nSi solo hay un reanimador: 1 min de RCP antes de ir a llamar', AppColors.comunicacion),
                _AlgorithmStep('Abrir vía aérea', 'Maniobra frente-mentón\nPosición neutra en lactantes\nLigera extensión en niños', AppColors.tecnicas),
                _AlgorithmStep('¿Respira normalmente?', 'Ver, oír, sentir (máximo 10 segundos)\nSi respira: PLS adaptada a la edad', AppColors.valoracion),
                _AlgorithmStep('5 ventilaciones de rescate', 'Boca a boca-nariz en lactantes\nBoca a boca en niños\nInsuflaciones de ~1 segundo\nObservar elevación del tórax en cada insuflación', AppColors.soporteVital),
                _AlgorithmStep('¿Signos de vida?', 'Evaluar respuesta a ventilaciones (máx 10s)\nBuscar movimiento, tos, respiración\nProfesionales: comprobar pulso (braquial/carotídeo)', AppColors.valoracion),
                _AlgorithmStep('15 compresiones torácicas', 'Lactante: 2 pulgares abrazando tórax (2 reanimadores)\no 2 dedos (1 reanimador)\nNiño: 1 o 2 manos según tamaño\nProfundidad: al menos 1/3 del tórax (4cm lactante, 5cm niño)', AppColors.soporteVital),
                _AlgorithmStep('Continuar 15:2', 'Ratio 15:2 (2 reanimadores)\nRatio 30:2 (1 reanimador)\nUsar DEA en cuanto esté disponible\n(parches pediátricos si <8 años, adulto si no disponibles)', AppColors.soporteVital),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithm(String title, List<_AlgorithmStep> steps) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          return Column(
            children: [
              Card(
                color: step.color.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: step.color,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: TextStyle(fontWeight: FontWeight.bold, color: step.color)),
                            if (step.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(step.description, style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index < steps.length - 1)
                const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
            ],
          );
        }),
      ],
    );
  }
}

class _AlgorithmStep {
  final String title;
  final String description;
  final Color color;
  const _AlgorithmStep(this.title, this.description, this.color);
}
