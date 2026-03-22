import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/features/nihss/domain/nihss_data.dart';
import 'package:emerkit/features/lund_browder/domain/lund_browder_data.dart';
import 'package:emerkit/features/glosario/domain/glosario_data.dart';
import 'package:emerkit/features/rcp/domain/rcp_data.dart';

void main() {
  group('NIHSS - integridad de datos clinicos', () {
    test('tiene exactamente 15 categorias', () {
      expect(NihssData.items.length, 15);
    });

    test('cada categoria tiene al menos 2 opciones', () {
      for (final item in NihssData.items) {
        expect(item.options.length, greaterThanOrEqualTo(2),
            reason: '${item.name} debe tener al menos 2 opciones');
      }
    });

    test('puntuacion maxima es 42', () {
      int maxScore = 0;
      for (final item in NihssData.items) {
        int itemMax = 0;
        for (final opt in item.options) {
          if (opt.score > itemMax) itemMax = opt.score;
        }
        maxScore += itemMax;
      }
      expect(maxScore, 42);
    });
  });

  group('Lund-Browder - integridad de datos clinicos', () {
    test('tiene 19 zonas corporales', () {
      expect(LundBrowderData.zoneNames.length, 19);
    });

    test('porcentajes adulto suman 100%', () {
      const adultIndex = 5; // Adulto
      double total = 0;
      for (final row in LundBrowderData.zonePercentages) {
        total += row[adultIndex];
      }
      expect(total, closeTo(100.0, 0.1));
    });

    test('cada zona tiene porcentaje para las 6 franjas de edad', () {
      for (var i = 0; i < LundBrowderData.zonePercentages.length; i++) {
        expect(LundBrowderData.zonePercentages[i].length, 6,
            reason: 'Zona $i debe tener 6 franjas de edad');
      }
    });
  });

  group('Glosario - integridad de datos clinicos', () {
    test('tiene al menos 80 terminos', () {
      expect(GlosarioData.entries.length, greaterThanOrEqualTo(80));
    });

    test('ningun termino esta vacio', () {
      for (final entry in GlosarioData.entries) {
        expect(entry.term.isNotEmpty, isTrue,
            reason: 'Termino vacio encontrado');
        expect(entry.definition.isNotEmpty, isTrue,
            reason: 'Definicion vacia para: ${entry.term}');
      }
    });

    test('no hay terminos duplicados', () {
      final terms =
          GlosarioData.entries.map((e) => e.term.toLowerCase()).toList();
      final uniqueTerms = terms.toSet();
      expect(uniqueTerms.length, terms.length,
          reason: 'Hay terminos duplicados en el glosario');
    });
  });

  group('RCP SVA - integridad de medicaciones', () {
    test('tiene 4 medicaciones definidas', () {
      expect(RcpData.svaMedications.length, 4);
    });

    test('Adrenalina: 1mg, intervalo 4 min, sin maximo', () {
      final adr = RcpData.svaMedications[0];
      expect(adr.name, 'Adrenalina');
      expect(adr.dose, contains('1mg'));
      expect(adr.interval.inSeconds, greaterThan(0));
      expect(adr.maxDoses, isNull);
    });

    test('Amiodarona: maximo 2 dosis', () {
      final ami = RcpData.svaMedications[1];
      expect(ami.name, 'Amiodarona');
      expect(ami.maxDoses, 2);
    });
  });
}
