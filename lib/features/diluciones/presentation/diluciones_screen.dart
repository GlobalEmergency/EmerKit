import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import 'package:emerkit/shared/presentation/widgets/result_banner.dart';
import 'package:emerkit/shared/presentation/widgets/section_header.dart';
import 'package:emerkit/shared/presentation/widgets/tool_info_panel.dart';
import 'package:emerkit/shared/presentation/widgets/tool_screen_base.dart';
import '../domain/diluciones_calculator.dart';
import '../domain/diluciones_data.dart';

class DilucionesScreen extends StatefulWidget {
  const DilucionesScreen({super.key});

  @override
  State<DilucionesScreen> createState() => _DilucionesScreenState();
}

class _DilucionesScreenState extends State<DilucionesScreen> {
  static const _calculator = DilutionCalculator();
  static const _color = AppColors.tecnicas;

  // Drug vial
  final _drugAmountCtrl = TextEditingController();
  final _drugVolumeCtrl = TextEditingController();
  int? _selectedPreset;

  // Dose
  final _doseCtrl = TextEditingController();

  // Weight-based
  bool _useWeight = false;
  final _weightCtrl = TextEditingController();
  final _doseMgKgCtrl = TextEditingController();

  // Dilution (optional)
  bool _useDilution = false;
  final _finalVolumeCtrl = TextEditingController();

  // Continuous infusion
  bool _isContinuous = false;
  final _doseRateCtrl = TextEditingController();
  final _infusionHoursCtrl = TextEditingController();

