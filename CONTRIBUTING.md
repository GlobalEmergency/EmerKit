# Contribuir a EmerKit / Contributing to EmerKit

Gracias por tu interes en contribuir a EmerKit.
Thank you for your interest in contributing to EmerKit.

---

## Inicio Rapido / Quick Start (< 5 min)

```bash
# 1. Fork y clona / Fork and clone
git clone https://github.com/<tu-usuario>/NavajaSuizaSanitaria.git
cd NavajaSuizaSanitaria/navaja_suiza_sanitaria

# 2. Instala dependencias / Install dependencies
flutter pub get

# 3. Ejecuta tests / Run tests
flutter test

# 4. Crea tu rama / Create your branch
git checkout -b feat/mi-nueva-feature
```

---

## Arquitectura / Architecture

EmerKit sigue una arquitectura **Feature-First DDD** (Domain-Driven Design orientado a features).

EmerKit follows a **Feature-First DDD** (feature-oriented Domain-Driven Design) architecture.

```
lib/
├── shared/              # Capa compartida / Shared layer
│   ├── di/              # Service locator (DI)
│   ├── domain/entities/ # Severity, ToolCategory
│   ├── presentation/
│   │   ├── widgets/     # ToolScreenBase, ResultBanner, InfoCard...
│   │   ├── theme/
│   │   └── router/
│   └── utils/
└── features/            # Una carpeta por herramienta / One folder per tool
    └── <feature>/
        ├── domain/      # Calculadoras, datos, logica pura / Calculators, data, pure logic
        └── presentation/# Screens, widgets especificos / Specific screens & widgets
```

### Principios clave / Key Principles

- **Calculadores son Dart puro**: sin imports de Flutter, sin dependencias externas.
  *Calculators are pure Dart*: no Flutter imports, no external dependencies.
- **Un feature = una carpeta**: toda la logica de una herramienta vive en su carpeta.
  *One feature = one folder*: all tool logic lives in its own folder.
- **Shared es transversal**: widgets, entidades y utilidades comunes.
  *Shared is cross-cutting*: common widgets, entities, and utilities.

---

## Convenciones de Codigo / Code Conventions

### Estilo Dart / Dart Style

- Seguimos las reglas de `flutter_lints` definidas en `analysis_options.yaml`.
  We follow the `flutter_lints` rules defined in `analysis_options.yaml`.
- `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`.
- Ejecuta `flutter analyze` antes de cada commit.
  Run `flutter analyze` before every commit.

### Imports

- **Entre features**: usa `package:navaja_suiza_sanitaria/...`
  *Cross-feature*: use `package:navaja_suiza_sanitaria/...`
- **Dentro del mismo feature**: usa imports relativos.
  *Within the same feature*: use relative imports.

### Patrones de archivos / File Patterns

| Tipo / Type | Patron / Pattern | Ejemplo / Example |
|---|---|---|
| Calculadora / Calculator | `<feature>_calculator.dart` | `glasgow_calculator.dart` |
| Datos / Data | `<feature>_data.dart` | `glasgow_data.dart` |
| Pantalla / Screen | `<feature>_screen.dart` | `glasgow_screen.dart` |
| Test | `<feature>_calculator_test.dart` | `glasgow_calculator_test.dart` |

---

## Formato de Commits / Commit Format

Usamos **Conventional Commits**. We use **Conventional Commits**.

```
<tipo>(<scope>): <descripcion>

feat(glasgow): add pediatric GCS variant
fix(o2): correct cylinder volume calculation
test(triage): add START triage edge cases
docs: update README with new tools
refactor(shared): extract result banner widget
ci: add Android build workflow
chore(deps): bump go_router to 14.9.0
```

### Tipos / Types

| Tipo / Type | Uso / Usage |
|---|---|
| `feat` | Nueva funcionalidad / New feature |
| `fix` | Correccion de bug / Bug fix |
| `test` | Anadir o mejorar tests / Add or improve tests |
| `docs` | Documentacion / Documentation |
| `refactor` | Refactorizacion sin cambio funcional / No functional change |
| `ci` | Cambios en CI/CD / CI/CD changes |
| `chore` | Tareas de mantenimiento / Maintenance tasks |

### Scopes

`glasgow`, `triage`, `ictus`, `o2`, `rcp`, `tep`, `nihss`, `rankin`, `shared`, `ci`, `docs`

---

## Nombrado de Ramas / Branch Naming

```
feat/<nombre-descriptivo>      # Nueva herramienta o funcionalidad
fix/<nombre-descriptivo>       # Correccion de bug
refactor/<nombre-descriptivo>  # Refactorizacion
docs/<nombre-descriptivo>      # Documentacion
test/<nombre-descriptivo>      # Tests
```

