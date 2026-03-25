import 'dart:math';

/// Coordenada en grados decimales (DD).
class Coordinate {
  final double latitude;
  final double longitude;

  const Coordinate({required this.latitude, required this.longitude});

  /// Genera todos los formatos de representacion.
  CoordinateFormats toAllFormats() {
    return CoordinateFormats(
      decimal: _toDecimalString(),
      degreesMinutes: _toDegreesMinutes(),
      degreesMinutesSeconds: _toDMS(),
      utm: toUtm(),
      mgrs: toMgrs(),
    );
  }

  /// DD.dddddd (e.g., 40.524722, -3.891667)
  String _toDecimalString() {
    return '${latitude.toStringAsFixed(6)}°, ${longitude.toStringAsFixed(6)}°';
  }

  /// DD° MM.mmmm' (e.g., 40° 31.4833', -3° 53.5000')
  String _toDegreesMinutes() {
    final lat = _ddToDm(latitude);
    final lng = _ddToDm(longitude);
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${lat.degrees}° ${lat.minutes.toStringAsFixed(4)}\' $latDir, '
        '${lng.degrees}° ${lng.minutes.toStringAsFixed(4)}\' $lngDir';
  }

  /// DD° MM' SS.ss" (e.g., 40° 31' 29.00" N, 3° 53' 30.00" W)
  String _toDMS() {
    final lat = ddToDms(latitude);
    final lng = ddToDms(longitude);
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${lat.degrees}° ${lat.minutes}\' ${lat.seconds.toStringAsFixed(2)}" $latDir, '
        '${lng.degrees}° ${lng.minutes}\' ${lng.seconds.toStringAsFixed(2)}" $lngDir';
  }

  /// Convierte a UTM.
  UtmCoordinate toUtm() {
    return _latLngToUtm(latitude, longitude);
  }

  /// Convierte a MGRS.
  String toMgrs() {
    final utm = toUtm();
    return _utmToMgrs(utm);
  }

  /// Genera URI para navegacion (geo: intent).
  String toNavigationUri() {
    return 'geo:$latitude,$longitude';
  }

  /// Genera URI para Google Maps navigation.
  String toGoogleMapsUri() {
    return 'google.navigation:q=$latitude,$longitude';
  }

  // -- Helpers de conversion --

  static _DM _ddToDm(double dd) {
    final abs = dd.abs();
    final degrees = abs.truncate();
    final minutes = (abs - degrees) * 60;
    return _DM(degrees, minutes);
  }

  static DMS ddToDms(double dd) {
    final abs = dd.abs();
    final degrees = abs.truncate();
    final minutesDecimal = (abs - degrees) * 60;
    final minutes = minutesDecimal.truncate();
    final seconds = (minutesDecimal - minutes) * 60;
    return DMS(degrees, minutes, seconds);
  }

  static double dmsToDecimal(int degrees, int minutes, double seconds,
      {bool negative = false}) {
    final dd = degrees + minutes / 60 + seconds / 3600;
    return negative ? -dd : dd;
  }

  static double dmToDecimal(int degrees, double minutes,
      {bool negative = false}) {
    final dd = degrees + minutes / 60;
    return negative ? -dd : dd;
  }
}

class _DM {
  final int degrees;
  final double minutes;
  _DM(this.degrees, this.minutes);
}

/// Grados, Minutos, Segundos.
class DMS {
  final int degrees;
  final int minutes;
  final double seconds;
  const DMS(this.degrees, this.minutes, this.seconds);
}

/// Todos los formatos de coordenadas.
class CoordinateFormats {
  final String decimal;
  final String degreesMinutes;
  final String degreesMinutesSeconds;
  final UtmCoordinate utm;
  final String mgrs;

  const CoordinateFormats({
    required this.decimal,
    required this.degreesMinutes,
    required this.degreesMinutesSeconds,
    required this.utm,
    required this.mgrs,
  });
}

/// Coordenada UTM.
class UtmCoordinate {
  final int zone;
  final String band;
  final double easting;
  final double northing;

  const UtmCoordinate({
    required this.zone,
    required this.band,
    required this.easting,
    required this.northing,
  });

  @override
  String toString() {
    return '$zone$band ${easting.round()}E ${northing.round()}N';
  }
}

// ===========================================================================
// UTM conversion (WGS84 ellipsoid)
// ===========================================================================

const double _a = 6378137.0; // semi-major axis WGS84
const double _e2 = 0.00669437999014; // e^2
const double _k0 = 0.9996; // scale factor

