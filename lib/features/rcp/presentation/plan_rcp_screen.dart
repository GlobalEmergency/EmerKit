import 'package:flutter/material.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/theme/app_colors.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_info_panel.dart';
import 'package:navaja_suiza_sanitaria/shared/presentation/widgets/tool_screen_base.dart';

import '../domain/rcp_data.dart';

class PlanRcpScreen extends StatelessWidget {
  const PlanRcpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ToolScreenBase(
        title: 'Algoritmo SVB',
        infoBody: const ToolInfoPanel(
          sections: RcpData.infoSections,
          references: RcpData.references,
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
                  Tab(text: 'Adultos'),
                  Tab(text: 'Pediátrico'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAlgorithm(
                    'SVB Adultos (ERC 2025)',
                    [
                      const _AlgorithmStep(
                          'Seguridad',
                          'Garantizar la seguridad del reanimador y la víctima',
                          AppColors.proteccion),
                      const _AlgorithmStep(
                          '¿Responde?',
                          'Estimular: sacudir hombros y preguntar "¿Se encuentra bien?"',
                          AppColors.valoracion),
                      const _AlgorithmStep(
                          'Pedir ayuda',
                          'Gritar pidiendo ayuda\nActivar altavoz del teléfono para llamar al 112 sin dejar de actuar',
                          AppColors.comunicacion),
                      const _AlgorithmStep(
                          'Abrir vía aérea',
                          'Maniobra frente-mentón\n(Tracción mandibular si sospecha trauma)',
                          AppColors.tecnicas),
                      const _AlgorithmStep(
                          '¿Respira normalmente?',
                          'Ver, oír, sentir (máximo 10 segundos)\nGasping = NO respira\nSi duda: actuar como si no respira',
                          AppColors.valoracion),
                      const _AlgorithmStep(
                          'Llamar 112 + pedir DEA',
                          'Activar sistema de emergencias\nSolicitar DEA\nUsar función manos libres del teléfono\nSi solo hay un reanimador: iniciar RCP antes de llamar',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          '30 compresiones torácicas',
                          'Centro del pecho (mitad inferior del esternón)\nProfundidad: 5-6 cm\nFrecuencia: 100-120/min\nPermitir reexpansión torácica completa\nMinimizar interrupciones (<10s)',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          '2 ventilaciones de rescate',
                          'Insuflaciones de ~1 segundo cada una\nObservar elevación del tórax\nSi no se consigue: recolocar cabeza y reintentar\nSi no es posible ventilar: solo compresiones',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          'Continuar 30:2',
                          'No interrumpir hasta:\n- Llegada de profesionales\n- La víctima muestre signos de vida\n- Agotamiento del reanimador\n- Relevo cada 2 min si hay más reanimadores',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          'DEA',
                          'En cuanto esté disponible:\n- Encender y seguir instrucciones de voz\n- Colocar parches (esternal-apical)\n- No tocar al paciente durante análisis\n- Descarga si indicada\n- Reanudar RCP inmediatamente tras descarga\n- Continuar hasta que el DEA reanalice',
                          AppColors.soporteVital),
                    ],
                  ),
                  _buildAlgorithm(
                    'SVB Pediátrico (ERC 2025)',
                    [
                      const _AlgorithmStep('Seguridad', 'Garantizar seguridad',
                          AppColors.proteccion),
                      const _AlgorithmStep(
                          '¿Responde?',
                          'Estimular suavemente y hablar\nLactante: estimular planta del pie',
                          AppColors.valoracion),
                      const _AlgorithmStep(
                          'Pedir ayuda',
                          'Gritar pidiendo ayuda\nSi solo hay un reanimador: 1 min de RCP antes de ir a llamar',
                          AppColors.comunicacion),
                      const _AlgorithmStep(
                          'Abrir vía aérea',
                          'Maniobra frente-mentón\nPosición neutra en lactantes\nLigera extensión en niños',
                          AppColors.tecnicas),
                      const _AlgorithmStep(
                          '¿Respira normalmente?',
                          'Ver, oír, sentir (máximo 10 segundos)\nSi respira: PLS adaptada a la edad',
                          AppColors.valoracion),
                      const _AlgorithmStep(
                          '5 ventilaciones de rescate',
                          'Boca a boca-nariz en lactantes\nBoca a boca en niños\nInsuflaciones de ~1 segundo\nObservar elevación del tórax en cada insuflación',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          '¿Signos de vida?',
                          'Evaluar respuesta a ventilaciones (máx 10s)\nBuscar movimiento, tos, respiración\nProfesionales: comprobar pulso (braquial/carotídeo)',
                          AppColors.valoracion),
                      const _AlgorithmStep(
                          '15 compresiones torácicas',
                          'Lactante: 2 pulgares abrazando tórax (2 reanimadores)\no 2 dedos (1 reanimador)\nNiño: 1 o 2 manos según tamaño\nProfundidad: al menos 1/3 del tórax (4cm lactante, 5cm niño)',
                          AppColors.soporteVital),
                      const _AlgorithmStep(
                          'Continuar 15:2',
                          'Ratio 15:2 (2 reanimadores)\nRatio 30:2 (1 reanimador)\nUsar DEA en cuanto esté disponible\n(parches pediátricos si <8 años, adulto si no disponibles)',
                          AppColors.soporteVital),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithm(String title, List<_AlgorithmStep> steps) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
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
                        child: Text('${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: step.color)),
                            if (step.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(step.description,
                                  style: const TextStyle(fontSize: 13)),
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
