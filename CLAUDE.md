# CLAUDE.md - Project Rules for AI Assistants

## Project Overview

EmerKit (navaja_suiza_sanitaria) is a cross-platform Flutter app with 24 clinical tools for emergency healthcare professionals. Developed by Global Emergency.

## Architecture

**Feature-First DDD** with a shared layer.

```
lib/
├── shared/              # Cross-cutting: widgets, entities, DI, theme, router
│   ├── di/              # Service locator pattern for dependency injection
│   ├── domain/entities/ # Severity, ToolCategory
│   ├── presentation/
│   │   ├── widgets/     # ToolScreenBase, ResultBanner, InfoCard, ScoredItemSelector, ToolInfoPanel
│   │   ├── theme/
│   │   └── router/      # GoRouter configuration
│   └── utils/
├── features/            # One folder per tool
│   └── <feature>/
│       ├── domain/      # Pure Dart calculators and data (NO Flutter imports)
│       └── presentation/# Screens and feature-specific widgets
└── screens/             # General screens
```

## Key Commands

```bash
flutter test                # Run all tests (85+ unit tests)
flutter analyze             # Static analysis with flutter_lints
flutter build apk --debug   # Debug APK
flutter build apk --release # Release APK
flutter pub get             # Install dependencies
flutter run                 # Run on connected device
```

## Code Conventions

### Imports
- **Cross-feature**: use `package:navaja_suiza_sanitaria/...`
- **Within same feature**: use relative imports
- Example: a screen in `features/glasgow/presentation/` importing its calculator uses `../domain/glasgow_calculator.dart`

### File Naming Patterns
| Type | Pattern | Example |
|---|---|---|
| Calculator | `<feature>_calculator.dart` | `glasgow_calculator.dart` |
| Data | `<feature>_data.dart` | `glasgow_data.dart` |
| Screen | `<feature>_screen.dart` | `glasgow_screen.dart` |
| Test | `<feature>_calculator_test.dart` | `glasgow_calculator_test.dart` |

### Dart Style
- `analysis_options.yaml` enforces: `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`
- Linter: `flutter_lints`

## Critical Rules

### Calculators are Pure Dart
Calculators in `domain/` must NOT import `package:flutter/...`. They contain only pure Dart logic. This allows them to be tested without Flutter framework overhead and keeps domain logic framework-independent.

### Testing Rules
- Use `flutter_test`, NOT `package:test`
- Test **clinical use cases**, not class methods
- Use descriptive group names that describe the clinical scenario
- Follow the AAA pattern (Arrange, Act, Assert)
- Tests live in `test/domain/` at project root

```dart
// CORRECT: clinical use case
group('Paciente con minima puntuacion (coma profundo)', () {
  test('GCS 3 es Grave', () {
    final r = calculator.calculate(eye: 1, verbal: 1, motor: 1);
    expect(r.total, 3);
    expect(r.severity.level, SeverityLevel.severe);
  });
});
```

### Shared Widgets
Reuse these widgets from `lib/shared/presentation/widgets/`:
- `ToolScreenBase` -- base scaffold for tool screens
- `ResultBanner` -- colored result display banner
- `InfoCard` -- informational cards
- `ScoredItemSelector` -- selector for scored items (e.g., Glasgow eye/verbal/motor)
- `ToolInfoPanel` -- panel with tool description and references
- `SectionHeader` -- section divider headers

### Dependency Injection
Uses a **service locator pattern** in `lib/shared/di/`.

### Navigation
Uses **GoRouter** (`go_router` package). Routes defined in `lib/shared/presentation/router/`.

### Tool Registration
All tools are registered in `lib/features/home/presentation/tool_registry.dart` with:
- `id`: unique identifier
- `name`: display name (Spanish)
- `icon`: Material icon
- `route`: GoRouter path
- `category`: one of ToolCategory enum values

### Categories (ToolCategory enum)
- `soporteVital` -- Life Support
- `valoracion` -- Assessment
- `signosValores` -- Signs & Values
- `oxigenoterapia` -- Oxygen Therapy
- `tecnicas` -- Techniques
- `proteccion` -- Protection
- `comunicacion` -- Communication

## Adding a New Tool

1. Create `lib/features/<tool>/domain/<tool>_calculator.dart` (pure Dart)
2. Create `lib/features/<tool>/domain/<tool>_data.dart` (static data)
3. Create `lib/features/<tool>/presentation/<tool>_screen.dart` (use shared widgets)
4. Add route in `lib/shared/presentation/router/`
5. Register in `lib/features/home/presentation/tool_registry.dart`
6. Write tests in `test/domain/<tool>_calculator_test.dart`
7. Run `flutter analyze && flutter test`

## Commit Convention

Conventional Commits: `<type>(<scope>): <description>`
Types: feat, fix, test, docs, refactor, ci, chore
Scopes: glasgow, triage, ictus, o2, rcp, tep, nihss, rankin, shared, ci, docs