Ejemplos / Examples:
- `feat/pediatric-glasgow`
- `fix/o2-calculation-rounding`
- `docs/contributing-guide`

---

## Testing

### Ejecutar tests / Running tests

```bash
# Todos los tests / All tests
flutter test

# Un archivo / Single file
flutter test test/domain/glasgow_calculator_test.dart

# Con cobertura / With coverage
flutter test --coverage
```

### Reglas de testing / Testing Rules

1. **Usa `flutter_test`**, no `package:test`.
   Use `flutter_test`, not `package:test`.

2. **Testea casos de uso clinicos**, no metodos de clase.
   Test **clinical use cases**, not class methods.

   ```dart
   // BIEN / GOOD: describe el caso clinico
   group('Paciente con minima puntuacion (coma profundo)', () {
     test('GCS 3 es Grave', () {
       final r = calculator.calculate(eye: 1, verbal: 1, motor: 1);
       expect(r.total, 3);
       expect(r.severity.level, SeverityLevel.severe);
     });
   });

   // MAL / BAD: describe el metodo
   test('calculate returns 3', () { ... });
   ```

3. **Patron AAA** (Arrange, Act, Assert).
   Use the **AAA pattern** (Arrange, Act, Assert).

4. **Cada calculadora necesita tests** antes de hacer merge.
   Every calculator needs tests before merging.

---

## Flujo de Pull Request / PR Workflow

1. Crea un fork y clona / Fork and clone.
2. Crea una rama desde `main` / Create a branch from `main`.
3. Desarrolla y escribe tests / Develop and write tests.
4. Asegurate de que pasan todos los checks:
   Make sure all checks pass:
   ```bash
   flutter analyze
   flutter test
   ```
5. Abre un Pull Request describiendo los cambios.
   Open a Pull Request describing the changes.
6. Espera la revision / Wait for review.

---

## Anadir una Nueva Herramienta / Adding a New Tool

Guia paso a paso para anadir una herramienta clinica nueva.
Step-by-step guide to adding a new clinical tool.

### 1. Crear la carpeta del feature / Create the feature folder

```
lib/features/<nueva_herramienta>/
├── domain/
│   ├── <herramienta>_calculator.dart   # Logica pura en Dart
│   └── <herramienta>_data.dart         # Datos estaticos (items, opciones)
└── presentation/
    └── <herramienta>_screen.dart       # Pantalla con widgets de shared/
```

### 2. Implementar el calculador / Implement the calculator

```dart
// lib/features/mi_escala/domain/mi_escala_calculator.dart
// SIN imports de Flutter / NO Flutter imports

class MiEscalaResult {
  final int total;
  final Severity severity;
  const MiEscalaResult({required this.total, required this.severity});
}

class MiEscalaCalculator {
  const MiEscalaCalculator();

  MiEscalaResult calculate({required int param1, required int param2}) {
    final total = param1 + param2;
    return MiEscalaResult(
      total: total,
      severity: _classify(total),
    );
  }

  Severity _classify(int score) { /* ... */ }
}
```

### 3. Crear la pantalla / Create the screen

Usa los widgets compartidos / Use shared widgets:
- `ToolScreenBase` -- estructura base de la pantalla
- `ResultBanner` -- banner con el resultado y color de gravedad
- `InfoCard` -- tarjetas informativas
- `ScoredItemSelector` -- selector de items con puntuacion
- `ToolInfoPanel` -- panel de informacion de la herramienta

### 4. Registrar la ruta / Register the route

Anade la ruta en `lib/shared/presentation/router/`.
Add the route in `lib/shared/presentation/router/`.

### 5. Registrar en ToolRegistry / Register in ToolRegistry

```dart
// lib/features/home/presentation/tool_registry.dart
ToolEntry(
  id: 'mi_escala',
  name: 'Mi Escala',
  icon: Icons.assessment,
  route: '/mi-escala',
  category: ToolCategory.valoracion,
),
```

### 6. Escribir tests / Write tests

```dart
// test/domain/mi_escala_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:navaja_suiza_sanitaria/features/mi_escala/domain/mi_escala_calculator.dart';

void main() {
  const calculator = MiEscalaCalculator();

  group('Caso clinico: paciente con puntuacion maxima', () {
    test('devuelve gravedad leve', () {
      final r = calculator.calculate(param1: 5, param2: 5);
      expect(r.total, 10);
      expect(r.severity.level, SeverityLevel.mild);
    });
  });
}
```

### 7. Verificar / Verify

```bash
flutter analyze
flutter test
flutter run
```

---

## Codigo de Conducta / Code of Conduct

Se respetuoso y constructivo. Este proyecto esta destinado a mejorar herramientas para profesionales que salvan vidas.

Be respectful and constructive. This project is aimed at improving tools for professionals who save lives.