UtmCoordinate _latLngToUtm(double lat, double lng) {
  final latRad = lat * pi / 180;
  final zone = ((lng + 180) / 6).floor() + 1;
  final centralMeridian = (zone - 1) * 6 - 180 + 3;

  final n = _a / sqrt(1 - _e2 * sin(latRad) * sin(latRad));
  final t = tan(latRad) * tan(latRad);
  final c = _e2 / (1 - _e2) * cos(latRad) * cos(latRad);
  final a2 = (lng - centralMeridian) * pi / 180 * cos(latRad);

  final m = _a *
      ((1 - _e2 / 4 - 3 * _e2 * _e2 / 64 - 5 * _e2 * _e2 * _e2 / 256) * latRad -
          (3 * _e2 / 8 + 3 * _e2 * _e2 / 32 + 45 * _e2 * _e2 * _e2 / 1024) *
              sin(2 * latRad) +
          (15 * _e2 * _e2 / 256 + 45 * _e2 * _e2 * _e2 / 1024) *
              sin(4 * latRad) -
          (35 * _e2 * _e2 * _e2 / 3072) * sin(6 * latRad));

  var easting = _k0 *
          n *
          (a2 +
              (1 - t + c) * a2 * a2 * a2 / 6 +
              (5 - 18 * t + t * t + 72 * c - 58 * _e2 / (1 - _e2)) *
                  a2 *
                  a2 *
                  a2 *
                  a2 *
                  a2 /
                  120) +
      500000.0;

  var northing = _k0 *
      (m +
          n *
              tan(latRad) *
              (a2 * a2 / 2 +
                  (5 - t + 9 * c + 4 * c * c) * a2 * a2 * a2 * a2 / 24 +
                  (61 - 58 * t + t * t + 600 * c - 330 * _e2 / (1 - _e2)) *
                      a2 *
                      a2 *
                      a2 *
                      a2 *
                      a2 *
                      a2 /
                      720));

  if (lat < 0) {
    northing += 10000000.0;
  }

  final band = _utmBandLetter(lat);

  return UtmCoordinate(
    zone: zone,
    band: band,
    easting: easting,
    northing: northing,
  );
}

String _utmBandLetter(double lat) {
  const bands = 'CDEFGHJKLMNPQRSTUVWX';
  if (lat < -80 || lat > 84) return 'Z';
  final index = ((lat + 80) / 8).floor();
  return bands[index.clamp(0, bands.length - 1)];
}

// ===========================================================================
// MGRS conversion (from UTM)
// ===========================================================================

String _utmToMgrs(UtmCoordinate utm) {
  const colLetters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const rowLetters = 'ABCDEFGHJKLMNPQRSTUV';

  // Column letter (easting)
  final colIndex = ((utm.easting / 100000).floor() - 1) % colLetters.length;
  final setNumber = (utm.zone - 1) % 6;
  final adjustedCol = (colIndex + setNumber * 8) % colLetters.length;
  final colLetter = colLetters[adjustedCol];

  // Row letter (northing)
  final rowIndex = (utm.northing / 100000).floor() % rowLetters.length;
  final rowOffset = (setNumber % 2 == 0) ? 0 : 5;
  final adjustedRow = (rowIndex + rowOffset) % rowLetters.length;
  final rowLetter = rowLetters[adjustedRow];

  // 5-digit easting and northing within 100km square
  final e5 = (utm.easting % 100000).round().toString().padLeft(5, '0');
  final n5 = (utm.northing % 100000).round().toString().padLeft(5, '0');

  return '${utm.zone}${utm.band} $colLetter$rowLetter $e5 $n5';
}

// ===========================================================================
// Reverse UTM to Lat/Lng conversion
// ===========================================================================