  List<TextEditingController> get _allControllers => [
        _drugAmountCtrl,
        _drugVolumeCtrl,
        _doseCtrl,
        _weightCtrl,
        _doseMgKgCtrl,
        _finalVolumeCtrl,
        _doseRateCtrl,
        _infusionHoursCtrl,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  double? _parse(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  DilutionResult get _result {
    final drugAmount = _parse(_drugAmountCtrl);
    final drugVolume = _parse(_drugVolumeCtrl);

    if (drugAmount == null || drugVolume == null) {
      return const DilutionResult.empty();
    }

    // Continuous infusion (requires weight + dilution)
    if (_useWeight && _isContinuous) {
      final weight = _parse(_weightCtrl);
      final rate = _parse(_doseRateCtrl);
      final hours = _parse(_infusionHoursCtrl);
      final finalVolume = _parse(_finalVolumeCtrl);
      if (weight == null || finalVolume == null) {
        return const DilutionResult.empty();
      }
      return _calculator.calculateByWeight(
        drugAmountMg: drugAmount,
        drugVolumeMl: drugVolume,
        finalVolumeMl: finalVolume,
        weightKg: weight,
        doseMcgPerKgPerMin: rate,
        infusionHours: hours,
      );
    }

    // Calculate the desired dose
    double? desiredDose;
    if (_useWeight) {
      final weight = _parse(_weightCtrl);
      final doseMgKg = _parse(_doseMgKgCtrl);
      if (weight == null || doseMgKg == null) {
        return const DilutionResult.empty();
      }
      desiredDose = weight * doseMgKg;
    } else {
      desiredDose = _parse(_doseCtrl);
    }

    if (desiredDose == null) return const DilutionResult.empty();

    // With dilution
    if (_useDilution) {
      final finalVolume = _parse(_finalVolumeCtrl);
      if (finalVolume == null) return const DilutionResult.empty();
      final desiredConc = desiredDose / finalVolume;
      return _calculator.calculateSimple(
        drugAmountMg: drugAmount,
        drugVolumeMl: drugVolume,
        finalVolumeMl: finalVolume,
        desiredConcentrationMgMl: desiredConc,
      );
    }

    // Direct dose (no dilution)
    return _calculator.calculateDose(
      drugAmountMg: drugAmount,
      drugVolumeMl: drugVolume,
      desiredDoseMg: desiredDose,
    );
  }

  void _reset() {
    setState(() {
      for (final c in _allControllers) {
        c.clear();
      }
      _selectedPreset = null;
      _useWeight = false;
      _useDilution = false;
      _isContinuous = false;
    });
  }

  void _selectPreset(int index) {
    final preset = DilucionesData.presets[index];
    setState(() {
      _selectedPreset = index;
      _drugAmountCtrl.text = _fmtInput(preset.amountMg);
      _drugVolumeCtrl.text = _fmtInput(preset.volumeMl);
    });
  }

  String? _buildBannerSubtitle(DilutionResult r) {
    final parts = <String>[];

    // Dose info
    if (r.totalDoseMg != null) {
      parts.add('Dosis: ${_fmtResult(r.totalDoseMg!)} mg');
    }

    // Per-vial info when multiple vials
    if (r.vialsNeeded > 1) {
      final drugVolume = _parse(_drugVolumeCtrl);
      if (drugVolume != null) {
        parts.add('${_fmtResult(drugVolume)} mL/vial');
      }
    }

    // Dilution info
    if (r.diluentVolumeMl > 0) {
      parts.add('+ ${_fmtResult(r.diluentVolumeMl)} mL diluyente '
          '\u2192 ${_fmtResult(r.finalVolumeMl)} mL');
    }

    // Infusion rate
    if (r.infusionRateMlH != null) {
      parts.add('${_fmtResult(r.infusionRateMlH!)} mL/h');
    }

    return parts.isEmpty ? null : parts.join(' \u00b7 ');
  }

  String _fmtInput(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  String _fmtResult(double v) {
    if (v == v.roundToDouble() && v < 10000) return v.toInt().toString();
    if (v < 0.01) return v.toStringAsFixed(4);
    if (v < 1) return v.toStringAsFixed(3);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final hasResult = !r.isEmpty;
    final bannerColor = r.warning != null ? AppColors.severityModerate : _color;
    final showDilutionResult = hasResult && r.diluentVolumeMl > 0;

    return ToolScreenBase(
      title: 'Diluciones',
      onReset: _reset,
      resultWidget: ResultBanner(
        value: hasResult ? '${_fmtResult(r.drugVolumeMl)} mL' : '- mL',
        label: hasResult
            ? r.vialsNeeded > 1
                ? 'Extraer ${_fmtResult(r.drugVolumeMl)} mL '
                    '(${r.vialsNeeded} viales)'
                : 'Extraer ${_fmtResult(r.drugVolumeMl)} mL del vial'
            : 'Introduce los datos del farmaco',
        subtitle: hasResult ? _buildBannerSubtitle(r) : null,
        color: bannerColor,
        severityLevel: null,
      ),
      toolBody: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Section 1: Drug vial ---
          const SectionHeader(
            title: 'Medicamento disponible',
            color: _color,
          ),
          const SizedBox(height: 12),
          _buildPresetChips(),
          const SizedBox(height: 12),
          _buildDrugInputRow(),
          if (_parse(_drugAmountCtrl) != null &&
              _parse(_drugVolumeCtrl) != null) ...[
            const SizedBox(height: 4),
            _buildConcentrationHint(),
          ],
          const SizedBox(height: 24),

          // --- Section 2: Dose ---
          const SectionHeader(
            title: 'Dosis necesaria',
            color: _color,
          ),
          const SizedBox(height: 12),

          // Weight toggle
          SwitchListTile(
            title: Text(
              'Calcular por peso',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Pediatrico / dosificacion por kg'),
            value: _useWeight,
            activeTrackColor: _color,
            thumbColor: const WidgetStatePropertyAll(_color),
            onChanged: (v) => setState(() => _useWeight = v),
            dense: true,
          ),

          if (_useWeight) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _weightCtrl,
                    label: 'Peso',
                    suffix: 'kg',
                  ),
                ),
                const SizedBox(width: 12),
                if (!_isContinuous)
                  Expanded(
                    child: _buildField(
                      controller: _doseMgKgCtrl,
                      label: 'Dosis',
                      suffix: 'mg/kg',
                    ),
                  ),
              ],
            ),
            if (_useWeight &&
                _parse(_weightCtrl) != null &&
                !_isContinuous) ...[
              const SizedBox(height: 4),
              _buildWeightDoseHint(),
            ],
          ] else ...[
            const SizedBox(height: 8),
            _buildField(
              controller: _doseCtrl,
              label: 'Dosis que necesito administrar',
              suffix: 'mg',
              hint: 'Ej: 0.5, 1, 5',
            ),
          ],
          const SizedBox(height: 24),

          // --- Section 3: Dilution (optional) ---
          const SectionHeader(
            title: 'Dilucion (opcional)',
            color: _color,
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            title: Text(
              'Preparar en volumen final',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Diluir en suero para perfusion o jeringa'),
            value: _useDilution || _isContinuous,
            activeTrackColor: _color,
            thumbColor: const WidgetStatePropertyAll(_color),
            onChanged:
                _isContinuous ? null : (v) => setState(() => _useDilution = v),
            dense: true,
          ),
          if (_useDilution || _isContinuous) ...[
            const SizedBox(height: 8),
            _buildField(
              controller: _finalVolumeCtrl,
              label: 'Volumen final',
              suffix: 'mL',
              hint: 'Ej: 10, 50, 100, 250',
            ),
          ],

          if (_useWeight) ...[
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(
                'Perfusion continua',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              value: _isContinuous,
              activeTrackColor: _color,
              thumbColor: const WidgetStatePropertyAll(_color),
              onChanged: (v) => setState(() {
                _isContinuous = v;
                if (v) _useDilution = true;
              }),
              dense: true,
            ),
            if (_isContinuous) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _doseRateCtrl,
                      label: 'Ritmo',
                      suffix: 'mcg/kg/min',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _infusionHoursCtrl,
                      label: 'Duracion',
                      suffix: 'horas',
                    ),
                  ),
                ],
              ),
            ],
          ],

          // --- Section 4: Detailed results ---
          if (hasResult) ...[
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Resultado detallado',
              color: _color,
            ),
            const SizedBox(height: 8),
            _buildResultRow(
              'Volumen a extraer',
              '${_fmtResult(r.drugVolumeMl)} mL',
            ),
            if (r.vialsNeeded > 0)
              _buildResultRow(
                'Viales necesarios',
                '${r.vialsNeeded}',
              ),
            if (r.totalDoseMg != null)
              _buildResultRow(
                'Dosis total',
                '${_fmtResult(r.totalDoseMg!)} mg',
              ),
            if (showDilutionResult) ...[
              const Divider(height: 20),
              _buildResultRow(
                'Diluyente a anadir',
                '${_fmtResult(r.diluentVolumeMl)} mL',
              ),
              _buildResultRow(
                'Volumen total',
                '${_fmtResult(r.finalVolumeMl)} mL',
              ),
              _buildResultRow(
                'Concentracion final',
                '${_fmtResult(r.finalConcentrationMgMl)} mg/mL',
              ),
            ],
            if (r.infusionRateMlH != null)
              _buildResultRow(
                'Ritmo de perfusion',
                '${_fmtResult(r.infusionRateMlH!)} mL/h',
              ),
            if (r.warning != null) ...[
              const SizedBox(height: 12),
              _buildWarningCard(r.warning!),
            ],
          ],
          const SizedBox(height: 32),
        ],
      ),
      infoBody: const ToolInfoPanel(
        sections: DilucionesData.infoSections,
        references: DilucionesData.references,
      ),
    );
  }

  Widget _buildPresetChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(DilucionesData.presets.length, (i) {
          final preset = DilucionesData.presets[i];
          final selected = _selectedPreset == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(preset.name),
              selected: selected,
              selectedColor: _color,
              labelStyle: TextStyle(
                color: selected ? Colors.white : null,
                fontWeight: selected ? FontWeight.bold : null,
              ),
              onSelected: (_) => _selectPreset(i),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDrugInputRow() {
    return Row(
      children: [
        Expanded(
          child: _buildField(
            controller: _drugAmountCtrl,
            label: 'Cantidad',
            suffix: 'mg',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'en',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
          ),
        ),
        Expanded(
          child: _buildField(
            controller: _drugVolumeCtrl,
            label: 'Volumen',
            suffix: 'mL',
          ),
        ),
      ],
    );
  }

  Widget _buildConcentrationHint() {
    final amount = _parse(_drugAmountCtrl)!;
    final volume = _parse(_drugVolumeCtrl)!;
    if (volume <= 0) return const SizedBox.shrink();
    final conc = amount / volume;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        'Concentracion: ${_fmtResult(conc)} mg/mL',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildWeightDoseHint() {
    final weight = _parse(_weightCtrl);
    final doseMgKg = _parse(_doseMgKgCtrl);
    if (weight == null || doseMgKg == null) return const SizedBox.shrink();
    final totalDose = weight * doseMgKg;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        'Dosis total: ${_fmtResult(totalDose)} mg '
        '(${_fmtResult(weight)} kg x ${_fmtResult(doseMgKg)} mg/kg)',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) {
        if (controller == _drugAmountCtrl || controller == _drugVolumeCtrl) {
          if (_selectedPreset != null) {
            final preset = DilucionesData.presets[_selectedPreset!];
            final matchesAmount =
                _drugAmountCtrl.text == _fmtInput(preset.amountMg);
            final matchesVolume =
                _drugVolumeCtrl.text == _fmtInput(preset.volumeMl);
            if (!matchesAmount || !matchesVolume) {
              _selectedPreset = null;
            }
          }
        }
      },
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String message) {
    return Card(
      color: AppColors.severityModerate.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.severityModerate),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.severityModerate,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
