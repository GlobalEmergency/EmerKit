import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emerkit/shared/presentation/widgets/screen_info_helper.dart';
import 'package:emerkit/shared/presentation/theme/app_colors.dart';
import '../domain/gps_converter_calculator.dart';
import '../domain/gps_converter_data.dart';
import 'coordinate_format_card.dart';

class GpsConverterScreen extends StatefulWidget {
  const GpsConverterScreen({super.key});

  @override
  State<GpsConverterScreen> createState() => _GpsConverterScreenState();
}

class _GpsConverterScreenState extends State<GpsConverterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _inputController = TextEditingController();

  Coordinate? _currentCoordinate;
  CoordinateFormats? _currentFormats;
  String? _address;
  Position? _position;
  bool _loading = false;
  String? _error;

  // Converter tab
  Coordinate? _convertedCoordinate;
  CoordinateFormats? _convertedFormats;
  String? _convertError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Check service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Los servicios de ubicacion estan desactivados.';
          _loading = false;
        });
        return;
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permiso de ubicacion denegado.';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permiso de ubicacion denegado permanentemente. '
              'Activalo en Ajustes.';
          _loading = false;
        });
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final coord = Coordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Reverse geocoding
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.street,
            if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
            p.locality,
            p.administrativeArea,
            p.country,
          ].where((s) => s != null && s.isNotEmpty);
          address = parts.join(', ');
        }
      } catch (_) {
        // Geocoding can fail silently — coordinates are still valid
      }

      setState(() {
        _currentCoordinate = coord;
        _currentFormats = coord.toAllFormats();
        _address = address;
        _position = position;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al obtener ubicacion: $e';
        _loading = false;
      });
    }
  }

  void _convertInput() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _convertedCoordinate = null;
        _convertedFormats = null;
        _convertError = null;
      });
      return;
    }

    final coord = CoordinateParser.parse(input);
    if (coord == null) {
      setState(() {
        _convertedCoordinate = null;
        _convertedFormats = null;
        _convertError = 'No se pudo interpretar el formato. '
            'Prueba: 40.524722, -3.891667';
      });
      return;
    }

    setState(() {
      _convertedCoordinate = coord;
      _convertedFormats = coord.toAllFormats();
      _convertError = null;
    });
  }

  Future<void> _navigateTo(Coordinate coord) async {
    // Try geo: URI first (works with most map apps)
    final geoUri = Uri.parse(coord.toNavigationUri());
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to Google Maps URL
    final mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${coord.latitude},${coord.longitude}',
    );
    await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Convertidor'),
        actions: [
          buildInfoAction(
            context,
            'GPS Convertidor',
            [
              ...GpsConverterData.infoSections.entries.map(
                (e) => buildInfoCard(e.key, e.value),
              ),
              buildReferencesCard(
                GpsConverterData.references.map((r) => r.citation).toList(),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.my_location), text: 'Mi ubicacion'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'Convertidor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocationTab(),
          _buildConverterTab(),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Get location button
        FilledButton.icon(
          onPressed: _loading ? null : _getLocation,
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.my_location),
          label: Text(_loading ? 'Obteniendo...' : 'Obtener mi ubicacion'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppColors.utilidades,
          ),
        ),
        const SizedBox(height: 16),

        // Error
        if (_error != null)
          Card(
            color: AppColors.severitySevere.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.severitySevere),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style:
                            const TextStyle(color: AppColors.severitySevere)),
                  ),
                ],
              ),
            ),
          ),

        // Results
        if (_currentFormats != null) ...[
          CoordinateFormatCard(
            label: 'DD.dddddd° (Decimal)',
            value: _currentFormats!.decimal,
            icon: Icons.pin_drop,
          ),
          CoordinateFormatCard(
            label: 'DD° MM.mmmm\' (Grados + Minutos)',
            value: _currentFormats!.degreesMinutes,
            icon: Icons.straighten,
          ),
          CoordinateFormatCard(
            label: 'DD° MM\' SS.ss" (Grados, Minutos, Segundos)',
            value: _currentFormats!.degreesMinutesSeconds,
            icon: Icons.grid_on,
          ),
          CoordinateFormatCard(
            label: 'UTM',
            value: _currentFormats!.utm.toString(),
            icon: Icons.map,
          ),
          CoordinateFormatCard(
            label: 'MGRS',
            value: _currentFormats!.mgrs,
            icon: Icons.military_tech,
          ),
          if (_address != null && _address!.isNotEmpty)
            CoordinateFormatCard(
              label: 'Direccion',
              value: _address!,
              icon: Icons.location_city,
            ),
          if (_position != null) ...[
            const SizedBox(height: 12),
            _buildPositionDetails(),
          ],
          const SizedBox(height: 16),
          // Navigate button
          OutlinedButton.icon(
            onPressed: () => _navigateTo(_currentCoordinate!),
            icon: const Icon(Icons.navigation),
            label: const Text('Navegar a esta ubicacion'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.utilidades,
            ),
          ),
        ],

        if (_currentFormats == null && _error == null && !_loading)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                const Icon(Icons.explore, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Pulsa el boton para obtener\ntu ubicacion actual',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPositionDetails() {
    final p = _position!;
    final ts = p.timestamp;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
    final dateStr =
        '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.satellite_alt,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Detalles tecnicos',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _detailRow(
                Icons.height, 'Altitud', '${p.altitude.toStringAsFixed(1)} m'),
            _detailRow(Icons.gps_fixed, 'Precision horizontal',
                '\u00b1 ${p.accuracy.toStringAsFixed(1)} m'),
            _detailRow(Icons.terrain, 'Precision altitud',
                '\u00b1 ${p.altitudeAccuracy.toStringAsFixed(1)} m'),
            _detailRow(Icons.speed, 'Velocidad',
                '${p.speed.toStringAsFixed(1)} m/s (${(p.speed * 3.6).toStringAsFixed(1)} km/h)'),
            _detailRow(Icons.speed, 'Precision velocidad',
                '\u00b1 ${p.speedAccuracy.toStringAsFixed(1)} m/s'),
            _detailRow(
                Icons.explore, 'Rumbo', '${p.heading.toStringAsFixed(1)}°'),
            _detailRow(Icons.compass_calibration, 'Precision rumbo',
                '\u00b1 ${p.headingAccuracy.toStringAsFixed(1)}°'),
            _detailRow(Icons.schedule, 'Hora GPS', '$timeStr  $dateStr'),
            if (p.isMocked)
              _detailRow(Icons.warning_amber, 'Simulado', 'Si (ubicacion mock)',
                  highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: highlight
                  ? AppColors.severityModerate
                  : Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: highlight
                        ? AppColors.severityModerate
                        : Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: highlight ? AppColors.severityModerate : null)),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Input field
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: 'Coordenadas',
            hintText: 'Ej: 40.524722, -3.891667',
            prefixIcon: const Icon(Icons.edit_location_alt),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_inputController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _inputController.clear();
                      _convertInput();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Convertir',
                  onPressed: _convertInput,
                ),
              ],
            ),
            border: const OutlineInputBorder(),
            helperText: 'Acepta DD, DM, DMS, UTM y MGRS',
            helperMaxLines: 2,
          ),
          onSubmitted: (_) => _convertInput(),
          maxLines: 2,
          minLines: 1,
        ),
        const SizedBox(height: 8),

        // Convert button
        FilledButton.icon(
          onPressed: _convertInput,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Convertir'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            backgroundColor: AppColors.utilidades,
          ),
        ),
        const SizedBox(height: 16),

        // Error
        if (_convertError != null)
          Card(
            color: AppColors.severityModerate.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppColors.severityModerate),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_convertError!)),
                ],
              ),
            ),
          ),

        // Converted results
        if (_convertedFormats != null) ...[
          CoordinateFormatCard(
            label: 'DD.dddddd° (Decimal)',
            value: _convertedFormats!.decimal,
            icon: Icons.pin_drop,
          ),
          CoordinateFormatCard(
            label: 'DD° MM.mmmm\' (Grados + Minutos)',
            value: _convertedFormats!.degreesMinutes,
            icon: Icons.straighten,
          ),
          CoordinateFormatCard(
            label: 'DD° MM\' SS.ss" (Grados, Minutos, Segundos)',
            value: _convertedFormats!.degreesMinutesSeconds,
            icon: Icons.grid_on,
          ),
          CoordinateFormatCard(
            label: 'UTM',
            value: _convertedFormats!.utm.toString(),
            icon: Icons.map,
          ),
          CoordinateFormatCard(
            label: 'MGRS',
            value: _convertedFormats!.mgrs,
            icon: Icons.military_tech,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _navigateTo(_convertedCoordinate!),
            icon: const Icon(Icons.navigation),
            label: const Text('Navegar a estas coordenadas'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.utilidades,
            ),
          ),
        ],

        if (_convertedFormats == null && _convertError == null)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                const Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Introduce coordenadas en cualquier\n'
                  'formato para convertirlas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
