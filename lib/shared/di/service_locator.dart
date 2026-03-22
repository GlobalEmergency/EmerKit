/// Contenedor de dependencias simple.
/// Registra y resuelve instancias sin dependencias externas.
///
/// Uso:
///   // En main.dart
///   ServiceLocator.register(GlasgowCalculator());
///
///   // En cualquier screen
///   final calc = ServiceLocator.get();
class ServiceLocator {
  ServiceLocator._();

  static final _instances = <Type, Object>{};
  static final _factories = <Type, Object Function()>{};

  /// Registra una instancia singleton.
  static void register<T extends Object>(T instance) {
    _instances[T] = instance;
  }

  /// Registra una factory que crea una nueva instancia cada vez.
  static void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Obtiene la instancia registrada.
  static T get<T extends Object>() {
    if (_instances.containsKey(T)) return _instances[T] as T;
    if (_factories.containsKey(T)) return _factories[T]!() as T;
    throw Exception(
        'ServiceLocator: $T no está registrado. Llama a register<$T>() primero.');
  }

  /// Comprueba si un tipo está registrado.
  static bool isRegistered<T extends Object>() {
    return _instances.containsKey(T) || _factories.containsKey(T);
  }

  /// Limpia todas las instancias (útil para tests).
  static void reset() {
    _instances.clear();
    _factories.clear();
  }
}