Coordinate? _utmToLatLng(
    int zone, String band, double easting, double northing) {
  final isSouth = band.compareTo('N') < 0;

  // Remove false easting/northing
  final x = easting - 500000.0;
  var y = northing;
  if (isSouth) y -= 10000000.0;

  final m = y / _k0;
  final mu =
      m / (_a * (1 - _e2 / 4 - 3 * _e2 * _e2 / 64 - 5 * _e2 * _e2 * _e2 / 256));

  final e1 = (1 - sqrt(1 - _e2)) / (1 + sqrt(1 - _e2));

  final phi1 = mu +
      (3 * e1 / 2 - 27 * e1 * e1 * e1 / 32) * sin(2 * mu) +
      (21 * e1 * e1 / 16 - 55 * e1 * e1 * e1 * e1 / 32) * sin(4 * mu) +
      (151 * e1 * e1 * e1 / 96) * sin(6 * mu);

  final n1 = _a / sqrt(1 - _e2 * sin(phi1) * sin(phi1));
  final t1 = tan(phi1) * tan(phi1);
  final c1 = _e2 / (1 - _e2) * cos(phi1) * cos(phi1);
  final r1 = _a * (1 - _e2) / pow(1 - _e2 * sin(phi1) * sin(phi1), 1.5);
  final d = x / (n1 * _k0);

  var lat = phi1 -
      (n1 * tan(phi1) / r1) *
          (d * d / 2 -
              (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * _e2 / (1 - _e2)) *
                  d *
                  d *
                  d *
                  d /
                  24 +
              (61 +
                      90 * t1 +
                      298 * c1 +
                      45 * t1 * t1 -
                      252 * _e2 / (1 - _e2) -
                      3 * c1 * c1) *
                  d *
                  d *
                  d *
                  d *
                  d *
                  d /
                  720);

  final centralMeridian = ((zone - 1) * 6 - 180 + 3).toDouble();
  final lngRad = (d -
          (1 + 2 * t1 + c1) * d * d * d / 6 +
          (5 -
                  2 * c1 +
                  28 * t1 -
                  3 * c1 * c1 +
                  8 * _e2 / (1 - _e2) +
                  24 * t1 * t1) *
              d *
              d *
              d *
              d *
              d /
              120) /
      cos(phi1);

  lat = lat * 180 / pi;
  var lng = centralMeridian + lngRad * 180 / pi;

  if (lat.abs() > 90 || lng.abs() > 180) return null;
  return Coordinate(latitude: lat, longitude: lng);
}

// ===========================================================================
// Coordinate parser — parses any format to Coordinate
// ===========================================================================

class CoordinateParser {
  /// Intenta parsear un string de coordenadas en cualquier formato comun.
  /// Retorna null si no puede parsear.
  static Coordinate? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Try DD.ddddd format (e.g., "40.524722, -3.891667" or "40.524722 -3.891667")
    final dd = _tryParseDecimal(trimmed);
    if (dd != null) return dd;

    // Try DMS format (e.g., "40° 31' 29.00\" N, 3° 53' 30.00\" W")
    final dms = _tryParseDms(trimmed);
    if (dms != null) return dms;

    // Try DM format (e.g., "40° 31.4833' N, 3° 53.5000' W")
    final dm = _tryParseDm(trimmed);
    if (dm != null) return dm;

    // Try UTM format (e.g., "30T 424472E 4486380N" or "30T 424472 4486380")
    final utm = _tryParseUtm(trimmed);
    if (utm != null) return utm;

    // Try MGRS format (e.g., "30T VK 24472 86380")
    final mgrs = _tryParseMgrs(trimmed);
    if (mgrs != null) return mgrs;

