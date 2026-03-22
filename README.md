# EmerKit

**Tu kit de emergencias sanitarias en el bolsillo.**
*Your pocket emergency medical toolkit.*

[![CI](https://github.com/GlobalEmergency/EmerKit/actions/workflows/ci.yml/badge.svg)](https://github.com/GlobalEmergency/EmerKit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Que es EmerKit / What is EmerKit

**ES** -- EmerKit es una aplicacion multiplataforma desarrollada en Flutter que reune las herramientas clinicas mas utilizadas por profesionales de emergencias sanitarias: tecnicos de emergencias (TES), enfermeros y medicos. Escalas de valoracion, calculadoras de oxigeno, metronomo de RCP, guias de tecnicas... todo en una sola app, sin conexion a internet.

**EN** -- EmerKit is a cross-platform Flutter application that brings together the most commonly used clinical tools for emergency healthcare professionals: EMTs, nurses, and physicians. Assessment scales, oxygen calculators, CPR metronome, technique guides... all in a single app, fully offline.

---

## Herramientas / Features

### Soporte Vital / Life Support
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| Metronomo RCP | CPR Metronome | Ritmo audible a 110 bpm para compresiones / Audible 110 bpm rhythm for compressions |
| Algoritmo SVB | BLS Algorithm | Algoritmo de soporte vital basico paso a paso / Step-by-step basic life support algorithm |
| DEA Cercano | Nearest AED | Enlace a app de localizacion de desfibriladores / Link to AED locator app |

### Valoracion / Assessment
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| Glasgow (GCS) | Glasgow (GCS) | Escala de Coma de Glasgow con clasificacion de gravedad / Glasgow Coma Scale with severity classification |
| Triage START | START Triage | Triage multiple victimas con protocolo START / Mass casualty triage with START protocol |
| TEP | PAT | Triangulo de Evaluacion Pediatrica / Pediatric Assessment Triangle |
| Ictus (Cincinnati + Madrid-DIRECT) | Stroke | Escalas prehospitalarias de ictus / Prehospital stroke scales |
| NIHSS | NIHSS | National Institutes of Health Stroke Scale |
| Rankin | Rankin | Escala de Rankin modificada / Modified Rankin Scale |

### Signos y Valores / Signs & Values
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| Constantes Vitales | Vital Signs | Rangos normales por edad / Normal ranges by age |
| Frecuencia Cardiaca | Heart Rate | Calculadora de FC por palpacion / HR calculator by palpation |
| Glucemia | Blood Glucose | Clasificacion e interpretacion de glucemia / Blood glucose classification and interpretation |
| Hipotermia | Hypothermia | Clasificacion de hipotermia por temperatura / Hypothermia classification by temperature |
| Hipertermia | Hyperthermia | Clasificacion de hipertermia por temperatura / Hyperthermia classification by temperature |

### Oxigenoterapia / Oxygen Therapy
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| Calculadora O2 | O2 Calculator | Calculo de autonomia de botella de oxigeno / Oxygen tank duration calculator |
| Dispositivos O2 | O2 Devices | Guia de dispositivos de oxigenoterapia y flujos / Oxygen therapy devices and flow guide |

### Tecnicas / Techniques
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| Electrodos ECG | ECG Leads | Colocacion de electrodos de 4 y 12 derivaciones / 4 and 12 lead electrode placement |
| Lund-Browder | Lund-Browder | Calculo de superficie corporal quemada / Burn body surface area calculation |
| Vendajes | Bandaging | Guia de tecnicas de vendaje / Bandaging technique guide |
| Heridas | Wounds | Clasificacion y manejo de heridas / Wound classification and management |
| Posiciones | Positions | Posiciones de traslado del paciente / Patient transport positions |

### Proteccion / Protection
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| EPI | PPE | Equipos de proteccion individual / Personal protective equipment |
| ADR | ADR | Identificacion de mercancias peligrosas / Hazardous materials identification |

### Comunicacion / Communication
| Herramienta | Tool | Descripcion / Description |
|---|---|---|
| SBAR | SBAR | Comunicacion estructurada SBAR / SBAR structured communication |

---

## Stack Tecnologico / Tech Stack

| Componente / Component | Tecnologia / Technology |
|---|---|
| Framework | Flutter 3.x |
| Lenguaje / Language | Dart 3.5+ |
| Arquitectura / Architecture | Feature-First DDD |
| Navegacion / Navigation | GoRouter |
| Testing | flutter_test (86+ tests) |
| CI/CD | GitHub Actions |
| Analisis / Analysis | flutter_lints |

---

## Primeros Pasos / Getting Started

### Requisitos / Prerequisites

- Flutter SDK >= 3.x ([flutter.dev](https://flutter.dev))
- Dart SDK >= 3.5
- Android Studio o VS Code con extension Flutter
- Android SDK para builds Android

### Instalacion / Setup

```bash
# Clonar el repositorio / Clone the repository
git clone https://github.com/GlobalEmergency/EmerKit.git
cd EmerKit

# Instalar dependencias / Install dependencies
flutter pub get

# Ejecutar la app / Run the app
flutter run

# Ejecutar tests / Run tests
flutter test

# Analisis estatico / Static analysis
flutter analyze
```

### Compilacion / Build

```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# Web
flutter build web
```

---

## Estructura del Proyecto / Project Structure

```
lib/
├── main.dart                          # Punto de entrada / Entry point
├── app.dart                           # MaterialApp + GoRouter
├── shared/                            # Capa compartida / Shared layer
│   ├── di/                            # Inyeccion de dependencias / Dependency injection
│   ├── domain/
│   │   └── entities/                  # Entidades comunes (Severity, ToolCategory)
│   ├── presentation/
│   │   ├── router/                    # Configuracion de GoRouter
│   │   ├── theme/                     # Tema de la app / App theme
│   │   └── widgets/                   # Widgets reutilizables / Reusable widgets
│   └── utils/                         # Utilidades / Utilities
├── features/                          # Una carpeta por herramienta / One folder per tool
│   ├── glasgow/
│   │   ├── domain/                    # glasgow_calculator.dart, glasgow_data.dart
│   │   └── presentation/             # glasgow_screen.dart
│   ├── triage/
│   ├── rcp/
│   ├── o2_calculator/
│   ├── ictus/
│   ├── ...                            # (24 features en total / 24 total features)
│   └── home/
│       └── presentation/
│           └── tool_registry.dart     # Registro central de herramientas
├── version.json                       # Version unica de la app / Single source of version
└── scripts/
    └── propagate-version.sh           # Propaga version a pubspec.yaml y assets
```

---

## Versionado / Versioning

La version se gestiona desde `version.json`. Al hacer push a main con cambios en este fichero, el CI automaticamente:

1. Crea un tag `vX.Y.Z`
2. Crea un GitHub Release
3. Dispara los builds de Android (Google Play) e iOS (TestFlight)

```bash
# Propagar version a pubspec.yaml y assets
bash scripts/propagate-version.sh

# Verificar que todo esta sincronizado
bash scripts/propagate-version.sh --check
```

---

## Testing

La app incluye **86+ tests unitarios** que verifican casos de uso clinicos reales.
The app includes **86+ unit tests** that verify real clinical use cases.

```
test/
└── domain/
    ├── glasgow_calculator_test.dart
    ├── triage_engine_test.dart
    ├── cincinnati_calculator_test.dart
    ├── madrid_direct_calculator_test.dart
    ├── o2_calculator_test.dart
    ├── nihss_calculator_test.dart
    ├── rankin_calculator_test.dart
    ├── tep_calculator_test.dart
    ├── heart_rate_calculator_test.dart
    ├── lund_browder_calculator_test.dart
    └── temperature_classifier_test.dart
```

### Ejemplo / Example

```dart
test('GCS 3 es Grave', () {
  final r = calculator.calculate(eye: 1, verbal: 1, motor: 1);
  expect(r.total, 3);
  expect(r.severity.label, 'Grave');
  expect(r.severity.level, SeverityLevel.severe);
});
```

```bash
# Ejecutar todos los tests / Run all tests
flutter test

# Un archivo especifico / A specific file
flutter test test/domain/glasgow_calculator_test.dart

# Con cobertura / With coverage
flutter test --coverage
```

---

## Contribuir / Contributing

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para conocer como colaborar.
Read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how to contribute.

---

## Aviso Legal / Disclaimer

**ES** -- EmerKit es una herramienta de apoyo y referencia rapida. No sustituye la formacion profesional, los protocolos oficiales ni el juicio clinico. El uso de esta aplicacion es responsabilidad exclusiva del profesional sanitario.

**EN** -- EmerKit is a quick-reference support tool. It does not replace professional training, official protocols, or clinical judgment. The use of this application is the sole responsibility of the healthcare professional.

---

## Licencia / License

Este proyecto esta licenciado bajo la [Licencia MIT](LICENSE).
This project is licensed under the [MIT License](LICENSE).

---

## Desarrollado por / Developed by

**[Global Emergency](https://www.globalemergency.online/)** -- Organizacion dedicada a mejorar la respuesta ante emergencias.
*Organization dedicated to improving emergency response.*
