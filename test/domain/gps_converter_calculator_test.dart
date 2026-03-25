import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/features/gps_converter/domain/gps_converter_calculator.dart';

void main() {
  group('Conversion DD a DMS', () {
    test('Coordenadas de Madrid (positivas)', () {
      final dms = Coordinate.ddToDms(40.524722);
      expect(dms.degrees, 40);
      expect(dms.minutes, 31);
      expect(dms.seconds, closeTo(29.0, 0.1));
    });

    test('Coordenadas negativas (longitud oeste)', () {
      final dms = Coordinate.ddToDms(-3.891667);
      expect(dms.degrees, 3);
      expect(dms.minutes, 53);
      expect(dms.seconds, closeTo(30.0, 0.1));
    });

    test('Coordenadas cero', () {
      final dms = Coordinate.ddToDms(0.0);
      expect(dms.degrees, 0);
      expect(dms.minutes, 0);
      expect(dms.seconds, closeTo(0.0, 0.01));
    });
  });

  group('Conversion DMS a DD', () {
    test('DMS positivo a decimal', () {
      final dd = Coordinate.dmsToDecimal(40, 31, 29.0);
      expect(dd, closeTo(40.5247, 0.001));
    });

    test('DMS negativo (hemisferio sur)', () {
      final dd = Coordinate.dmsToDecimal(33, 51, 54.0, negative: true);
      expect(dd, closeTo(-33.865, 0.001));
    });

    test('DMS negativo (longitud oeste)', () {
      final dd = Coordinate.dmsToDecimal(3, 53, 30.0, negative: true);
      expect(dd, closeTo(-3.8917, 0.001));
    });
  });

  group('Conversion DM a DD', () {
    test('DM positivo', () {
      final dd = Coordinate.dmToDecimal(40, 31.4833);
      expect(dd, closeTo(40.5247, 0.001));
    });

    test('DM negativo', () {
      final dd = Coordinate.dmToDecimal(3, 53.5000, negative: true);
      expect(dd, closeTo(-3.8917, 0.001));
    });
  });

  group('Conversion a UTM - coordenadas conocidas', () {
    test('Madrid (40.524722, -3.891667) -> zona 30T', () {
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      final utm = coord.toUtm();
      expect(utm.zone, 30);
      expect(utm.band, 'T');
      expect(utm.easting, closeTo(424472, 50));
      expect(utm.northing, closeTo(4486380, 50));
    });

    test('Londres (51.5074, -0.1278) -> zona 30U', () {
      const coord = Coordinate(latitude: 51.5074, longitude: -0.1278);
      final utm = coord.toUtm();
      expect(utm.zone, 30);
      expect(utm.band, 'U');
      // Easting alrededor de 699000, northing alrededor de 5710000
      expect(utm.easting, closeTo(699316, 500));
      expect(utm.northing, closeTo(5710160, 500));
    });

    test('Sydney hemisferio sur (-33.8688, 151.2093) -> zona 56H', () {
      const coord = Coordinate(latitude: -33.8688, longitude: 151.2093);
      final utm = coord.toUtm();
      expect(utm.zone, 56);
      expect(utm.band, 'H');
      expect(utm.easting, closeTo(334369, 500));
      expect(utm.northing, closeTo(6250948, 1000));
    });

    test('Ecuador y meridiano 0 (0.0, 0.0) -> zona 31N', () {
      const coord = Coordinate(latitude: 0.0, longitude: 0.0);
      final utm = coord.toUtm();
      expect(utm.zone, 31);
      expect(utm.band, 'N');
    });
  });

  group('Conversion a MGRS', () {
    test('Madrid genera formato MGRS valido', () {
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      final mgrs = coord.toMgrs();
      // Debe empezar con zona 30T
      expect(mgrs, startsWith('30T'));
      // Debe tener el formato: zona banda espacio 2letras espacio 5digitos espacio 5digitos
      expect(mgrs.split(' ').length, 4);
    });
  });

  group('Formato de salida completo', () {
    test('toAllFormats genera los 5 formatos', () {
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      final formats = coord.toAllFormats();

      expect(formats.decimal, contains('40.524722'));
      expect(formats.degreesMinutes, contains('40°'));
      expect(formats.degreesMinutes, contains('N'));
      expect(formats.degreesMinutesSeconds, contains('40°'));
      expect(formats.degreesMinutesSeconds, contains('"'));
      expect(formats.utm.zone, 30);
      expect(formats.mgrs, isNotEmpty);
    });
  });

  group('URI de navegacion', () {
    test('Genera URI geo: valido', () {
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      expect(coord.toNavigationUri(), 'geo:40.524722,-3.891667');
    });

    test('Genera URI Google Maps valido', () {
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      expect(
          coord.toGoogleMapsUri(), 'google.navigation:q=40.524722,-3.891667');
    });
  });

  group('CoordinateParser - formato decimal', () {
    test('Parsea DD con coma', () {
      final coord = CoordinateParser.parse('40.524722, -3.891667');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.5247, 0.001));
      expect(coord.longitude, closeTo(-3.8917, 0.001));
    });

    test('Parsea DD con espacio', () {
      final coord = CoordinateParser.parse('40.524722 -3.891667');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.5247, 0.001));
    });

    test('Parsea DD con simbolo de grado', () {
      final coord = CoordinateParser.parse('40.524722° -3.891667°');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.5247, 0.001));
    });

    test('Rechaza latitud fuera de rango', () {
      final coord = CoordinateParser.parse('95.0, -3.0');
      expect(coord, isNull);
    });

    test('Rechaza longitud fuera de rango', () {
      final coord = CoordinateParser.parse('40.0, 200.0');
      expect(coord, isNull);
    });
  });

  group('CoordinateParser - formato DMS', () {
    test('Parsea DMS con N/W', () {
      final coord =
          CoordinateParser.parse('40° 31\' 29.00" N, 3° 53\' 30.00" W');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.5247, 0.001));
      expect(coord.longitude, closeTo(-3.8917, 0.001));
    });

    test('Parsea DMS hemisferio sur', () {
      final coord =
          CoordinateParser.parse('33° 51\' 54.00" S, 151° 12\' 33.00" E');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(-33.865, 0.001));
      expect(coord.longitude, closeTo(151.209, 0.001));
    });
  });

  group('CoordinateParser - formato DM', () {
    test('Parsea DM con N/W', () {
      final coord = CoordinateParser.parse('40° 31.4833\' N, 3° 53.5000\' W');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.5247, 0.001));
      expect(coord.longitude, closeTo(-3.8917, 0.001));
    });
  });

  group('CoordinateParser - formato UTM', () {
    test('Parsea UTM con E/N sufijos', () {
      final coord = CoordinateParser.parse('30T 424472E 4486380N');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.525, 0.01));
      expect(coord.longitude, closeTo(-3.892, 0.01));
    });

    test('Parsea UTM sin sufijos', () {
      final coord = CoordinateParser.parse('30T 424472 4486380');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(40.525, 0.01));
    });

    test('Parsea UTM zona 56 hemisferio sur', () {
      final coord = CoordinateParser.parse('56H 334369 6250948');
      expect(coord, isNotNull);
      expect(coord!.latitude, closeTo(-33.87, 0.05));
      expect(coord.longitude, closeTo(151.21, 0.05));
    });
  });

  group('CoordinateParser - formato MGRS', () {
    test('Parsea MGRS basico', () {
      // First convert a known coordinate to MGRS, then parse it back
      const coord = Coordinate(latitude: 40.524722, longitude: -3.891667);
      final mgrs = coord.toMgrs();
      final parsed = CoordinateParser.parse(mgrs);
      expect(parsed, isNotNull);
      // Should be within ~100m of original
      expect(parsed!.latitude, closeTo(40.525, 0.01));
      expect(parsed.longitude, closeTo(-3.892, 0.05));
    });
  });

  group('CoordinateParser - entradas invalidas', () {
    test('String vacio retorna null', () {
      expect(CoordinateParser.parse(''), isNull);
    });

    test('Texto aleatorio retorna null', () {
      expect(CoordinateParser.parse('hola mundo'), isNull);
    });

    test('Un solo numero retorna null', () {
      expect(CoordinateParser.parse('40.5'), isNull);
    });
  });
}
