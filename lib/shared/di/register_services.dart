import 'service_locator.dart';

// Los calculators se importarán aquí cuando estén creados por los agentes.
// Por ahora es el placeholder que se rellenará en la Fase 4.

/// Registra todos los servicios/calculators en el contenedor.
/// Se llama una vez en main.dart.
void registerServices() {
  // Los calculators son stateless, así que se registran como singletons.
  // Se irán añadiendo a medida que se creen las features:
  //
  // ServiceLocator.register(GlasgowCalculator());
  // ServiceLocator.register(O2Calculator());
  // ServiceLocator.register(TriageEngine(TriageData.nodes));
  // ServiceLocator.register(TemperatureClassifier());
  // ServiceLocator.register(MadridDirectCalculator());
  // ServiceLocator.register(CincinnatiCalculator());
  // ServiceLocator.register(NihssCalculator());
  // ServiceLocator.register(TepCalculator());
  // ServiceLocator.register(LundBrowderCalculator());
  // ServiceLocator.register(HeartRateCalculator());
  // ServiceLocator.register(RankinCalculator());
}