    return null;
  }

  static Coordinate? _tryParseDecimal(String input) {
    // Remove degree symbols
    final cleaned = input.replaceAll('°', '').replaceAll(',', ' ');
    final parts =
        cleaned.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;

    return Coordinate(latitude: lat, longitude: lng);
  }

  static final _dmsRegex = RegExp(
    '(\\d+)[\\u00b0\\s]+(\\d+)[\\u0027\\u2032\\s]+(\\d+(?:\\.\\d+)?)[\\u0022\\u2033\\s]*([NSns])[\\s,]+(\\d+)[\\u00b0\\s]+(\\d+)[\\u0027\\u2032\\s]+(\\d+(?:\\.\\d+)?)[\\u0022\\u2033\\s]*([EWew])',
  );

  static Coordinate? _tryParseDms(String input) {
    final match = _dmsRegex.firstMatch(input);
    if (match == null) return null;

    final latDeg = int.parse(match.group(1)!);
    final latMin = int.parse(match.group(2)!);
    final latSec = double.parse(match.group(3)!);
    final latDir = match.group(4)!.toUpperCase();

    final lngDeg = int.parse(match.group(5)!);
    final lngMin = int.parse(match.group(6)!);
    final lngSec = double.parse(match.group(7)!);
    final lngDir = match.group(8)!.toUpperCase();

    final lat = Coordinate.dmsToDecimal(latDeg, latMin, latSec,
        negative: latDir == 'S');
    final lng = Coordinate.dmsToDecimal(lngDeg, lngMin, lngSec,
        negative: lngDir == 'W');

    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return Coordinate(latitude: lat, longitude: lng);
  }

  static final _dmRegex = RegExp(
    '(\\d+)[\\u00b0\\s]+(\\d+(?:\\.\\d+)?)[\\u0027\\u2032\\s]*([NSns])[\\s,]+(\\d+)[\\u00b0\\s]+(\\d+(?:\\.\\d+)?)[\\u0027\\u2032\\s]*([EWew])',
  );

  static Coordinate? _tryParseDm(String input) {
    final match = _dmRegex.firstMatch(input);
    if (match == null) return null;

    final latDeg = int.parse(match.group(1)!);
    final latMin = double.parse(match.group(2)!);
    final latDir = match.group(3)!.toUpperCase();

    final lngDeg = int.parse(match.group(4)!);
    final lngMin = double.parse(match.group(5)!);
    final lngDir = match.group(6)!.toUpperCase();

    final lat = Coordinate.dmToDecimal(latDeg, latMin, negative: latDir == 'S');
    final lng = Coordinate.dmToDecimal(lngDeg, lngMin, negative: lngDir == 'W');

    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return Coordinate(latitude: lat, longitude: lng);
  }

  // UTM: "30T 424472E 4486380N" or "30T 424472 4486380"
  static final _utmRegex = RegExp(
    r'(\d{1,2})\s*([C-HJ-NP-X])\s+(\d+(?:\.\d+)?)\s*[Ee]?\s+(\d+(?:\.\d+)?)\s*[Nn]?',
    caseSensitive: false,
  );

  static Coordinate? _tryParseUtm(String input) {
    final match = _utmRegex.firstMatch(input);
    if (match == null) return null;

    final zone = int.parse(match.group(1)!);
    final band = match.group(2)!.toUpperCase();
    final easting = double.parse(match.group(3)!);
    final northing = double.parse(match.group(4)!);

    if (zone < 1 || zone > 60) return null;
    if (easting < 100000 || easting > 999999) return null;
    if (northing < 0 || northing > 10000000) return null;

    return _utmToLatLng(zone, band, easting, northing);
  }

  // MGRS: "30T VK 24472 86380"
  static final _mgrsRegex = RegExp(
    r'(\d{1,2})\s*([C-HJ-NP-X])\s*([A-HJ-NP-Z])([A-HJ-NP-V])\s*(\d{2,5})\s*(\d{2,5})',
    caseSensitive: false,
  );

  static Coordinate? _tryParseMgrs(String input) {
    final match = _mgrsRegex.firstMatch(input);
    if (match == null) return null;

    final zone = int.parse(match.group(1)!);
    final band = match.group(2)!.toUpperCase();
    final colLetter = match.group(3)!.toUpperCase();
    final rowLetter = match.group(4)!.toUpperCase();
    var eStr = match.group(5)!;
    var nStr = match.group(6)!;

    // Normalize to 5-digit precision
    while (eStr.length < 5) {
      eStr += '0';
    }
    while (nStr.length < 5) {
      nStr += '0';
    }

    final e5 = int.parse(eStr.substring(0, 5));
    final n5 = int.parse(nStr.substring(0, 5));

    // Decode 100km square to easting/northing
    const colLetters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const rowLetters = 'ABCDEFGHJKLMNPQRSTUV';

    final setNumber = (zone - 1) % 6;
    final colIndex = colLetters.indexOf(colLetter);
    if (colIndex < 0) return null;
    final baseCol = (colIndex - setNumber * 8) % colLetters.length;
    final e100km = (baseCol + 1) * 100000;

    final rowIndex = rowLetters.indexOf(rowLetter);
    if (rowIndex < 0) return null;
    final rowOffset = (setNumber % 2 == 0) ? 0 : 5;
    final baseRow = (rowIndex - rowOffset) % rowLetters.length;
    final n100km = baseRow * 100000;

    final easting = e100km + e5.toDouble();
    var northing = n100km + n5.toDouble();

    // Adjust northing based on band (approximate latitude range)
    // Bands C-M are southern, N-X are northern
    final isSouth = band.compareTo('N') < 0;
    if (isSouth) {
      northing += 10000000;
    }
    // Ensure northing is reasonable by checking against band latitude
    while (northing < _bandMinNorthing(band, isSouth)) {
      northing += 2000000;
    }

    if (zone < 1 || zone > 60) return null;
    return _utmToLatLng(zone, band, easting, northing);
  }

  static double _bandMinNorthing(String band, bool isSouth) {
    // Approximate minimum northing for each band
    const bandStarts = {
      'C': 1100000.0,
      'D': 2000000.0,
      'E': 2800000.0,
      'F': 3700000.0,
      'G': 4600000.0,
      'H': 5500000.0,
      'J': 6400000.0,
      'K': 7300000.0,
      'L': 8200000.0,
      'M': 9100000.0,
      'N': 0.0,
      'P': 800000.0,
      'Q': 1700000.0,
      'R': 2600000.0,
      'S': 3500000.0,
      'T': 4400000.0,
      'U': 5300000.0,
      'V': 6200000.0,
      'W': 7000000.0,
      'X': 7900000.0,
    };
    return bandStarts[band] ?? 0.0;
  }
}
