import 'service_locator.dart';
import 'package:navaja_suiza_sanitaria/features/glasgow/domain/glasgow_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/o2_calculator/domain/o2_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/hipotermia/domain/temperature_classifier.dart';
import 'package:navaja_suiza_sanitaria/features/ictus/domain/madrid_direct_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/ictus/domain/cincinnati_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/nihss/domain/nihss_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/tep/domain/tep_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/lund_browder/domain/lund_browder_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/heart_rate/domain/heart_rate_calculator.dart';
import 'package:navaja_suiza_sanitaria/features/rankin/domain/rankin_calculator.dart';

/// Registra todos los servicios/calculators en el contenedor.
/// Se llama una vez en main.dart.
void registerServices() {
  ServiceLocator.register(const GlasgowCalculator());
  ServiceLocator.register(O2Calculator());
  ServiceLocator.register(TemperatureClassifier());
  ServiceLocator.register(const MadridDirectCalculator());
  ServiceLocator.register(const CincinnatiCalculator());
  ServiceLocator.register(const NihssCalculator());
  ServiceLocator.register(const TepCalculator());
  ServiceLocator.register(LundBrowderCalculator());
  ServiceLocator.register(HeartRateCalculator());
  ServiceLocator.register(const RankinCalculator());
}
